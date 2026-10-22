#import "CRMNearbyDrawingViewController.h"
#import "CRMNearbyDrawingDocument.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

static NSString * const CRMBoardService = @"crm-draw";
static NSArray<UIColor *> *CRMBoardColors(void) {
    UIColor *ink = UIColor.blackColor;
    if (@available(iOS 13.0, *)) ink = UIColor.labelColor;
    return @[ink, UIColor.systemRedColor, UIColor.systemOrangeColor,
             UIColor.systemGreenColor, UIColor.systemBlueColor, UIColor.systemPurpleColor];
}
static UIButton *CRMBoardButton(NSString *title, id target, SEL action) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button.heightAnchor constraintGreaterThanOrEqualToConstant:44].active = YES;
    return button;
}

@interface CRMNearbyCanvas : UIView
@property (nonatomic, strong) CRMNearbyDrawingDocument *document;
@property (nonatomic, copy) void (^touchHandler)(CGPoint point, UIGestureRecognizerState state);
@end
@implementation CRMNearbyCanvas
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (NSDictionary *stroke in self.document.strokes) {
        NSArray *points = stroke[@"points"];
        CGFloat width = [stroke[@"width"] doubleValue] / 1000.0 * self.bounds.size.width;
        UIColor *color = CRMBoardColors()[[stroke[@"color"] unsignedIntegerValue]];
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextSetLineWidth(context, width);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGPoint first = CGPointMake([points[0][0] doubleValue] * self.bounds.size.width,
                                   [points[0][1] doubleValue] * self.bounds.size.height);
        if (points.count == 1) {
            CGContextFillEllipseInRect(context, CGRectMake(first.x - width / 2, first.y - width / 2, width, width));
        } else {
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, first.x, first.y);
            for (NSUInteger index = 1; index < points.count; index++) {
                CGContextAddLineToPoint(context, [points[index][0] doubleValue] * self.bounds.size.width,
                                       [points[index][1] doubleValue] * self.bounds.size.height);
            }
            CGContextStrokePath(context);
        }
    }
}
- (void)emitTouch:(UITouch *)touch state:(UIGestureRecognizerState)state {
    if (!touch || !self.touchHandler || self.bounds.size.width <= 0 || self.bounds.size.height <= 0) return;
    CGPoint point = [touch locationInView:self];
    point.x = MIN(1, MAX(0, point.x / self.bounds.size.width));
    point.y = MIN(1, MAX(0, point.y / self.bounds.size.height));
    self.touchHandler(point, state);
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self emitTouch:touches.anyObject state:UIGestureRecognizerStateBegan]; }
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSArray<UITouch *> *samples = [event coalescedTouchesForTouch:touches.anyObject];
    for (UITouch *touch in samples ?: touches.allObjects) [self emitTouch:touch state:UIGestureRecognizerStateChanged];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self emitTouch:touches.anyObject state:UIGestureRecognizerStateEnded]; }
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self emitTouch:touches.anyObject state:UIGestureRecognizerStateCancelled]; }
@end

@interface CRMNearbyDrawingViewController () <MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>
@property (nonatomic, strong) CRMNearbyDrawingDocument *document;
@property (nonatomic, strong) CRMNearbyCanvas *canvas;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UIStackView *drawingTools;
@property (nonatomic, strong) UISegmentedControl *colorControl;
@property (nonatomic, strong) UISegmentedControl *widthControl;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic, strong) MCNearbyServiceBrowser *peerBrowser;
@property (nonatomic, strong) MCPeerID *localPeer;
@property (nonatomic, strong) NSMutableArray<MCPeerID *> *nearbyPeers;
@property (nonatomic, strong) UIScrollView *peerScroll;
@property (nonatomic, strong) UIStackView *peerList;
@property (nonatomic, strong) UIStackView *invitationPanel;
@property (nonatomic, strong) UILabel *invitationLabel;
@property (nonatomic, strong) NSTimer *connectionTimer;
@property (nonatomic, strong) NSMutableArray<NSString *> *connectionEvents;
@property (nonatomic) BOOL stoppingConnection;
@property (nonatomic, weak) UINavigationController *boardNavigationController;
@property (nonatomic) BOOL departurePending;
@property (nonatomic, strong) MCPeerID *acceptedPeer;
@property (nonatomic) BOOL host;
@property (nonatomic) BOOL ready;
@property (nonatomic, copy) NSString *strokeID;
@property (nonatomic) CGPoint lastPoint;
@property (nonatomic, strong) NSMutableArray *pendingPoints;
@property (nonatomic, strong) NSTimer *flushTimer;
@property (nonatomic, strong) NSTimer *healthTimer;
@property (nonatomic) NSTimeInterval lastPeerMessage;
@property (nonatomic) NSTimeInterval lastRepairTime;
@property (nonatomic) NSTimeInterval lastProgressLog;
@property (nonatomic) NSUInteger sentOperations;
@property (nonatomic) NSUInteger receivedOperations;
@property (nonatomic) NSUInteger peerRevision;
@property (nonatomic, copy) void (^pendingInvitation)(BOOL accept, MCSession *session);
@end

@implementation CRMNearbyDrawingViewController

// 全屏返回库会读取当前页面的此开关，避免横向游戏操作触发返回。
// 直接实现读取方法，让独立画板工程也无需依赖该手势库。
- (BOOL)fd_interactivePopDisabled {
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"你画我看";
    self.view.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
    if (@available(iOS 13.0, *)) self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.document = [CRMNearbyDrawingDocument new];
    self.pendingPoints = [NSMutableArray array];
    self.nearbyPeers = [NSMutableArray array];
    self.connectionEvents = [NSMutableArray array];
    [self buildInterface];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"连接日志" style:UIBarButtonItemStylePlain target:self action:@selector(copyConnectionLog)];
    [self updateRole];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}
- (void)buildInterface {
    UIStackView *content = [[UIStackView alloc] init];
    content.axis = UILayoutConstraintAxisVertical;
    content.spacing = 12;
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:content];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [content.topAnchor constraintEqualToAnchor:safe.topAnchor constant:12],
        [content.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:16],
        [content.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-16],
        [content.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-12]
    ]];
    UIStackView *connection = [[UIStackView alloc] initWithArrangedSubviews:@[
        CRMBoardButton(@"创建画板", self, @selector(createBoard)),
        CRMBoardButton(@"加入画板", self, @selector(joinBoard)),
        CRMBoardButton(@"断开", self, @selector(disconnectBoard))]];
    connection.distribution = UIStackViewDistributionFillEqually;
    [content addArrangedSubview:connection];
    self.statusLabel = [UILabel new];
    self.statusLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.text = @"一台创建画板，另一台加入，即可实时观看。";
    [content addArrangedSubview:self.statusLabel];
    self.invitationLabel = [UILabel new];
    self.invitationLabel.numberOfLines = 0;
    self.invitationLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    UIStackView *invitationActions = [[UIStackView alloc] initWithArrangedSubviews:@[
        CRMBoardButton(@"允许观看", self, @selector(acceptInvitation)),
        CRMBoardButton(@"拒绝", self, @selector(rejectInvitation))]];
    invitationActions.distribution = UIStackViewDistributionFillEqually;
    self.invitationPanel = [[UIStackView alloc] initWithArrangedSubviews:@[self.invitationLabel, invitationActions]];
    self.invitationPanel.axis = UILayoutConstraintAxisVertical;
    self.invitationPanel.hidden = YES;
    [content addArrangedSubview:self.invitationPanel];
    self.peerScroll = [UIScrollView new];
    self.peerScroll.hidden = YES;
    [self.peerScroll.heightAnchor constraintEqualToConstant:100].active = YES;
    self.peerList = [UIStackView new];
    self.peerList.axis = UILayoutConstraintAxisVertical;
    self.peerList.spacing = 4;
    self.peerList.translatesAutoresizingMaskIntoConstraints = NO;
    [self.peerScroll addSubview:self.peerList];
    [NSLayoutConstraint activateConstraints:@[
        [self.peerList.topAnchor constraintEqualToAnchor:self.peerScroll.contentLayoutGuide.topAnchor],
        [self.peerList.bottomAnchor constraintEqualToAnchor:self.peerScroll.contentLayoutGuide.bottomAnchor],
        [self.peerList.leadingAnchor constraintEqualToAnchor:self.peerScroll.contentLayoutGuide.leadingAnchor],
        [self.peerList.trailingAnchor constraintEqualToAnchor:self.peerScroll.contentLayoutGuide.trailingAnchor],
        [self.peerList.widthAnchor constraintEqualToAnchor:self.peerScroll.frameLayoutGuide.widthAnchor]
    ]];
    [content addArrangedSubview:self.peerScroll];
    UIView *canvasArea = [UIView new];
    [content addArrangedSubview:canvasArea];
    self.canvas = [CRMNearbyCanvas new];
    self.canvas.document = self.document;
    self.canvas.backgroundColor = UIColor.whiteColor;
    if (@available(iOS 13.0, *)) self.canvas.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
    self.canvas.layer.cornerRadius = 16;
    self.canvas.clipsToBounds = YES;
    self.canvas.contentMode = UIViewContentModeRedraw;
    self.canvas.translatesAutoresizingMaskIntoConstraints = NO;
    [canvasArea addSubview:self.canvas];
    NSLayoutConstraint *fillWidth = [self.canvas.widthAnchor constraintEqualToAnchor:canvasArea.widthAnchor];
    fillWidth.priority = UILayoutPriorityDefaultHigh;
    NSLayoutConstraint *fillHeight = [self.canvas.heightAnchor constraintEqualToAnchor:canvasArea.heightAnchor];
    fillHeight.priority = UILayoutPriorityDefaultLow;
    [NSLayoutConstraint activateConstraints:@[
        [self.canvas.centerXAnchor constraintEqualToAnchor:canvasArea.centerXAnchor],
        [self.canvas.centerYAnchor constraintEqualToAnchor:canvasArea.centerYAnchor],
        [self.canvas.widthAnchor constraintEqualToAnchor:self.canvas.heightAnchor multiplier:0.75],
        [self.canvas.widthAnchor constraintLessThanOrEqualToAnchor:canvasArea.widthAnchor],
        [self.canvas.heightAnchor constraintLessThanOrEqualToAnchor:canvasArea.heightAnchor], fillWidth, fillHeight
    ]];
    __weak typeof(self) weakSelf = self;
    self.canvas.touchHandler = ^(CGPoint point, UIGestureRecognizerState state) { [weakSelf handlePoint:point state:state]; };
    self.colorControl = [[UISegmentedControl alloc] initWithItems:@[@"墨", @"红", @"橙", @"绿", @"蓝", @"紫"]];
    self.colorControl.selectedSegmentIndex = 0;
    self.widthControl = [[UISegmentedControl alloc] initWithItems:@[@"细", @"中", @"粗"]];
    self.widthControl.selectedSegmentIndex = 1;
    UIStackView *actions = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.widthControl, CRMBoardButton(@"撤销", self, @selector(undoStroke)),
        CRMBoardButton(@"清空", self, @selector(clearBoard))]];
    actions.distribution = UIStackViewDistributionFillEqually;
    actions.spacing = 8;
    self.drawingTools = [[UIStackView alloc] initWithArrangedSubviews:@[self.colorControl, actions]];
    self.drawingTools.axis = UILayoutConstraintAxisVertical;
    self.drawingTools.spacing = 10;
    [content addArrangedSubview:self.drawingTools];
    self.hintLabel = [UILabel new];
    self.hintLabel.font = [UIFont systemFontOfSize:12];
    self.hintLabel.textColor = UIColor.grayColor;
    if (@available(iOS 13.0, *)) self.hintLabel.textColor = UIColor.secondaryLabelColor;
    self.hintLabel.numberOfLines = 0;
    [content addArrangedSubview:self.hintLabel];
}
- (void)updateRole {
    self.canvas.userInteractionEnabled = self.host;
    self.colorControl.enabled = self.host;
    for (UIView *row in self.drawingTools.arrangedSubviews) {
        if ([row isKindOfClass:UIStackView.class]) for (UIControl *control in ((UIStackView *)row).arrangedSubviews) control.enabled = self.host;
    }
    self.hintLabel.text = self.host ? @"你负责画，对方负责看。重连会补齐画布；最多 500 笔、2 万个点，满后可撤销或清空。" :
        @"保持两台设备停留在此页面，并允许本地网络访问。建议开启 Wi-Fi 和蓝牙；无需互联网。";
}
- (void)showMessage:(NSString *)message {
    if (self.presentedViewController) { self.statusLabel.text = message; return; }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"你画我看" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)recordConnectionEvent:(NSString *)event {
    if (!self.connectionEvents) self.connectionEvents = [NSMutableArray array];
    NSString *line = [NSString stringWithFormat:@"%.1f %@", NSDate.timeIntervalSinceReferenceDate, event];
    [self.connectionEvents addObject:line];
    if (self.connectionEvents.count > 80) [self.connectionEvents removeObjectAtIndex:0];
    NSLog(@"[你画我看] %@", line);
}
- (void)copyConnectionLog {
    NSString *header = [NSString stringWithFormat:@"画板连接诊断 v4 · %@ · iOS %@\n%@\n", UIDevice.currentDevice.model, UIDevice.currentDevice.systemVersion, self.statusLabel.text];
    UIPasteboard.generalPasteboard.string = [header stringByAppendingString:[self.connectionEvents componentsJoinedByString:@"\n"] ?: @""];
    [self showMessage:@"连接日志已复制。若仍无法连接，请分别复制两台设备的日志，用于对照发现、邀请、加密握手和画布同步阶段。"]; 
}
- (void)prepareSession {
    [self stopConnection];
    // 同一页面内重试复用设备身份，减少重新生成身份导致的过期发现条目。
    if (!self.localPeer) {
        NSString *suffix = [NSUUID.UUID.UUIDString substringToIndex:4];
        self.localPeer = [[MCPeerID alloc] initWithDisplayName:[NSString stringWithFormat:@"%@-%@", UIDevice.currentDevice.model, suffix]];
    }
    self.session = [[MCSession alloc] initWithPeer:self.localPeer securityIdentity:nil encryptionPreference:MCEncryptionRequired];
    self.session.delegate = self;
    [self recordConnectionEvent:[NSString stringWithFormat:@"建立会话 %@，iOS %@，要求加密", self.localPeer.displayName, UIDevice.currentDevice.systemVersion]];
}
- (void)createBoard {
    if (self.session) { [self showMessage:@"请先断开当前连接，再创建或加入其他画板。"]; return; }
    [self prepareSession];
    self.host = YES;
    [self updateRole];
    self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.session.myPeerID discoveryInfo:@{@"role": @"host", @"version": @"1"} serviceType:CRMBoardService];
    self.advertiser.delegate = self;
    [self.advertiser startAdvertisingPeer];
    [self recordConnectionEvent:@"创建端开始广播，等待邀请"];
    self.statusLabel.text = [NSString stringWithFormat:@"画板已创建：%@\n等待对方加入，现在也可以先画。", self.session.myPeerID.displayName];
}
- (void)joinBoard {
    if (self.session) { [self showMessage:@"请先断开当前连接，再创建或加入其他画板。"]; return; }
    void (^join)(void) = ^{
        [self prepareSession];
        self.host = NO;
        [self updateRole];
        self.peerBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.session.myPeerID serviceType:CRMBoardService];
        self.peerBrowser.delegate = self;
        self.peerScroll.hidden = NO;
        self.peerList.hidden = NO;
        [self refreshPeerList];
        [self.peerBrowser startBrowsingForPeers];
        [self recordConnectionEvent:@"观看端开始发现附近画板"];
        self.statusLabel.text = @"正在寻找附近画板，请点击下方设备名称连接。";
    };
    if (!self.document.strokes.count) { join(); return; }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"加入其他画板？" message:@"连接后将用对方的画布替换当前内容。" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"加入" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { join(); }]];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)refreshPeerList {
    for (UIView *view in self.peerList.arrangedSubviews) { [self.peerList removeArrangedSubview:view]; [view removeFromSuperview]; }
    if (!self.nearbyPeers.count) {
        UILabel *label = [UILabel new];
        label.text = @"尚未发现画板，请让另一台设备点击「创建画板」。";
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:13];
        [self.peerList addArrangedSubview:label];
    }
    for (NSUInteger index = 0; index < self.nearbyPeers.count; index++) {
        UIButton *button = CRMBoardButton([NSString stringWithFormat:@"连接 %@", self.nearbyPeers[index].displayName], self, @selector(selectNearbyPeer:));
        button.tag = index;
        button.enabled = !self.acceptedPeer;
        [self.peerList addArrangedSubview:button];
    }
}
- (void)selectNearbyPeer:(UIButton *)button {
    if (self.host || !self.peerBrowser || self.acceptedPeer || button.tag < 0 || button.tag >= self.nearbyPeers.count) return;
    MCPeerID *peer = self.nearbyPeers[button.tag];
    self.acceptedPeer = peer;
    [self refreshPeerList];
    [self recordConnectionEvent:[NSString stringWithFormat:@"发送邀请至 %@，等待对方确认", peer.displayName]];
    self.statusLabel.text = @"邀请已发出，请在对方画板页面点击「允许观看」。";
    [self startConnectionTimeout:45 message:@"连接超时，可能尚未确认邀请或网络握手未完成。请查看两端连接日志后重试。"];
    NSData *context = [NSJSONSerialization dataWithJSONObject:@{@"version": @1} options:0 error:nil];
    [self.peerBrowser invitePeer:peer toSession:self.session withContext:context timeout:45];
}
- (void)startConnectionTimeout:(NSTimeInterval)seconds message:(NSString *)message {
    [self.connectionTimer invalidate];
    MCSession *expectedSession = self.session;
    __weak typeof(self) weakSelf = self;
    self.connectionTimer = [NSTimer scheduledTimerWithTimeInterval:seconds repeats:NO block:^(NSTimer *timer) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || self.session != expectedSession) return;
        [self recordConnectionEvent:[@"超时：" stringByAppendingString:message]];
        [self stopConnection];
        self.statusLabel.text = message;
    }];
}
- (void)disconnectBoard {
    [self recordConnectionEvent:@"用户主动断开"];
    [self stopConnection];
    self.statusLabel.text = @"连接已断开，画布保留。可重新创建或加入。";
}
- (void)stopConnection {
    if (self.stoppingConnection) return;
    self.stoppingConnection = YES;
    [self finishStroke];
    self.ready = NO;
    [self.healthTimer invalidate];
    self.healthTimer = nil;
    [self.connectionTimer invalidate];
    self.connectionTimer = nil;
    void (^reply)(BOOL, MCSession *) = self.pendingInvitation;
    self.pendingInvitation = nil;
    if (reply) reply(NO, nil);
    self.invitationPanel.hidden = YES;
    self.acceptedPeer = nil;
    self.advertiser.delegate = nil;
    [self.advertiser stopAdvertisingPeer];
    self.advertiser = nil;
    self.peerBrowser.delegate = nil;
    [self.peerBrowser stopBrowsingForPeers];
    self.peerBrowser = nil;
    [self.nearbyPeers removeAllObjects];
    self.peerScroll.hidden = YES;
    self.session.delegate = nil;
    [self.session disconnect];
    self.session = nil;
    self.stoppingConnection = NO;
}
- (void)enteredBackground {
    [self recordConnectionEvent:@"进入后台，主动释放连接"];
    [self stopConnection];
    self.statusLabel.text = @"已因进入后台断开。画布保留，返回后请重新连接。";
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.boardNavigationController = self.navigationController;
    self.departurePending = NO;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UINavigationController *navigation = self.navigationController ?: self.boardNavigationController;
    BOOL moving = self.isMovingFromParentViewController;
    BOOL dismissing = self.isBeingDismissed;
    BOOL dismissingNavigation = navigation.isBeingDismissed;
    self.departurePending = moving || dismissing || dismissingNavigation;
    if (!self.departurePending) return;
    [self recordConnectionEvent:[NSString stringWithFormat:@"页面转场开始 moving=%d dismissing=%d navigationDismissing=%d，暂不释放连接", moving, dismissing, dismissingNavigation]];
    // 交互式返回可能取消，viewWillDisappear 不能视为已经离开页面。
    id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator ?: navigation.transitionCoordinator;
    __weak typeof(self) weakSelf = self;
    if (coordinator) {
        [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            if (context.isCancelled) {
                self.departurePending = NO;
                [self recordConnectionEvent:@"页面转场已取消，保留当前连接"];
                return;
            }
            [self confirmPageDeparture];
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{ [weakSelf confirmPageDeparture]; });
    }
}
- (void)confirmPageDeparture {
    if (!self.departurePending) return;
    UINavigationController *navigation = self.navigationController ?: self.boardNavigationController;
    BOOL removedFromStack = navigation && ![navigation.viewControllers containsObject:self];
    BOOL detached = !self.parentViewController && !self.viewIfLoaded.window;
    BOOL dismissalFinished = !self.viewIfLoaded.window &&
        (self.isBeingDismissed || navigation.isBeingDismissed);
    if (!removedFromStack && !detached && !dismissalFinished) {
        [self recordConnectionEvent:@"页面仍在导航栈或可见，保留当前连接"];
        return;
    }
    self.departurePending = NO;
    [self recordConnectionEvent:[NSString stringWithFormat:@"确认离开画板 stackRemoved=%d detached=%d dismissalFinished=%d，释放连接", removedFromStack, detached, dismissalFinished]];
    [self stopConnection];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self confirmPageDeparture];
    UIViewController *selected = self.tabBarController.selectedViewController;
    if (selected && selected != self && selected != self.navigationController) {
        [self recordConnectionEvent:@"切换标签页，主动释放连接"];
        [self stopConnection];
    }
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_healthTimer invalidate];
    [_flushTimer invalidate];
    [_connectionTimer invalidate];
    if (_pendingInvitation) _pendingInvitation(NO, nil);
    _advertiser.delegate = nil;
    [_advertiser stopAdvertisingPeer];
    _peerBrowser.delegate = nil;
    [_peerBrowser stopBrowsingForPeers];
    _session.delegate = nil;
    [_session disconnect];
}

#pragma mark - 本地笔迹与可靠传输
- (void)handlePoint:(CGPoint)point state:(UIGestureRecognizerState)state {
    if (!self.host) return;
    if (state == UIGestureRecognizerStateBegan) {
        [self finishStroke];
        self.strokeID = NSUUID.UUID.UUIDString;
        self.lastPoint = point;
        NSArray *widths = @[@4, @9, @18];
        NSDictionary *stroke = @{@"id": self.strokeID, @"color": @(self.colorControl.selectedSegmentIndex),
                                  @"width": widths[self.widthControl.selectedSegmentIndex], @"points": @[@[@(point.x), @(point.y)]]};
        if (![self performOperation:@{@"type": @"begin", @"stroke": stroke}]) {
            self.strokeID = nil;
            [self showMessage:@"画布容量已满，请撤销部分笔迹或清空后继续。"]; return;
        }
        __weak typeof(self) weakSelf = self;
        self.flushTimer = [NSTimer timerWithTimeInterval:1.0 / 30.0 repeats:YES block:^(NSTimer *timer) { [weakSelf flushPoints]; }];
        [[NSRunLoop mainRunLoop] addTimer:self.flushTimer forMode:NSRunLoopCommonModes];
    } else if (self.strokeID) {
        if (hypot(point.x - self.lastPoint.x, point.y - self.lastPoint.y) >= 0.001) {
            if (self.document.pointCount + self.pendingPoints.count >= 20000) {
                [self finishStroke];
                [self showMessage:@"画布容量已满，请撤销部分笔迹或清空后继续。"]; return;
            }
            [self.pendingPoints addObject:@[@(point.x), @(point.y)]];
            self.lastPoint = point;
        }
        if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) [self finishStroke];
    }
}
- (void)flushPoints {
    if (!self.pendingPoints.count || !self.strokeID) return;
    NSArray *points = [self.pendingPoints copy];
    [self.pendingPoints removeAllObjects];
    [self performOperation:@{@"type": @"append", @"id": self.strokeID, @"points": points}];
}
- (void)finishStroke {
    [self.flushTimer invalidate];
    self.flushTimer = nil;
    [self flushPoints];
    self.strokeID = nil;
}
- (BOOL)performOperation:(NSDictionary *)operation {
    NSMutableDictionary *message = [operation mutableCopy];
    message[@"revision"] = @(self.document.revision + 1);
    message[@"version"] = @1;
    if (![self.document applyOperation:message]) return NO;
    [self.canvas setNeedsDisplay];
    self.sentOperations++;
    [self sendMessage:message];
    return YES;
}
- (void)undoStroke {
    if (!self.host) return;
    [self finishStroke];
    [self performOperation:@{@"type": @"undo"}];
}
- (void)clearBoard {
    if (!self.host || !self.document.strokes.count) return;
    [self finishStroke];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"清空画板？" message:@"对方的画面也会清空，此操作无法撤销。" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"清空" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self performOperation:@{@"type": @"clear"}];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)sendMessage:(NSDictionary *)message {
    if (!self.session.connectedPeers.count) return;
    NSData *data = [NSJSONSerialization dataWithJSONObject:message options:0 error:nil];
    NSError *error = nil;
    if (!data || ![self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:&error]) {
        [self recordConnectionEvent:[NSString stringWithFormat:@"发送失败 %@/%ld：%@", error.domain, (long)error.code, error.localizedDescription]];
        [self stopConnection];
        self.statusLabel.text = @"同步失败，画布已保留，请重新连接。";
    }
}


#pragma mark - 同步确认与断流恢复
- (void)startSyncHealthCheck {
    [self.healthTimer invalidate];
    self.lastPeerMessage = NSProcessInfo.processInfo.systemUptime;
    self.lastRepairTime = 0;
    self.lastProgressLog = 0;
    self.sentOperations = 0;
    self.receivedOperations = 0;
    self.peerRevision = 0;
    MCSession *expectedSession = self.session;
    __weak typeof(self) weakSelf = self;
    self.healthTimer = [NSTimer timerWithTimeInterval:2 repeats:YES block:^(NSTimer *timer) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || self.session != expectedSession) { [timer invalidate]; return; }
        [self checkSyncHealth];
    }];
    [[NSRunLoop mainRunLoop] addTimer:self.healthTimer forMode:NSRunLoopCommonModes];
}
- (void)checkSyncHealth {
    if (!self.ready) return;
    NSTimeInterval now = NSProcessInfo.processInfo.systemUptime;
    if (now - self.lastPeerMessage > 20) {
        [self recordConnectionEvent:@"连续20秒未收到对端数据，链路已失去响应，释放会话"];
        [self stopConnection];
        self.statusLabel.text = @"同步连接无响应，画布已保留，请重新创建或加入。";
        return;
    }
    [self sendMessage:@{@"type": @"state", @"version": @1, @"revision": @(self.document.revision)}];
    if (now - self.lastProgressLog >= 10) {
        self.lastProgressLog = now;
        [self recordConnectionEvent:[NSString stringWithFormat:@"同步检查 本地修订=%lu 对端修订=%lu 发送操作=%lu 接收操作=%lu 笔数=%lu 点数=%lu", (unsigned long)self.document.revision, (unsigned long)self.peerRevision, (unsigned long)self.sentOperations, (unsigned long)self.receivedOperations, (unsigned long)self.document.strokes.count, (unsigned long)self.document.pointCount]];
    }
}
- (void)repairSynchronization {
    if (!self.ready) return;
    // 创建端是唯一写入者；正常的短暂传输延迟最多每五秒补偿一次。
    if (!self.host && self.peerRevision <= self.document.revision) return;
    NSTimeInterval now = NSProcessInfo.processInfo.systemUptime;
    if (now - self.lastRepairTime < 5) return;
    self.lastRepairTime = now;
    [self recordConnectionEvent:[NSString stringWithFormat:@"发现修订差异 本地=%lu 对端=%lu，%@", (unsigned long)self.document.revision, (unsigned long)self.peerRevision, self.host ? @"补发完整画布" : @"请求完整画布"]];
    if (self.host) [self sendMessage:self.document.snapshot];
    else [self sendMessage:@{@"type": @"sync", @"version": @1}];
}

#pragma mark - 发现、邀请与会话握手
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (browser != self.peerBrowser || self.host) return;
        if (![info[@"role"] isEqualToString:@"host"] || ![info[@"version"] isEqualToString:@"1"]) return;
        if (![self.nearbyPeers containsObject:peerID]) [self.nearbyPeers addObject:peerID];
        [self recordConnectionEvent:[NSString stringWithFormat:@"发现创建端 %@", peerID.displayName]];
        [self refreshPeerList];
    });
}
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (browser != self.peerBrowser) return;
        [self.nearbyPeers removeObject:peerID];
        [self recordConnectionEvent:[NSString stringWithFormat:@"创建端从发现列表消失 %@（不能据此判断是否主动停止广播）", peerID.displayName]];
        [self refreshPeerList];
    });
}
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (browser != self.peerBrowser) return;
        [self recordConnectionEvent:[NSString stringWithFormat:@"发现失败 %@/%ld：%@", error.domain, (long)error.code, error.localizedDescription]];
        [self stopConnection];
        self.statusLabel.text = @"无法发现附近设备，请检查 Wi-Fi 和本应用的本地网络权限。可复制连接日志查看错误。";
    });
}
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self recordConnectionEvent:[NSString stringWithFormat:@"收到 %@ 的观看邀请", peerID.displayName]];
        if (advertiser != self.advertiser || !self.session || !self.host) {
            [self recordConnectionEvent:@"拒绝邀请：当前不是有效创建会话"];
            invitationHandler(NO, nil); return;
        }
        if (self.acceptedPeer || self.pendingInvitation) {
            [self recordConnectionEvent:@"拒绝邀请：已有观看者或正在确认其他邀请"];
            invitationHandler(NO, nil); return;
        }
        // 邀请作为页面内的持久区域展示，不受系统弹窗和模态呈现时序影响。
        self.acceptedPeer = peerID;
        self.pendingInvitation = invitationHandler;
        self.invitationLabel.text = [NSString stringWithFormat:@"%@ 想观看你的画板", peerID.displayName];
        self.invitationPanel.hidden = NO;
        self.statusLabel.text = @"收到观看邀请，请点击下方「允许观看」或「拒绝」。";
        [self recordConnectionEvent:@"邀请已展示，等待用户确认"];
        [self startConnectionTimeout:30 message:@"观看邀请已过期，请让对方重新加入。"];
    });
}
- (void)acceptInvitation {
    void (^reply)(BOOL, MCSession *) = self.pendingInvitation;
    if (!reply || !self.session || !self.acceptedPeer) return;
    self.pendingInvitation = nil;
    self.invitationPanel.hidden = YES;
    [self recordConnectionEvent:@"用户允许观看，开始建立加密会话"];
    self.statusLabel.text = @"已允许观看，正在建立设备连接…";
    [self startConnectionTimeout:35 message:@"已允许但连接未完成，请让两台设备连接同一 Wi-Fi，并检查 VPN 后重试；可复制两端连接日志。"];
    reply(YES, self.session);
}
- (void)rejectInvitation {
    void (^reply)(BOOL, MCSession *) = self.pendingInvitation;
    self.pendingInvitation = nil;
    self.acceptedPeer = nil;
    self.invitationPanel.hidden = YES;
    [self.connectionTimer invalidate];
    self.connectionTimer = nil;
    [self recordConnectionEvent:@"用户拒绝观看邀请"];
    if (reply) reply(NO, nil);
    self.statusLabel.text = @"已拒绝邀请，继续等待其他设备加入。";
}
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (advertiser != self.advertiser) return;
        [self recordConnectionEvent:[NSString stringWithFormat:@"广播失败 %@/%ld：%@", error.domain, (long)error.code, error.localizedDescription]];
        [self stopConnection];
        self.statusLabel.text = @"无法创建画板，请检查 Wi-Fi 和本应用的本地网络权限。可复制连接日志查看错误。";
    });
}
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (session != self.session) return;
        [self recordConnectionEvent:[NSString stringWithFormat:@"会话状态 %@ → %@", peerID.displayName,
            state == MCSessionStateConnected ? @"已连接" : state == MCSessionStateConnecting ? @"握手中" : @"未连接"]];
        // 迟到或其他设备的回调不能清除正在连接的目标。
        if (![self.acceptedPeer isEqual:peerID]) { [self recordConnectionEvent:@"忽略非当前目标的状态回调"]; return; }
        if (state == MCSessionStateConnected) {
            [self startSyncHealthCheck];
            self.statusLabel.text = @"加密连接已建立，正在同步画布…";
            // 广播端保留到应用层确认，避免两端建立会话回调先后不一致时提前清理。
            [self.peerBrowser stopBrowsingForPeers];
            self.peerScroll.hidden = YES;
            [self startConnectionTimeout:15 message:@"连接成功但画布同步超时，请复制两端连接日志后重新连接。"];
            if (!self.host) {
                self.ready = NO;
                [self recordConnectionEvent:@"请求完整画布"];
                [self sendMessage:@{@"type": @"sync", @"version": @1}];
            }
        } else if (state == MCSessionStateConnecting) {
            self.statusLabel.text = @"正在建立设备间连接，请保持两台设备在前台。";
        } else {
            [self recordConnectionEvent:@"目标会话断开，释放旧会话以便重试"];
            [self stopConnection];
            self.statusLabel.text = @"连接未建立或已断开，画布保留。若使用手机热点或访客 Wi-Fi，请换普通路由器网络重试，并查看连接日志。";
        }
    });
}
- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 仅接受用户明确选择或允许的目标；继续要求链路加密，不做无条件放行。
        BOOL accepted = session == self.session && [self.acceptedPeer isEqual:peerID];
        [self recordConnectionEvent:[NSString stringWithFormat:@"加密证书回调 %@：%@", peerID.displayName, accepted ? @"接受已确认目标" : @"拒绝非目标"]];
        certificateHandler(accepted);
    });
}
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    if (data.length > 2 * 1024 * 1024) return;
    id message = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![message isKindOfClass:NSDictionary.class] || ![message[@"version"] isEqual:@1] || ![message[@"type"] isKindOfClass:NSString.class]) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (session != self.session || ![self.acceptedPeer isEqual:peerID]) return;
        self.lastPeerMessage = NSProcessInfo.processInfo.systemUptime;
        NSString *type = message[@"type"];
        if ([type isEqualToString:@"state"]) {
            NSNumber *revision = message[@"revision"];
            if (![revision isKindOfClass:NSNumber.class] || revision.doubleValue < 0 || revision.doubleValue > 1000000000 || floor(revision.doubleValue) != revision.doubleValue) return;
            self.peerRevision = revision.unsignedIntegerValue;
            if (self.peerRevision != self.document.revision) [self repairSynchronization];
            return;
        }
        if (self.host) {
            if ([type isEqualToString:@"sync"]) {
                [self recordConnectionEvent:@"收到同步请求，发送完整画布"];
                [self sendMessage:self.document.snapshot];
            } else if ([type isEqualToString:@"ready"]) {
                self.ready = YES;
                [self.connectionTimer invalidate]; self.connectionTimer = nil;
                [self.advertiser stopAdvertisingPeer];
                [self recordConnectionEvent:@"对方确认画布已就绪"];
                self.statusLabel.text = @"已连接 · 你画，对方实时观看";
            }
        } else if ([type isEqualToString:@"snapshot"]) {
            self.ready = [self.document loadSnapshot:message];
            if (self.ready) {
                [self.connectionTimer invalidate]; self.connectionTimer = nil;
                [self.canvas setNeedsDisplay];
                [self recordConnectionEvent:@"画布快照已加载，发送就绪确认"];
                self.statusLabel.text = @"画布已同步 · 正在实时观看";
                [self sendMessage:@{@"type": @"ready", @"version": @1}];
            } else {
                [self recordConnectionEvent:@"画布快照校验失败"];
                [self disconnectBoard];
            }
        } else if (self.ready) {
            // 补发快照可能已包含队列中的旧操作，旧修订直接忽略，避免反复重同步。
            if ([message[@"revision"] isKindOfClass:NSNumber.class] && [message[@"revision"] unsignedIntegerValue] <= self.document.revision) return;
            if ([self.document applyOperation:message]) {
                self.receivedOperations++;
                [self.canvas setNeedsDisplay];
            }
            else {
                self.ready = NO;
                self.statusLabel.text = @"正在重新同步画布…";
                [self recordConnectionEvent:@"操作修订号异常，重新请求快照"];
                [self startConnectionTimeout:15 message:@"画布重新同步超时，请重新连接。"];
                [self sendMessage:@{@"type": @"sync", @"version": @1}];
            }
        }
    });
}
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)name fromPeer:(MCPeerID *)peerID { [stream close]; }
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)name fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress { [progress cancel]; }
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)name fromPeer:(MCPeerID *)peerID atURL:(NSURL *)url withError:(NSError *)error {}
@end
