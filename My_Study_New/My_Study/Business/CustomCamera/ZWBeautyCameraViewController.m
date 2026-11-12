#import "ZWBeautyCameraViewController.h"
#import "ZWBeautyCameraEngine.h"
#import <MetalKit/MetalKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>

@interface ZWBeautyToolButton : UIButton
@end
@implementation ZWBeautyToolButton
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    CGFloat icon = MIN(30,self.bounds.size.height-24);
    self.imageView.frame = CGRectMake((width-icon)/2,2,icon,icon);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.titleLabel.frame = CGRectMake(0,icon+6,width,18);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}
@end

@interface ZWBeautyEffectButton : UIButton
@property (nonatomic, strong) UIView *tile;
@property (nonatomic, strong) UIImageView *symbol;
@property (nonatomic, strong) UILabel *caption;
@property (nonatomic, strong) UIView *valueDot;
@property (nonatomic, strong) UIView *selectionRing;
@end
@implementation ZWBeautyEffectButton
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _selectionRing = [UIView new];
        _selectionRing.userInteractionEnabled = NO;
        _selectionRing.layer.cornerRadius = 12;
        _selectionRing.layer.borderWidth = 1.5;
        _selectionRing.layer.borderColor = UIColor.whiteColor.CGColor;
        [self addSubview:_selectionRing];
        _tile = [UIView new];
        _tile.userInteractionEnabled = NO;
        _tile.backgroundColor = [UIColor colorWithWhite:0.17 alpha:1];
        _tile.layer.cornerRadius = 9;
        [self addSubview:_tile];
        _symbol = [UIImageView new];
        _symbol.tintColor = UIColor.whiteColor;
        _symbol.contentMode = UIViewContentModeScaleAspectFit;
        [_tile addSubview:_symbol];
        _caption = [UILabel new];
        _caption.font = [UIFont systemFontOfSize:12];
        _caption.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_caption];
        _valueDot = [UIView new];
        _valueDot.backgroundColor = UIColor.whiteColor;
        _valueDot.layer.cornerRadius = 1.5;
        [self addSubview:_valueDot];
        self.isAccessibilityElement = YES;
        self.accessibilityTraits = UIAccessibilityTraitButton;
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat x = (CGRectGetWidth(self.bounds)-52)/2;
    self.tile.frame = CGRectMake(x,4,52,52);
    self.selectionRing.frame = CGRectMake(x-3,1,58,58);
    self.symbol.frame = CGRectMake(11,11,30,30);
    self.caption.frame = CGRectMake(0,65,CGRectGetWidth(self.bounds),19);
    self.valueDot.frame = CGRectMake(CGRectGetMidX(self.bounds)-1.5,88,3,3);
}
@end

@interface ZWBeautyIntensitySlider : UISlider
@end
@implementation ZWBeautyIntensitySlider
- (CGRect)trackRectForBounds:(CGRect)bounds {
    CGRect track = [super trackRectForBounds:bounds];
    track.origin.y = CGRectGetMidY(bounds)-1.5;
    track.size.height = 3;
    return track;
}
@end

@interface ZWBeautyCameraViewController () <MTKViewDelegate, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) ZWBeautyCameraEngine *engine;
@property (nonatomic, strong) MTKView *preview;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *shutter;
@property (nonatomic, strong) UIButton *flipButton;
@property (nonatomic, strong) UIButton *originalButton;
@property (nonatomic, strong) UISegmentedControl *modeControl;
@property (nonatomic, strong) UISegmentedControl *filterControl;
@property (nonatomic, strong) UIScrollView *beautyEffects;
@property (nonatomic, strong) NSArray<ZWBeautyEffectButton *> *beautyButtons;
@property (nonatomic, strong) UIView *intensityBar;
@property (nonatomic, strong) UISlider *intensitySlider;
@property (nonatomic, strong) UILabel *intensityValue;
@property (nonatomic, strong) UIView *panelDismissArea;
@property (nonatomic, strong) NSMutableDictionary<NSString *,NSNumber *> *beautyValues;
@property (nonatomic) NSInteger selectedBeauty;
@property (nonatomic) BOOL beautyDisabled;
@property (nonatomic, strong) UIView *review;
@property (nonatomic, strong) UIImageView *photoPreview;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) CFTimeInterval recordStart;
@property (nonatomic) BOOL recording;
@property (nonatomic) BOOL busy;
@property (nonatomic) BOOL ready;
@property (nonatomic) BOOL visible;
@property (nonatomic) BOOL navigationWasHidden;
@property (nonatomic) BOOL saving;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *retakeButton;
@property (nonatomic, strong) UIView *captureBar;
@property (nonatomic, strong) UIView *toolRail;
@property (nonatomic, strong) UIView *footer;
@property (nonatomic, strong) UIView *shutterFill;
@property (nonatomic, strong) CAShapeLayer *progressRing;
@property (nonatomic, strong) NSMutableDictionary<NSString *,UIButton *> *toolButtons;
@property (nonatomic, strong) NSMutableSet<NSString *> *hiddenTools;
@property (nonatomic, strong) NSArray<UIButton *> *modeButtons;
@property (nonatomic, strong) UIButton *albumButton;
@property (nonatomic, strong) UIButton *panelCloseButton;
@property (nonatomic, strong) UILabel *panelTitle;
@property (nonatomic, strong) UIScrollView *visibilityPanel;
@property (nonatomic, strong) UILabel *countdownLabel;
@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic) NSInteger countdownSeconds;
@property (nonatomic) NSInteger countdownRemaining;
@property (nonatomic) NSInteger panelMode;
@property (nonatomic) BOOL toolsExpanded;
@property (nonatomic) BOOL navigationStateCaptured;
@property (nonatomic) CGFloat zoom;
@property (nonatomic) CFTimeInterval lastStatusUpdate;
@end

@implementation ZWBeautyCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    self.engine = [ZWBeautyCameraEngine new];
    self.commandQueue = [self.engine.device newCommandQueue];
    self.preview = [[MTKView alloc] initWithFrame:CGRectZero device:self.engine.device];
    self.preview.framebufferOnly = NO;
    self.preview.preferredFramesPerSecond = 30;
    self.preview.enableSetNeedsDisplay = NO;
    self.preview.paused = YES;
    self.preview.delegate = self;
    self.preview.backgroundColor = UIColor.blackColor;
    [self.view addSubview:self.preview];
    self.toolsExpanded = YES;
    self.zoom = 1;
    self.hiddenTools = [NSMutableSet setWithArray:[NSUserDefaults.standardUserDefaults stringArrayForKey:@"ZWBeautyCamera.hiddenTools"] ?: @[]];
    [self buildControls];
    __weak typeof(self) weakSelf = self;
    self.engine.statusHandler = ^(NSString *message, BOOL ready) {
        weakSelf.statusLabel.text = message;
        weakSelf.lastStatusUpdate = CACurrentMediaTime();
        weakSelf.ready = ready;
        [weakSelf updateControls];
    };
    self.engine.recordingHandler = ^(BOOL recording) {
        [weakSelf recordingChanged:recording];
    };
    self.engine.movieHandler = ^(NSURL *url, NSError *error) {
        weakSelf.busy = NO;
        if (error) [weakSelf showMessage:error.localizedDescription];
        else if (weakSelf) {
            weakSelf.videoURL = url;
            [weakSelf showReview];
        } else if (url) {
            [NSFileManager.defaultManager removeItemAtURL:url error:nil];
        }
        [weakSelf updateControls];
    };
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    [center addObserver:self selector:@selector(resignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [center addObserver:self selector:@selector(becomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [center addObserver:self selector:@selector(replayMovie:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.navigationStateCaptured) {
        self.navigationWasHidden = self.navigationController.navigationBarHidden;
        self.navigationStateCaptured = YES;
    }
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.visible = YES;
    [self becomeActive];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.visible = NO;
    [self resignActive];
    [self.navigationController setNavigationBarHidden:self.navigationWasHidden animated:animated];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [_timer invalidate];
    [_countdownTimer invalidate];
    _preview.delegate = nil;
    [_engine stop];
    if (_videoURL) [NSFileManager.defaultManager removeItemAtURL:_videoURL error:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }
- (UIInterfaceOrientationMask)supportedInterfaceOrientations { return UIInterfaceOrientationMaskPortrait; }
- (BOOL)shouldAutorotate { return NO; }

- (UIButton *)button:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    button.accessibilityLabel = title;
    if (action) [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UILabel *)label:(NSString *)title size:(CGFloat)size {
    UILabel *label = [UILabel new];
    label.text = title;
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont systemFontOfSize:size];
    return label;
}

- (UIButton *)tool:(NSString *)title symbol:(NSString *)symbol action:(SEL)action {
    ZWBeautyToolButton *button = [ZWBeautyToolButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    button.tintColor = UIColor.whiteColor;
    button.accessibilityLabel = title;
    if (@available(iOS 13.0,*)) {
        UIImageSymbolConfiguration *configuration = [UIImageSymbolConfiguration configurationWithPointSize:27 weight:UIImageSymbolWeightMedium];
        [button setImage:[UIImage systemImageNamed:symbol withConfiguration:configuration] forState:UIControlStateNormal];
    }
    button.layer.shadowColor = UIColor.blackColor.CGColor;
    button.layer.shadowOpacity = 0.45;
    button.layer.shadowRadius = 3;
    button.layer.shadowOffset = CGSizeMake(0,1);
    if (action) [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (NSArray<NSString *> *)toolOrder {
    return @[@"flip",@"torch",@"settings",@"countdown",@"beauty",@"filter",@"zoom",@"more"];
}

- (void)buildControls {
    self.topBar = [UIView new];
    [self.view addSubview:self.topBar];
    UIButton *close = [self button:@"×" action:@selector(closeCamera)];
    close.titleLabel.font = [UIFont systemFontOfSize:40 weight:UIFontWeightLight];
    close.accessibilityLabel = @"关闭相机";
    close.tag = 101;
    [self.topBar addSubview:close];
    self.timeLabel = [self label:@"● 00:00" size:15];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.hidden = YES;
    self.timeLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.timeLabel.layer.cornerRadius = 18;
    self.timeLabel.clipsToBounds = YES;
    [self.topBar addSubview:self.timeLabel];
    self.toolRail = [UIView new];
    [self.view addSubview:self.toolRail];
    self.toolButtons = [NSMutableDictionary dictionary];
    NSArray *titles = @[@"翻转",@"闪光灯",@"设置",@"倒计时",@"美颜",@"滤镜",@"1×",@"收起"];
    NSArray *symbols = @[@"arrow.triangle.2.circlepath.camera",@"bolt.slash.fill",@"gearshape.fill",@"timer",@"wand.and.stars",@"camera.filters",@"plus.magnifyingglass",@"chevron.up.circle.fill"];
    NSArray *actions = @[@"flipCamera",@"toggleTorch",@"toggleVisibilityPanel",@"chooseCountdown",@"toggleBeautyPanel",@"toggleFilterPanel",@"toggleZoom",@"toggleTools"];
    NSArray *keys = [self toolOrder];
    for (NSUInteger i=0;i<keys.count;i++) {
        UIButton *button = [self tool:titles[i] symbol:symbols[i] action:NSSelectorFromString(actions[i])];
        self.toolButtons[keys[i]] = button;
        [self.toolRail addSubview:button];
    }
    self.flipButton = self.toolButtons[@"flip"];
    self.statusLabel = [self label:@"正在准备相机…" size:12];
    self.statusLabel.numberOfLines = 2;
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.layer.shadowColor = UIColor.blackColor.CGColor;
    self.statusLabel.layer.shadowOpacity = 0.8;
    self.statusLabel.layer.shadowRadius = 3;
    self.statusLabel.layer.shadowOffset = CGSizeMake(0,1);
    [self.view addSubview:self.statusLabel];
    self.captureBar = [UIView new];
    [self.view addSubview:self.captureBar];
    // 分段模式尚未接入，提供真实可用的 15 秒、照片与 60 秒录像。
    self.modeControl = [[UISegmentedControl alloc] initWithItems:@[@"照片",@"15 秒",@"视频"]];
    self.modeControl.selectedSegmentIndex = 0;
    NSMutableArray *modes = [NSMutableArray array];
    NSArray *modeTitles = @[@"15 秒",@"照片",@"视频"];
    NSArray *modeIndexes = @[@1,@0,@2];
    for (NSUInteger i=0;i<3;i++) {
        UIButton *button = [self button:modeTitles[i] action:@selector(selectMode:)];
        button.tag = [modeIndexes[i] integerValue];
        button.layer.cornerRadius = 17;
        [self.captureBar addSubview:button];
        [modes addObject:button];
    }
    self.modeButtons = modes;
    self.shutter = [self button:@"" action:@selector(capture)];
    self.shutter.accessibilityLabel = @"拍照";
    self.shutter.layer.borderWidth = 3;
    self.shutter.layer.borderColor = UIColor.whiteColor.CGColor;
    self.shutter.layer.cornerRadius = 39;
    self.shutterFill = [UIView new];
    self.shutterFill.userInteractionEnabled = NO;
    self.shutterFill.backgroundColor = UIColor.whiteColor;
    [self.shutter addSubview:self.shutterFill];
    self.progressRing = [CAShapeLayer layer];
    self.progressRing.fillColor = UIColor.clearColor.CGColor;
    self.progressRing.strokeColor = [UIColor colorWithRed:1 green:0.2 blue:0.38 alpha:1].CGColor;
    self.progressRing.lineWidth = 4;
    self.progressRing.strokeEnd = 0;
    [self.shutter.layer addSublayer:self.progressRing];
    [self.captureBar addSubview:self.shutter];
    self.originalButton = [self tool:@"按住对比" symbol:@"circle.lefthalf.filled" action:NULL];
    [self.originalButton addTarget:self action:@selector(compareBegin) forControlEvents:UIControlEventTouchDown];
    [self.originalButton addTarget:self action:@selector(compareEnd) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    [self.captureBar addSubview:self.originalButton];
    self.albumButton = [self tool:@"相册" symbol:@"photo.on.rectangle" action:@selector(openAlbum)];
    [self.captureBar addSubview:self.albumButton];
    self.footer = [UIView new];
    self.footer.backgroundColor = UIColor.blackColor;
    UILabel *camera = [self label:@"相机" size:17];
    camera.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    camera.textAlignment = NSTextAlignmentCenter;
    camera.tag = 104;
    [self.footer addSubview:camera];
    [self.view addSubview:self.footer];
    self.panelDismissArea = [UIView new];
    self.panelDismissArea.hidden = YES;
    [self.panelDismissArea addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePanel)]];
    self.panelDismissArea.accessibilityLabel = @"轻点取景区收起面板";
    [self.view addSubview:self.panelDismissArea];
    self.bottomBar = [UIView new];
    self.bottomBar.backgroundColor = [UIColor colorWithWhite:0.085 alpha:1];
    self.bottomBar.layer.cornerRadius = 20;
    if (@available(iOS 11.0,*)) self.bottomBar.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.bottomBar.hidden = YES;
    [self.view addSubview:self.bottomBar];
    self.panelTitle = [self label:@"美颜" size:17];
    self.panelTitle.textAlignment = NSTextAlignmentCenter;
    self.panelTitle.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    [self.bottomBar addSubview:self.panelTitle];
    self.panelCloseButton = [self button:@"完成" action:@selector(closePanel)];
    [self.bottomBar addSubview:self.panelCloseButton];
    self.filterControl = [[UISegmentedControl alloc] initWithItems:@[@"自然",@"清透",@"暖调",@"黑白"]];
    self.filterControl.selectedSegmentIndex = 0;
    self.filterControl.accessibilityLabel = @"滤镜";
    [self.filterControl setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.whiteColor} forState:UIControlStateNormal];
    [self.filterControl setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.blackColor} forState:UIControlStateSelected];
    [self.filterControl addTarget:self action:@selector(settingsChanged) forControlEvents:UIControlEventValueChanged];
    [self.bottomBar addSubview:self.filterControl];
    self.selectedBeauty = NSNotFound;
    self.beautyValues = [@{@"smoothing":@0.65,@"whitening":@0.45,@"rosiness":@0,@"clarity":@0} mutableCopy];
    self.beautyEffects = [UIScrollView new];
    self.beautyEffects.showsHorizontalScrollIndicator = NO;
    self.beautyEffects.alwaysBounceHorizontal = YES;
    [self.bottomBar addSubview:self.beautyEffects];
    NSArray *effectTitles = @[@"无",@"磨皮",@"美白",@"红润",@"清晰"];
    NSArray *effectSymbols = @[@"nosign",@"drop",@"sun.max",@"heart",@"sparkles"];
    NSMutableArray *effects = [NSMutableArray array];
    for (NSUInteger i=0;i<effectTitles.count;i++) {
        ZWBeautyEffectButton *button = [[ZWBeautyEffectButton alloc] initWithFrame:CGRectZero];
        button.caption.text = effectTitles[i];
        button.accessibilityLabel = effectTitles[i];
        button.tag = i;
        if (@available(iOS 13.0,*)) button.symbol.image = [UIImage systemImageNamed:effectSymbols[i] withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:29 weight:UIImageSymbolWeightRegular]];
        else button.tile.accessibilityLabel = effectTitles[i];
        [button addTarget:self action:@selector(selectBeauty:) forControlEvents:UIControlEventTouchUpInside];
        [self.beautyEffects addSubview:button];
        [effects addObject:button];
    }
    self.beautyButtons = effects;
    UIButton *reset = [self button:@"↻ 重置" action:@selector(resetBeauty)];
    reset.titleLabel.font = [UIFont systemFontOfSize:15];
    reset.tag = 105;
    [self.bottomBar addSubview:reset];
    // 强度条位于取景区，不叠在不透明美颜面板内。
    self.intensityBar = [UIView new];
    self.intensityBar.hidden = YES;
    [self.view addSubview:self.intensityBar];
    self.intensitySlider = [[ZWBeautyIntensitySlider alloc] init];
    self.intensitySlider.minimumValue = 0;
    self.intensitySlider.maximumValue = 1;
    self.intensitySlider.minimumTrackTintColor = [UIColor colorWithRed:1 green:0.16 blue:0.37 alpha:1];
    self.intensitySlider.maximumTrackTintColor = [UIColor colorWithWhite:1 alpha:0.4];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(24,24),NO,0);
    [UIColor.whiteColor setFill];
    [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(2,2,20,20)] fill];
    UIImage *thumb = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.intensitySlider setThumbImage:thumb forState:UIControlStateNormal];
    [self.intensitySlider setThumbImage:thumb forState:UIControlStateHighlighted];
    [self.intensitySlider addTarget:self action:@selector(beautyIntensityChanged) forControlEvents:UIControlEventValueChanged];
    [self.intensityBar addSubview:self.intensitySlider];
    self.intensityValue = [self label:@"65" size:14];
    self.intensityValue.textAlignment = NSTextAlignmentCenter;
    self.intensityValue.layer.shadowColor = UIColor.blackColor.CGColor;
    self.intensityValue.layer.shadowOpacity = 0.35;
    self.intensityValue.layer.shadowRadius = 2;
    self.intensityValue.layer.shadowOffset = CGSizeMake(0,1);
    [self.intensityBar addSubview:self.intensityValue];
    [self refreshBeautySelection];
    self.visibilityPanel = [UIScrollView new];
    [self.bottomBar addSubview:self.visibilityPanel];
    NSArray *optionKeys = @[@"flip",@"torch",@"countdown",@"beauty",@"filter",@"zoom",@"compare",@"album",@"footer"];
    NSArray *optionTitles = @[@"翻转镜头",@"闪光灯",@"倒计时",@"美颜",@"滤镜",@"变焦",@"原图对比",@"相册入口",@"底部相机栏"];
    for (NSUInteger i=0;i<optionKeys.count;i++) {
        UILabel *label = [self label:optionTitles[i] size:15];
        label.tag = 200+i;
        [self.visibilityPanel addSubview:label];
        UISwitch *toggle = [UISwitch new];
        toggle.accessibilityIdentifier = optionKeys[i];
        toggle.accessibilityLabel = [@"显示" stringByAppendingString:optionTitles[i]];
        toggle.on = ![self.hiddenTools containsObject:optionKeys[i]];
        toggle.tag = 300+i;
        [toggle addTarget:self action:@selector(visibilityChanged:) forControlEvents:UIControlEventValueChanged];
        [self.visibilityPanel addSubview:toggle];
    }
    UILabel *unavailable = [self label:@"音乐、动图、跟拍、AR 特效和分段拼接未接入，入口已隐藏。" size:12];
    unavailable.numberOfLines = 2;
    unavailable.tag = 400;
    [self.visibilityPanel addSubview:unavailable];
    UIButton *permission = [self button:@"打开系统权限设置" action:@selector(openSettings)];
    permission.tag = 401;
    [self.visibilityPanel addSubview:permission];
    self.countdownLabel = [self label:@"" size:86];
    self.countdownLabel.textAlignment = NSTextAlignmentCenter;
    self.countdownLabel.font = [UIFont systemFontOfSize:86 weight:UIFontWeightSemibold];
    self.countdownLabel.hidden = YES;
    [self.view addSubview:self.countdownLabel];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flipCamera)];
    doubleTap.numberOfTapsRequired = 2;
    [self.preview addGestureRecognizer:doubleTap];
    [self updateControls];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat width = self.view.bounds.size.width, height = self.view.bounds.size.height;
    UIEdgeInsets safe = self.view.safeAreaInsets;
    // 所有操作悬浮在取景画面上，不再挤占预览区域。
    self.preview.frame = self.view.bounds;
    self.engine.outputAspectRatio = width / MAX(1,height);
    self.topBar.frame = CGRectMake(0,0,width,safe.top+58);
    [self.topBar viewWithTag:101].frame = CGRectMake(8,safe.top+4,44,48);
    self.timeLabel.frame = CGRectMake((width-150)/2,safe.top+10,150,36);
    BOOL footerVisible = ![self.hiddenTools containsObject:@"footer"];
    CGFloat footerHeight = footerVisible ? safe.bottom+52 : 0;
    self.footer.hidden = !footerVisible || self.panelMode != 0;
    self.footer.frame = CGRectMake(0,height-footerHeight,width,footerHeight);
    [self.footer viewWithTag:104].frame = CGRectMake(0,6,width,38);
    CGFloat captureHeight = 164;
    self.captureBar.frame = CGRectMake(0,height-footerHeight-captureHeight,width,captureHeight);
    for (NSUInteger i=0;i<self.modeButtons.count;i++) self.modeButtons[i].frame = CGRectMake(width/2-108+i*76,2,64,34);
    self.shutter.frame = CGRectMake((width-78)/2,60,78,78);
    self.shutterFill.frame = self.recording ? CGRectMake(25,25,28,28) : CGRectMake(7,7,64,64);
    self.shutterFill.layer.cornerRadius = self.recording ? 7 : 32;
    self.progressRing.frame = self.shutter.bounds;
    self.progressRing.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(39,39) radius:37 startAngle:-M_PI_2 endAngle:M_PI*1.5 clockwise:YES].CGPath;
    self.originalButton.frame = CGRectMake(width*0.16-30,68,72,64);
    self.albumButton.frame = CGRectMake(width*0.79-30,68,64,64);
    self.originalButton.hidden = [self.hiddenTools containsObject:@"compare"];
    self.albumButton.hidden = [self.hiddenTools containsObject:@"album"];
    self.statusLabel.frame = CGRectMake(30,CGRectGetMinY(self.captureBar.frame)-36,width-90,32);
    self.toolRail.frame = CGRectMake(width-67,safe.top+6,62,MAX(100,CGRectGetMinY(self.statusLabel.frame)-safe.top-12));
    NSMutableArray *visible = [NSMutableArray array];
    for (NSString *key in [self toolOrder]) {
        BOOL always = [key isEqualToString:@"settings"] || [key isEqualToString:@"more"];
        BOOL collapsed = !self.toolsExpanded && ![@[@"flip",@"torch",@"settings",@"more"] containsObject:key];
        UIButton *button = self.toolButtons[key];
        button.hidden = (!always && [self.hiddenTools containsObject:key]) || collapsed;
        if (!button.hidden) [visible addObject:button];
    }
    CGFloat row = MIN(66,CGRectGetHeight(self.toolRail.frame)/MAX(1,visible.count));
    for (NSUInteger i=0;i<visible.count;i++) ((UIButton *)visible[i]).frame = CGRectMake(0,i*row,62,row-3);
    CGFloat panelHeight = self.panelMode == 3 ? MIN(470,height*0.66) : self.panelMode == 1 ? 180+safe.bottom : 210+safe.bottom;
    self.bottomBar.frame = CGRectMake(0,height-panelHeight,width,panelHeight);
    self.panelDismissArea.frame = CGRectMake(0,0,width,height-panelHeight);
    self.panelTitle.frame = CGRectMake(width/2-65,16,130,28);
    self.panelCloseButton.frame = CGRectMake(width-78,10,66,44);
    [self.bottomBar viewWithTag:105].frame = CGRectMake(width-90,10,78,44);
    self.beautyEffects.frame = CGRectMake(0,61,width,110);
    CGFloat itemWidth = 66, gap = 8;
    for (NSUInteger i=0;i<self.beautyButtons.count;i++) self.beautyButtons[i].frame = CGRectMake(16+i*(itemWidth+gap),0,itemWidth,100);
    self.beautyEffects.contentSize = CGSizeMake(32+self.beautyButtons.count*(itemWidth+gap)-gap,110);
    self.intensityBar.frame = CGRectMake(0,height-panelHeight-68,width,62);
    self.intensitySlider.frame = CGRectMake(18,25,width-36,34);
    [self layoutIntensityValue];
    self.filterControl.frame = CGRectMake(24,96,width-48,44);
    self.visibilityPanel.frame = CGRectMake(20,62,width-40,panelHeight-70-safe.bottom);
    for (NSUInteger i=0;i<9;i++) {
        [self.visibilityPanel viewWithTag:200+i].frame = CGRectMake(4,i*48+4,width-130,34);
        [self.visibilityPanel viewWithTag:300+i].frame = CGRectMake(width-103,i*48+5,51,31);
    }
    [self.visibilityPanel viewWithTag:400].frame = CGRectMake(4,444,width-64,50);
    [self.visibilityPanel viewWithTag:401].frame = CGRectMake(4,500,width-64,44);
    self.visibilityPanel.contentSize = CGSizeMake(width-40,554);
    self.countdownLabel.frame = CGRectMake(0,height*0.35,width,120);
    self.review.frame = self.view.bounds;
    self.photoPreview.frame = self.view.bounds;
    self.playerLayer.frame = self.view.bounds;
    self.retakeButton.frame = CGRectMake(24,height-safe.bottom-65,100,48);
    self.saveButton.frame = CGRectMake(width-164,height-safe.bottom-65,140,48);
}

- (void)selectMode:(UIButton *)button {
    self.modeControl.selectedSegmentIndex = button.tag;
    self.engine.maximumDuration = button.tag == 1 ? 15 : 60;
    [self updateControls];
}

- (NSArray<NSString *> *)beautyKeys {
    return @[@"",@"smoothing",@"whitening",@"rosiness",@"clarity"];
}

- (void)showPanel:(NSInteger)mode {
    if (self.recording || self.busy || self.countdownTimer) return;
    self.panelMode = self.panelMode == mode ? 0 : mode;
    self.bottomBar.hidden = self.panelMode == 0;
    self.panelTitle.text = self.panelMode == 1 ? @"美颜" : self.panelMode == 2 ? @"滤镜" : @"界面设置";
    self.beautyEffects.hidden = self.panelMode != 1;
    [self.bottomBar viewWithTag:105].hidden = self.panelMode != 1;
    self.panelCloseButton.hidden = self.panelMode == 1;
    self.filterControl.hidden = self.panelMode != 2;
    self.visibilityPanel.hidden = self.panelMode != 3;
    [self refreshPanelVisibility];
    [self.view setNeedsLayout];
}

- (void)refreshPanelVisibility {
    BOOL open = self.panelMode != 0;
    self.topBar.hidden = open;
    self.toolRail.hidden = open;
    self.captureBar.hidden = open;
    self.statusLabel.hidden = open;
    self.footer.hidden = open || [self.hiddenTools containsObject:@"footer"];
    self.panelDismissArea.hidden = !open;
    self.intensityBar.hidden = self.panelMode != 1 || self.selectedBeauty == NSNotFound || self.selectedBeauty == 0;
}

- (void)toggleBeautyPanel { [self showPanel:1]; }
- (void)toggleFilterPanel { [self showPanel:2]; }
- (void)toggleVisibilityPanel { [self showPanel:3]; }
- (void)closePanel {
    self.panelMode = 0;
    self.bottomBar.hidden = YES;
    [self refreshPanelVisibility];
}

- (void)selectBeauty:(ZWBeautyEffectButton *)button {
    self.selectedBeauty = button.tag;
    self.beautyDisabled = button.tag == 0;
    if (button.tag > 0) {
        NSString *key = [self beautyKeys][button.tag];
        self.intensitySlider.value = self.beautyValues[key].floatValue;
        self.intensitySlider.accessibilityLabel = [button.caption.text stringByAppendingString:@"强度"];
    }
    [self settingsChanged];
    [self refreshBeautySelection];
    [self refreshPanelVisibility];
    [self.view setNeedsLayout];
}

- (void)beautyIntensityChanged {
    if (self.selectedBeauty <= 0 || self.selectedBeauty == NSNotFound) return;
    self.beautyValues[[self beautyKeys][self.selectedBeauty]] = @(self.intensitySlider.value);
    [self settingsChanged];
    [self refreshBeautySelection];
    [self layoutIntensityValue];
}

- (void)layoutIntensityValue {
    CGRect track = [self.intensitySlider trackRectForBounds:self.intensitySlider.bounds];
    CGRect thumb = [self.intensitySlider thumbRectForBounds:self.intensitySlider.bounds trackRect:track value:self.intensitySlider.value];
    CGFloat center = CGRectGetMinX(self.intensitySlider.frame)+CGRectGetMidX(thumb);
    CGFloat width = CGRectGetWidth(self.intensityBar.bounds);
    self.intensityValue.frame = CGRectMake(MAX(8,MIN(width-48,center-20)),0,40,22);
    self.intensityValue.text = [NSString stringWithFormat:@"%ld",(long)lround(self.intensitySlider.value*100)];
    self.intensitySlider.accessibilityValue = self.intensityValue.text;
}

- (void)refreshBeautySelection {
    for (ZWBeautyEffectButton *button in self.beautyButtons) {
        BOOL selected = self.selectedBeauty == button.tag;
        button.selectionRing.hidden = !selected;
        button.caption.textColor = selected ? UIColor.whiteColor : [UIColor colorWithWhite:0.6 alpha:1];
        button.caption.font = [UIFont systemFontOfSize:12 weight:selected ? UIFontWeightSemibold : UIFontWeightRegular];
        button.symbol.alpha = button.tag == 0 && !self.beautyDisabled ? 0.5 : 1;
        button.valueDot.hidden = button.tag == 0 || self.beautyDisabled || self.beautyValues[[self beautyKeys][button.tag]].floatValue <= 0;
        button.accessibilityTraits = UIAccessibilityTraitButton | (selected ? UIAccessibilityTraitSelected : 0);
        button.accessibilityValue = button.tag == 0 ? (self.beautyDisabled ? @"已关闭美颜" : @"关闭美颜") : [NSString stringWithFormat:@"%ld",(long)lround(self.beautyValues[[self beautyKeys][button.tag]].floatValue*100)];
    }
}

- (void)resetBeauty {
    self.beautyValues = [@{@"smoothing":@0.65,@"whitening":@0.45,@"rosiness":@0,@"clarity":@0} mutableCopy];
    self.beautyDisabled = NO;
    if (self.selectedBeauty == 0) self.selectedBeauty = NSNotFound;
    if (self.selectedBeauty != NSNotFound) self.intensitySlider.value = self.beautyValues[[self beautyKeys][self.selectedBeauty]].floatValue;
    [self settingsChanged];
    [self refreshBeautySelection];
    [self refreshPanelVisibility];
    [self layoutIntensityValue];
}
- (void)visibilityChanged:(UISwitch *)toggle {
    NSString *key = toggle.accessibilityIdentifier;
    if (toggle.on) [self.hiddenTools removeObject:key];
    else [self.hiddenTools addObject:key];
    [NSUserDefaults.standardUserDefaults setObject:self.hiddenTools.allObjects forKey:@"ZWBeautyCamera.hiddenTools"];
    [self.view setNeedsLayout];
}
- (void)toggleTools {
    self.toolsExpanded = !self.toolsExpanded;
    [self.toolButtons[@"more"] setTitle:self.toolsExpanded ? @"收起" : @"更多" forState:UIControlStateNormal];
    [self.view setNeedsLayout];
}
- (void)toggleTorch { [self.engine toggleTorch]; }
- (void)toggleZoom {
    self.zoom = self.zoom < 1.5 ? 2 : 1;
    [self.engine setZoom:self.zoom];
    [self.toolButtons[@"zoom"] setTitle:self.zoom < 1.5 ? @"1×" : @"2×" forState:UIControlStateNormal];
}
- (void)chooseCountdown {
    if (self.recording || self.busy || self.countdownTimer) return;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"拍摄倒计时" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSNumber *seconds in @[@0,@3,@10]) {
        NSString *title = seconds.integerValue ? [NSString stringWithFormat:@"%@ 秒",seconds] : @"关闭";
        [alert addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.countdownSeconds = seconds.integerValue;
            [self.toolButtons[@"countdown"] setTitle:seconds.integerValue ? title : @"倒计时" forState:UIControlStateNormal];
        }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    alert.popoverPresentationController.sourceView = self.toolButtons[@"countdown"];
    alert.popoverPresentationController.sourceRect = self.toolButtons[@"countdown"].bounds;
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)settingsChanged {
    self.engine.smoothing = self.beautyDisabled ? 0 : self.beautyValues[@"smoothing"].floatValue;
    self.engine.whitening = self.beautyDisabled ? 0 : self.beautyValues[@"whitening"].floatValue;
    self.engine.rosiness = self.beautyDisabled ? 0 : self.beautyValues[@"rosiness"].floatValue;
    self.engine.clarity = self.beautyDisabled ? 0 : self.beautyValues[@"clarity"].floatValue;
    self.engine.filterIndex = self.filterControl.selectedSegmentIndex;
}

- (void)modeChanged { [self updateControls]; }
- (void)compareBegin { self.engine.original = YES; }
- (void)compareEnd { self.engine.original = NO; }
- (void)flipCamera {
    if (!self.ready || self.recording || self.busy || self.countdownTimer) return;
    self.zoom = 1;
    [self.toolButtons[@"zoom"] setTitle:@"1×" forState:UIControlStateNormal];
    [self.engine switchCamera];
}

- (void)updateControls {
    BOOL idle = !self.busy && !self.recording && !self.review && !self.countdownTimer;
    self.shutter.enabled = self.ready && !self.busy && !self.review && !self.countdownTimer;
    for (NSString *key in self.toolButtons) {
        BOOL cosmetic = [@[@"settings",@"beauty",@"filter",@"countdown",@"more"] containsObject:key];
        self.toolButtons[key].enabled = idle && (cosmetic || self.ready);
    }
    for (UIButton *button in self.modeButtons) {
        button.enabled = idle;
        BOOL selected = button.tag == self.modeControl.selectedSegmentIndex;
        button.backgroundColor = selected ? UIColor.whiteColor : UIColor.clearColor;
        [button setTitleColor:selected ? UIColor.blackColor : UIColor.whiteColor forState:UIControlStateNormal];
    }
    self.filterControl.enabled = idle;
    self.intensitySlider.enabled = idle;
    self.originalButton.enabled = idle;
    self.albumButton.enabled = idle;
    self.shutter.accessibilityLabel = self.recording ? @"停止录制" : self.modeControl.selectedSegmentIndex == 0 ? @"拍照" : @"开始录制";
    self.shutterFill.backgroundColor = self.modeControl.selectedSegmentIndex == 0 ? UIColor.whiteColor : [UIColor colorWithRed:1 green:0.2 blue:0.38 alpha:1];
    self.timeLabel.hidden = !self.recording;
    if (@available(iOS 13.0,*)) {
        [self.toolButtons[@"torch"] setImage:[UIImage systemImageNamed:self.engine.torchEnabled ? @"bolt.fill" : @"bolt.slash.fill"] forState:UIControlStateNormal];
    }
    self.toolRail.alpha = self.recording ? 0 : 1;
    self.originalButton.alpha = self.recording ? 0 : 1;
    self.albumButton.alpha = self.recording ? 0 : 1;
    [self refreshPanelVisibility];
    [self.view setNeedsLayout];
}

- (void)capture {
    if (!self.ready || self.busy || self.review || self.countdownTimer) return;
    [self closePanel];
    if (self.recording || self.countdownSeconds == 0) { [self captureNow]; return; }
    self.countdownRemaining = self.countdownSeconds;
    self.countdownLabel.text = [NSString stringWithFormat:@"%ld",(long)self.countdownRemaining];
    self.countdownLabel.hidden = NO;
    __weak typeof(self) weakSelf = self;
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer *timer) {
        weakSelf.countdownRemaining--;
        if (weakSelf.countdownRemaining <= 0) {
            [weakSelf cancelCountdown];
            [weakSelf captureNow];
        } else weakSelf.countdownLabel.text = [NSString stringWithFormat:@"%ld",(long)weakSelf.countdownRemaining];
    }];
    [self updateControls];
}

- (void)cancelCountdown {
    [self.countdownTimer invalidate];
    self.countdownTimer = nil;
    self.countdownLabel.hidden = YES;
    [self updateControls];
}

- (void)captureNow {
    if (!self.ready || self.busy || self.review) return;
    if (self.modeControl.selectedSegmentIndex != 0) {
        if (self.recording) {
            self.busy = YES;
            [self.engine finishRecording];
        } else {
            [self.engine startRecording];
        }
        [self updateControls];
        return;
    }
    self.busy = YES;
    [self updateControls];
    __weak typeof(self) weakSelf = self;
    [self.engine takePhoto:^(UIImage *image) {
        weakSelf.busy = NO;
        if (image) {
            weakSelf.photo = image;
            [weakSelf showReview];
        } else [weakSelf showMessage:@"画面尚未准备好，请稍后拍摄"];
        [weakSelf updateControls];
    }];
}

- (void)recordingChanged:(BOOL)recording {
    self.recording = recording;
    [self.timer invalidate];
    self.timer = nil;
    if (recording) {
        self.recordStart = CACurrentMediaTime();
        __weak typeof(self) weakSelf = self;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 repeats:YES block:^(NSTimer *timer) {
            NSInteger maximum = (NSInteger)weakSelf.engine.maximumDuration;
            NSInteger seconds = MIN(maximum,(NSInteger)(CACurrentMediaTime()-weakSelf.recordStart));
            weakSelf.timeLabel.text = [NSString stringWithFormat:@"● %02ld:%02ld / %ld 秒",(long)seconds/60,(long)seconds%60,(long)maximum];
            weakSelf.progressRing.strokeEnd = MIN(1,(CACurrentMediaTime()-weakSelf.recordStart)/MAX(1,maximum));
            if (seconds >= maximum) {
                weakSelf.busy = YES;
                [weakSelf.engine finishRecording];
                [timer invalidate];
            }
        }];
        self.timeLabel.text = @"● 00:00";
        self.progressRing.strokeEnd = 0;
        self.statusLabel.text = @"正在录制 · 再次点击停止";
    } else {
        self.busy = YES;
        self.statusLabel.text = @"正在生成美颜视频…";
        self.progressRing.strokeEnd = 0;
    }
    [self updateControls];
}

- (void)resignActive {
    [self cancelCountdown];
    [self compareEnd];
    self.ready = NO;
    self.preview.paused = YES;
    [self.player pause];
    [self.engine stop];
    [self updateControls];
}

- (void)becomeActive {
    if (!self.visible || UIApplication.sharedApplication.applicationState != UIApplicationStateActive) return;
    if (self.review) { [self.player play]; return; }
    if (self.busy) return;
    self.preview.paused = NO;
    [self.engine start];
}

- (void)showReview {
    if (self.review) return;
    self.preview.paused = YES;
    [self.engine stop];
    self.review = [UIView new];
    self.review.backgroundColor = UIColor.blackColor;
    [self.view addSubview:self.review];
    self.photoPreview = [UIImageView new];
    self.photoPreview.contentMode = UIViewContentModeScaleAspectFit;
    self.photoPreview.image = self.photo;
    [self.review addSubview:self.photoPreview];
    if (self.videoURL) {
        self.player = [AVPlayer playerWithURL:self.videoURL];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self.review.layer addSublayer:self.playerLayer];
        if (self.visible && UIApplication.sharedApplication.applicationState == UIApplicationStateActive) [self.player play];
    }
    self.retakeButton = [self button:@"重新拍摄" action:@selector(retake)];
    self.saveButton = [self button:@"保存到相册" action:@selector(saveMedia)];
    self.saveButton.backgroundColor = [UIColor colorWithRed:1 green:0.2 blue:0.38 alpha:1];
    self.saveButton.layer.cornerRadius = 24;
    self.retakeButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.retakeButton.layer.cornerRadius = 24;
    [self.review addSubview:self.retakeButton];
    [self.review addSubview:self.saveButton];
    [self.view setNeedsLayout];
    [self updateControls];
}

- (void)replayMovie:(NSNotification *)note {
    if (note.object != self.player.currentItem || !self.visible || UIApplication.sharedApplication.applicationState != UIApplicationStateActive) return;
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

- (void)retake {
    if (self.saving) return;
    [self.player pause];
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    self.player = nil;
    [self.review removeFromSuperview];
    self.review = nil;
    self.photoPreview = nil;
    self.photo = nil;
    if (self.videoURL) [NSFileManager.defaultManager removeItemAtURL:self.videoURL error:nil];
    self.videoURL = nil;
    self.busy = NO;
    self.statusLabel.text = @"正在准备相机…";
    [self becomeActive];
    [self updateControls];
}

- (void)saveMedia {
    if (self.saving || (!self.photo && !self.videoURL)) return;
    self.saving = YES;
    self.saveButton.enabled = NO;
    self.retakeButton.enabled = NO;
    [self.player pause];
    __weak typeof(self) weakSelf = self;
    void (^authorized)(PHAuthorizationStatus) = ^(PHAuthorizationStatus status) {
        BOOL allowed = status == PHAuthorizationStatusAuthorized;
        if (@available(iOS 14.0,*)) allowed = allowed || status == PHAuthorizationStatusLimited;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!allowed) {
                [weakSelf saveFinished:NO message:@"相册写入未授权，请在系统设置中允许添加照片"];
                return;
            }
            UIImage *photo = weakSelf.photo;
            NSURL *url = weakSelf.videoURL;
            if (!photo && !url) return;
            [PHPhotoLibrary.sharedPhotoLibrary performChanges:^{
                if (photo) [PHAssetChangeRequest creationRequestForAssetFromImage:photo];
                else [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
            } completionHandler:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf saveFinished:success message:success ? @"已保存到系统相册" : error.localizedDescription ?: @"保存失败，请重试"];
                });
            }];
        });
    };
    if (@available(iOS 14.0,*)) [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly handler:authorized];
    else [PHPhotoLibrary requestAuthorization:authorized];
}

- (void)saveFinished:(BOOL)success message:(NSString *)message {
    self.saving = NO;
    self.retakeButton.enabled = YES;
    self.saveButton.enabled = !success;
    if (success) [self.saveButton setTitle:@"已保存" forState:UIControlStateNormal];
    [self showMessage:message];
}

- (void)showMessage:(NSString *)message {
    self.statusLabel.text = message;
    if (!self.visible || UIApplication.sharedApplication.applicationState != UIApplicationStateActive || self.presentedViewController) return;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"美颜相机" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)openSettings {
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
}

- (void)openAlbum {
    if (self.recording || self.busy || self.countdownTimer) return;
    [self closePanel];
    [self.engine stop];
    self.preview.paused = YES;
    if (@available(iOS 14.0,*)) {
        // 系统选择器只授予用户选中的文件，不申请读取整本相册。
        PHPickerConfiguration *configuration = [[PHPickerConfiguration alloc] initWithPhotoLibrary:PHPhotoLibrary.sharedPhotoLibrary];
        configuration.selectionLimit = 1;
        configuration.filter = [PHPickerFilter anyFilterMatchingSubfilters:@[PHPickerFilter.imagesFilter,PHPickerFilter.videosFilter]];
        PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:configuration];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        UIImagePickerController *picker = [UIImagePickerController new];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = @[@"public.image",@"public.movie"];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results API_AVAILABLE(ios(14)) {
    NSItemProvider *provider = results.firstObject.itemProvider;
    self.busy = provider != nil;
    [picker dismissViewControllerAnimated:YES completion:^{
        if (!provider) [self becomeActive];
    }];
    [self updateControls];
    if (!provider) return;
    __weak typeof(self) weakSelf = self;
    if ([provider hasItemConformingToTypeIdentifier:@"public.movie"]) {
        [provider loadFileRepresentationForTypeIdentifier:@"public.movie" completionHandler:^(NSURL *url, NSError *error) {
            NSURL *destination = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"beauty-import-%@.%@",NSUUID.UUID.UUIDString,url.pathExtension.length ? url.pathExtension : @"mov"]]];
            NSError *copyError = error;
            BOOL success = url && [NSFileManager.defaultManager copyItemAtURL:url toURL:destination error:&copyError];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.busy = NO;
                if (success && weakSelf) {
                    weakSelf.videoURL = destination;
                    [weakSelf showReview];
                } else {
                    [NSFileManager.defaultManager removeItemAtURL:destination error:nil];
                    [weakSelf becomeActive];
                    [weakSelf showMessage:copyError.localizedDescription ?: @"视频读取失败"];
                }
                [weakSelf updateControls];
            });
        }];
    } else {
        [provider loadObjectOfClass:UIImage.class completionHandler:^(__kindof id<NSItemProviderReading> object, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.busy = NO;
                if ([(id)object isKindOfClass:UIImage.class]) {
                    weakSelf.photo = (UIImage *)object;
                    [weakSelf showReview];
                } else {
                    [weakSelf becomeActive];
                    [weakSelf showMessage:error.localizedDescription ?: @"照片读取失败"];
                }
                [weakSelf updateControls];
            });
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{ [self becomeActive]; }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *photo = info[UIImagePickerControllerOriginalImage];
    NSURL *source = info[UIImagePickerControllerMediaURL];
    NSError *error = nil;
    NSURL *destination = source ? [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"beauty-import-%@.%@",NSUUID.UUID.UUIDString,source.pathExtension]]] : nil;
    BOOL copied = source && [NSFileManager.defaultManager copyItemAtURL:source toURL:destination error:&error];
    self.photo = photo;
    self.videoURL = copied ? destination : nil;
    [picker dismissViewControllerAnimated:YES completion:^{
        if (self.photo || self.videoURL) [self showReview];
        else { [self becomeActive]; [self showMessage:error.localizedDescription ?: @"作品读取失败"]; }
    }];
}

- (void)closeCamera {
    [self cancelCountdown];
    if (self.recording || self.busy || self.saving) {
        [self showMessage:@"请先停止录制，并等待作品处理完成"];
        return;
    }
    if (self.navigationController) [self.navigationController popViewControllerAnimated:YES];
    else [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)drawInMTKView:(MTKView *)view {
    @autoreleasepool {
        CIImage *image = self.engine.previewImage;
        if (self.ready && !self.recording && !self.busy && CACurrentMediaTime()-self.lastStatusUpdate > 4) {
            self.statusLabel.text = self.engine.detectedFaceCount ? @"人脸美颜已开启 · 按住对比查看原图" : @"肤色美颜已开启 · 正对镜头效果更佳";
            self.lastStatusUpdate = CACurrentMediaTime();
        }
        if (!image || view.drawableSize.width <= 0 || view.drawableSize.height <= 0) return;
        id<CAMetalDrawable> drawable = view.currentDrawable;
        if (!drawable) return;
        // 采集端已按屏幕比例裁切，铺满预览，照片与视频使用同一画幅。
        CGRect bounds = CGRectMake(0,0,view.drawableSize.width,view.drawableSize.height);
        CGFloat scale = MAX(bounds.size.width/image.extent.size.width,bounds.size.height/image.extent.size.height);
        CIImage *scaled = [image imageByApplyingTransform:CGAffineTransformMakeScale(scale,scale)];
        scaled = [scaled imageByApplyingTransform:CGAffineTransformMakeTranslation((bounds.size.width-scaled.extent.size.width)/2,(bounds.size.height-scaled.extent.size.height)/2)];
        CIImage *background = [[CIImage imageWithColor:[CIColor colorWithRed:0 green:0 blue:0 alpha:1]] imageByCroppingToRect:bounds];
        CIImage *composite = [scaled imageByCompositingOverImage:background];
        id<MTLCommandBuffer> command = [self.commandQueue commandBuffer];
        CGColorSpaceRef color = CGColorSpaceCreateDeviceRGB();
        [self.engine.context render:composite toMTLTexture:drawable.texture commandBuffer:command bounds:bounds colorSpace:color];
        CGColorSpaceRelease(color);
        [command presentDrawable:drawable];
        [command commit];
    }
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {}
@end
