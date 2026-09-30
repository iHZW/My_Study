//
//  HomeViewController.m
//  MainSubControllerDemo
//
//  Created by HZW on 2019/5/22.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "HomeViewController.h"
// #import <Flutter/Flutter.h>
#import "BlockViewController.h"
#import "HomeDataLoader.h"
#import "HomeRefreshView.h"
#import "HomeViewModel.h"
#import "RunLoopViewController.h"
#import "UIViewController+CWLateralSlide.h"
#import "WFThread.h"
#import <YYCategories/YYCategories.h>
#import <SDWebImage/SDWeakProxy.h>
#import "ZWHomeModel.h"
#import "TestKLineViewController.h"
#import "ZWCommonWebPage.h"

#define kJumpWebViewID      @"kDefaultJumpWebViewID"

static UIColor *CRMHomeColor(NSUInteger hex) {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:1.0];
}

@interface CRMHomeFeatureCell : UITableViewCell
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UILabel *iconLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *detailLabel;
- (void)configureWithTitle:(NSString *)title detail:(NSString *)detail icon:(NSString *)icon;
@end

@implementation CRMHomeFeatureCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = UIColor.clearColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _cardView = [[UIView alloc] init];
        _cardView.backgroundColor = UIColor.whiteColor;
        _cardView.layer.cornerRadius = 16;
        _cardView.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.07].CGColor;
        _cardView.layer.shadowOpacity = 1;
        _cardView.layer.shadowRadius = 10;
        _cardView.layer.shadowOffset = CGSizeMake(0, 4);
        [self.contentView addSubview:_cardView];

        _iconLabel = [[UILabel alloc] init];
        _iconLabel.textAlignment = NSTextAlignmentCenter;
        _iconLabel.font = [UIFont systemFontOfSize:22];
        _iconLabel.backgroundColor = CRMHomeColor(0xE8F3EF);
        _iconLabel.layer.cornerRadius = 13;
        _iconLabel.layer.masksToBounds = YES;
        [_cardView addSubview:_iconLabel];

        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        _nameLabel.textColor = CRMHomeColor(0x294B46);
        [_cardView addSubview:_nameLabel];

        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _detailLabel.textColor = CRMHomeColor(0x82918E);
        [_cardView addSubview:_detailLabel];

        UILabel *arrow = [[UILabel alloc] init];
        arrow.text = @"›";
        arrow.font = [UIFont systemFontOfSize:28 weight:UIFontWeightLight];
        arrow.textColor = CRMHomeColor(0x91AAA5);
        [_cardView addSubview:arrow];

        [_cardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(18);
            make.right.equalTo(self.contentView).offset(-18);
            make.top.equalTo(self.contentView).offset(5);
            make.bottom.equalTo(self.contentView).offset(-5);
        }];
        [_iconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.cardView).offset(14);
            make.centerY.equalTo(self.cardView);
            make.width.height.mas_equalTo(46);
        }];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconLabel.mas_right).offset(13);
            make.right.equalTo(arrow.mas_left).offset(-8);
            make.bottom.equalTo(self.cardView.mas_centerY).offset(-2);
        }];
        [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.nameLabel);
            make.top.equalTo(self.cardView.mas_centerY).offset(4);
        }];
        [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.cardView).offset(-16);
            make.centerY.equalTo(self.cardView);
        }];
    }
    return self;
}

- (void)configureWithTitle:(NSString *)title detail:(NSString *)detail icon:(NSString *)icon {
    self.nameLabel.text = title;
    self.detailLabel.text = detail;
    self.iconLabel.text = icon;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [UIView animateWithDuration:0.15 animations:^{
        self.cardView.transform = highlighted ? CGAffineTransformMakeScale(0.98, 0.98) : CGAffineTransformIdentity;
        self.cardView.alpha = highlighted ? 0.84 : 1.0;
    }];
}

@end

@interface HomeViewController () {
    NSTimer *_timer;
    NSTimer *_yyTimer;
}
@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, assign) int count;

@property (nonatomic, strong) WFThread *wf_thread;

@property (nonatomic, strong) HomeDataLoader *dataLoader;

@property (nonatomic, strong) HomeViewModel *viewModel;
@property (nonatomic, copy) NSArray<NSString *> *featureDetails;
@property (nonatomic, copy) NSArray<NSString *> *featureIcons;
@end

@implementation HomeViewController
#pragma mark - lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p1);

    self.viewModel = [[HomeViewModel alloc] init];

    self.title = @"首页";
    //    if (@available(iOS 7.0, *)) {
    //        // 让导航栏不是渐变色，变成没有穿透效果的纯色
    //        self.edgesForExtendedLayout = UIRectEdgeNone;
    //        self.automaticallyAdjustsScrollViewInsets = NO;
    //    }
    __block int count = 0;
    NSLog(@"%@", @(count));
    //    NSTimer *timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
    //        count++;
    //        NSLog(@"定时器---%d", count);
    //    }];
    //
    //    [timer setFireDate: ];

    //    _yyTimer = [YYTimer timerWithTimeInterval:1 target:self selector:@selector(stop) repeats:YES];
    //    [_yyTimer fire];
    //
    [self initNav];
    [self setupUI];
    [self setupLayout];
    [self setupDatas];

    [self registWaster];

    self.dataLoader = [[HomeDataLoader alloc] init];
}

- (void)registWaster {
    @pas_weakify_self

        [self cw_registerShowIntractiveWithEdgeGesture:NO transitionDirectionAutoBlock:^(CWDrawerTransitionDirection direction) {
            @pas_strongify_self if (direction == CWDrawerTransitionFromLeft) {
                [self gotoLeftDrawerPage];
            }
            else if (direction == CWDrawerTransitionFromRight) {
                [self gotoRightDrawerPage];
            }
        }];
}

- (void)initNav {
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.frame = CGRectMake(0, 0, 38, 38);
    menuButton.backgroundColor = CRMHomeColor(0xE8F3EF);
    menuButton.layer.cornerRadius = 12;
    menuButton.tintColor = CRMHomeColor(0x315F57);
    menuButton.accessibilityLabel = @"打开侧边栏";
    if (@available(iOS 13.0, *)) {
        UIImage *image = [UIImage systemImageNamed:@"line.3.horizontal"];
        [menuButton setImage:image forState:UIControlStateNormal];
    } else {
        [menuButton setTitle:@"☰" forState:UIControlStateNormal];
        [menuButton setTitleColor:CRMHomeColor(0x315F57) forState:UIControlStateNormal];
        menuButton.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
    }
    [menuButton addTarget:self action:@selector(gotoLeftDrawerPage) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];

    [self initRightNav];
}

- (void)initRightNav {
    HomeRefreshView *refreView = [[HomeRefreshView alloc] initWithFrame:CGRectMake(0, 0, 120, 38)];
    //    refreView.viewModel = self.viewModel;
    @pas_weakify_self
        refreView.actinBlock = ^{
        @pas_strongify_self
            [self.viewModel sendReauestForHomeRefresh];
    };

    //    UIButton * refreshBtn = [UIButton buttonWithFrame:CGRectMake(0, 0, 60, 35) title:@"刷新" font:PASBFont(18) titleColor:UIColor.whiteColor block:nil];
    //    refreshBtn.layer.cornerRadius = 8;
    //    refreshBtn.backgroundColor = UIColor.blueColor;
    //
    ////    backBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    ////    [backBtn setImage:[UIImage imageNamed:@"icon_nav_edit"] forState:UIControlStateNormal];
    //    [refreshBtn addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem              = [[UIBarButtonItem alloc] initWithCustomView:refreView];
    self.navigationItem.rightBarButtonItem = leftItem;

    refreView.viewModel = self.viewModel;
}

/**
 * 刷新
 */
- (void)refreshAction {
    [self.dataLoader sendRequestTest:^(NSInteger status, id _Nullable obj) {
        if ([obj isKindOfClass:[ZWHomeModel class]] && status == 1) {
            ZWHomeModel *model = obj;
            NSLog(@"obj = %@", obj);
        }
    }];
}

/* 打开抽屉 */
- (void)gotoLeftDrawerPage {
    [self cw_showDefaultDrawerViewController:[self getLeftDrawerPage]];

    //    [self cw_showDrawerViewController:[self getLeftDrawerPage] animationType:CWDrawerAnimationTypeDefault configuration:nil];
}

- (void)gotoRightDrawerPage {
    CWLateralSlideConfiguration *config = [[CWLateralSlideConfiguration alloc] initWithDistance:kMainScreenWidth * 0.5 maskAlpha:0.4 scaleY:1 direction:CWDrawerTransitionFromRight backImage:nil];
    [self cw_showDrawerViewController:[self getLeftDrawerPage] animationType:CWDrawerAnimationTypeDefault configuration:config];
}

- (ZWBaseViewController *)getLeftDrawerPage {
    ZWBaseViewController *vc           = [[ZWBaseViewController alloc] init];
    vc.title                           = @"抽屉";
    self.view.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p1);
    return vc;
}

- (void)keepAlive {
    NSLog(@"线程保活 currentThread = %@", [NSThread currentThread]);
    //    [[NSRunLoop currentRunLoop] addPort:[NSPort new] forMode:NSDefaultRunLoopMode];
    //    [[NSRunLoop currentRunLoop] run];

    NSLog(@"Game over");
}

- (void)stop {
    NSLog(@"%sm --- %@", __func__, [NSThread currentThread]);
}

- (void)run {
    self.count++;
    NSLog(@"self.count = %d", self.count);
}

- (void)startTimer {
    [_timer invalidate];
    _timer = [NSTimer timerWithTimeInterval:1 target:[SDWeakProxy proxyWithTarget:self] selector:@selector(run) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];

    //    [_yyTimer invalidate];
    //    _yyTimer = [YYTimer timerWithTimeInterval:1 target:self selector:@selector(stop) repeats:YES];
    //    [_yyTimer fire];
}

- (void)endTimer {
    [_timer invalidate];
    _timer = nil;
    //
    //    [_yyTimer invalidate];
    //    _yyTimer = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self startTimer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self endTimer];
}

- (void)setupDatas {
    [self.dataList removeAllObjects];

    [self.dataList addObject:[BaseCellModel modelWithTitle:@"Native 实验室" clazz:[RunLoopViewController class]]];
    [self.dataList addObject:[BaseCellModel modelWithTitle:@"Flutter 首页示例" flutterPageName:@"first"]];
    [self.dataList addObject:[BaseCellModel modelWithTitle:@"混合导航示例" flutterPageName:@"testList"]];
    [self.dataList addObject:[BaseCellModel modelWithTitle:@"跨端链路示例" flutterPageName:@"TestFlutterJumpFlutter"]];
    [self.dataList addObject:[BaseCellModel modelWithTitle:@"Flutter 全站导航" flutterPageName:@"TotalNavigationPage"]];
    [self.dataList addObject:[BaseCellModel modelWithTitle:@"Flutter 测试页" flutterPageName:@"TestPage"]];
    BaseCellModel *model = [BaseCellModel modelWithTitle:@"Block 回调实验" clazz:[BlockViewController class]];
    model.isFlutterPage  = NO;
    [self.dataList addObject:model];
    
    [self.dataList addObject:[BaseCellModel modelWithTitle:@"K 线图表" clazz:NSClassFromString(@"TestKLineViewController")]];
    [self.dataList addObject:[BaseCellModel modelWithTitle:@"RAC 列表绑定" clazz:NSClassFromString(@"RACBindingTableVc")]];
    [self.dataList addObject:[BaseCellModel modelWithTitle:@"RAC MVVM 绑定" clazz:NSClassFromString(@"RACBindingMVVMTableVc")]];
    [self.dataList addObject:[BaseCellModel modelWithTitle:@"本地 HTTP 服务" clazz:NSClassFromString(@"TestKTVCocoaHTTPServerPage")]];
    [self.dataList addObject:[BaseCellModel modelWithTitle:@"协程实验" clazz:NSClassFromString(@"TestCoobjcPage")]];
    
    BaseCellModel *webModel = [BaseCellModel modelWithTitle:@"网页浏览" clazz:NSClassFromString(@"ZWCommonWebPage")];
    webModel.identificationName = kJumpWebViewID;
    [self.dataList addObject:webModel];

    self.featureDetails = @[@"iOS · 线程与 RunLoop", @"跨端 · 基础页面", @"跨端 · Native 与 Flutter", @"跨端 · 多级页面链路", @"跨端 · 统一路由", @"跨端 · 页面容器", @"iOS · 内存与回调", @"图表 · 行情可视化", @"RAC · 响应式列表", @"RAC · MVVM 实践", @"工具 · 设备内服务", @"iOS · 异步编程", @"工具 · WebView"];
    self.featureIcons = @[@"🧪", @"🫧", @"🔀", @"🧩", @"🧭", @"🚀", @"🔗", @"📈", @"⚡️", @"🧱", @"🌐", @"⏱", @"🔎"];

}

- (void)setupUI {
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = CRMHomeColor(0xF4F7F5);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(6, 0, 18, 0);
    self.tableView.tableHeaderView = [self buildHomeHeaderView];
}

- (UIView *)buildHomeHeaderView {
    CGFloat width = CGRectGetWidth(UIScreen.mainScreen.bounds);
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 226)];

    UIView *hero = [[UIView alloc] initWithFrame:CGRectMake(18, 12, width - 36, 142)];
    hero.backgroundColor = CRMHomeColor(0x315F57);
    hero.layer.cornerRadius = 22;
    hero.layer.masksToBounds = YES;
    [header addSubview:hero];

    UIView *decoration = [[UIView alloc] initWithFrame:CGRectMake(width - 142, -34, 128, 128)];
    decoration.backgroundColor = [UIColor colorWithWhite:1 alpha:0.08];
    decoration.layer.cornerRadius = 64;
    [hero addSubview:decoration];

    UILabel *eyebrow = [[UILabel alloc] initWithFrame:CGRectMake(22, 20, 220, 18)];
    eyebrow.text = @"MY STUDY · 探索空间";
    eyebrow.textColor = [UIColor colorWithWhite:1 alpha:0.66];
    eyebrow.font = [UIFont systemFontOfSize:11 weight:UIFontWeightSemibold];
    [hero addSubview:eyebrow];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(22, 45, width - 100, 34)];
    title.text = @"今天想探索什么？";
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont systemFontOfSize:25 weight:UIFontWeightBold];
    [hero addSubview:title];

    UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectMake(22, 86, width - 100, 38)];
    subtitle.text = @"从原生能力到跨端实践，\n把每次尝试都变成可复用的经验。";
    subtitle.numberOfLines = 2;
    subtitle.textColor = [UIColor colorWithWhite:1 alpha:0.82];
    subtitle.font = [UIFont systemFontOfSize:13];
    [hero addSubview:subtitle];

    UILabel *sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 176, width - 40, 26)];
    sectionTitle.text = @"功能实验室";
    sectionTitle.textColor = CRMHomeColor(0x294B46);
    sectionTitle.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    [header addSubview:sectionTitle];

    UILabel *sectionHint = [[UILabel alloc] initWithFrame:CGRectMake(20, 204, width - 40, 16)];
    sectionHint.text = @"选择一个方向，继续你的学习与实验";
    sectionHint.textColor = CRMHomeColor(0x87938F);
    sectionHint.font = [UIFont systemFontOfSize:12];
    [header addSubview:sectionHint];
    return header;
}

- (void)setupLayout {
    //    self.tableView.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight- (kSysStatusBarHeight + kMainNavHeight + kMainTabbarHeight));
}
#pragma mark - actions

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSDictionary *dict = @{@"pageNo": @(1), @"count": @(20)};
    [self sendRequestUrl:kClientChatDetailURL dict:dict];
}

- (void)sendRequestUrl:(NSString *)url dict:(NSDictionary *)dict {
    [ZWM.http requestWithPath:url method:HttpRequestPost paramenters:dict prepareExecute:nil success:^(NSURLSessionDataTask *_Nullable task, id _Nullable responseObject) {

    } failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nullable error){

    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 78;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CRMHomeFeatureCell";
    CRMHomeFeatureCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) cell = [[CRMHomeFeatureCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    BaseCellModel *model = self.dataList[indexPath.row];
    NSString *detail = indexPath.row < self.featureDetails.count ? self.featureDetails[indexPath.row] : @"实用功能";
    NSString *icon = indexPath.row < self.featureIcons.count ? self.featureIcons[indexPath.row] : @"✨";
    [cell configureWithTitle:model.title detail:detail icon:icon];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self testGCD];
//    return;
    /* 点击效果 */
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    BaseCellModel *model = self.dataList[indexPath.row];
    NSString *url        = kClientChatDetailURL;
    switch (indexPath.row) {
        case 0:
            url = kClientChatDetailURL;
            break;
        case 1:
            url = kClientDetailDynamicTab;
            break;
        case 2:
            url = kClueToCustomerPage;
            break;
        case 3:
            url = kClientChatMsgList;
            break;
        default:
            break;
    }
    [self sendRequestUrl:url dict:@{}];

    if ([model.identificationName isEqualToString:kJumpWebViewID]) {
        // 判断是跳转webview的标识
        NSString *webUrl = @"https://equipment.maxwealthfl.com/#/pages/tabBar/home/index";
        if (0) {
            webUrl = @"https://dhuangmi.com/";
        }
        ZWCommonWebPage *webPage = [[ZWCommonWebPage alloc] init];
        [webPage loadUrl:[NSURL URLWithString:webUrl]];
        [self.navigationController pushViewController:webPage animated:YES];
        return;
    }
    
    if (model.isFlutterPage) {
        //        [MyFlutterRouter.sharedRouter openPage:model.flutterPageName params:@{} animated:YES completion:^(BOOL isFinish){}];
        [self jump_flutterPage];
    } else if (model.clazz != nil) {
        if ([model.clazz isKindOfClass:NSClassFromString(@"TestKLineViewController")]) {
            [self.navigationController pushViewController:[NSClassFromString(@"TestKLineViewController") new] animated:YES];
            return;
        }
        ZWBaseViewController *vc    = [model.clazz new];
        vc.hidesBottomBarWhenPushed = YES;
        vc.title                    = model.title;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)jump_flutterPage {
    NewVC *vc = [[NewVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)testGCD {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("1", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t serialQueue     = dispatch_queue_create("2", DISPATCH_QUEUE_SERIAL);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"1");
    });
    //    dispatch_async(serialQueue, ^{
    //        NSLog(@"1");
    //    });
    NSLog(@"2---%@\n\n", @(20 * 89 * 90 * 123 + 1010));
}

#pragma mark - getter && setter
- (NSMutableArray *)dataList {
    if (_dataList == nil) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}
@end

@implementation NewVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p1);

    //    FlutterViewController *flutterVC = [[FlutterViewController alloc] initWithProject:nil nibName:nil bundle:nil];
    //    [self addChildViewController:flutterVC];
    //    flutterVC.view.frame = self.view.bounds;
    //    [flutterVC didMoveToParentViewController:self];
    //    [self.view addSubview:flutterVC.view];
}

@end
