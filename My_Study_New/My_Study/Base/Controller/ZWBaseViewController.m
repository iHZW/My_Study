//
//  BaseViewController.m
//  MainSubControllerDemo
//
//  Created by HZW on 2019/5/22.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "ZWBaseViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

@interface ZWBaseViewController ()

@property (nonatomic, strong) UIButton *closeBtn;

@end

@implementation ZWBaseViewController

+ (NSString *)pageName{
    NSString *pageName = [NSStringFromClass(self) stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];
    return pageName;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self initExtendedData];
//        self.pop
    }
    
    return self;
}

- (void)initCloseBtn
{
    [self.view addSubview:self.closeBtn];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 40));
        make.left.equalTo(self.view.mas_left).offset(20);
        make.top.equalTo(self.view.mas_top).offset(kSysStatusBarHeight);
    }];
    
    [self.view bringSubviewToFront:self.closeBtn];
}

- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"top_icon_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}


/** 内存告警  */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    if ([self isViewLoaded] && self.view.window == nil)
    {
        [self receiveLowMemoryWarning];
        self.view = nil;
//        [[CMNetLayerNotificationCenter defaultCenter] removeObserver:self];
//        [[CMNotificationCenter defaultCenter] removeObserver:self];
    }
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p1);
    
    /* 默认加载 */
    if (!self.isRootPage) {
        [self initLeftNav];
        [self initRightNav];
    }
    
    NSDictionary *dict = [[self class] ss_constantParams];
    NSInteger navBarStyle = [[dict objectForKey:@"navbarStyle"] integerValue];
    if (navBarStyle == NavbarStyleNone){
        self.navBarShadowImage = [UIImage new];
    } else if (navBarStyle == NavbarStyleLine){
        self.navBarShadowImage = nil;
    }
    
    if (@available(iOS 11.0, *)) {
//        self.scrVc.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self decodeRouterParams:self.routerParams];
    [self loadUIData];
}




/* 初始化导航 */
- (void)initLeftNav{
    UIButton * backBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 40, 40, 40)];
    backBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [backBtn setImage:[UIImage imageNamed:@"icon_nav_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    backBtn.titleLabel.font = PASFont(15);
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)initRightNav
{
    
}

/** 返回按钮  */
- (void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
//    self.navigationController.navigationBarHidden = YES;
}

/** 关闭按钮  */
- (void)closeAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view setNeedsLayout];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

/**
 *  判断该viewcontroller当前是否是可见的，用来在app从后台启前台的时候决定要不要刷新数据或者view
 *
 *  @return 可见YES, 否则NO
 */
- (BOOL)isVisible
{
    return (self.isViewLoaded && self.view.window);
}



#pragma mark --摇一摇功能 和 LookinServer功能
//让当前控制器成为第一响应者，只有这样才能接收事件，所以此段代码必须加到控制器中
//- (BOOL)canBecomeFirstResponder
//{
//    return NO;// default is NO
//}
//- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
//{
//    NSLog(@"开始摇动手机");
//}
//
//-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
//    NSLog(@"结束");
//    if (motion == UIEventSubtypeMotionShake) {
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"Lookin功能列表" preferredStyle:UIAlertControllerStyleAlert];
//
//        [alert addAction:[UIAlertAction actionWithTitle:@"导出为 Lookin 文档" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"Lookin_Export" object:nil];
//        }]];
//
//        [alert addAction:[UIAlertAction actionWithTitle:@"进入 2D 模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"Lookin_2D" object:nil];
//        }]];
//
//        [alert addAction:[UIAlertAction actionWithTitle:@"进入 3D 模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"Lookin_3D" object:nil];
//        }]];
//
//        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
//        [self presentViewController:alert animated:YES completion:nil];
//    }
//}
//- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
//{
//    NSLog(@"取消");
//}



#pragma mark - Public's methods
/**
 *  扩展的初始化数据(子类继承时,子类初始化数据处理可在此函数中进行数据初始化)
 */
- (void)initExtendedData
{
    
}

/**
 *  界面加载(子类继承时,子类扩展界面加载可在此函数中进行处理)
 */
- (void)loadUIData
{
    
}

/**
 *  内存告警调用(子类继承时,子类收到内存告警时可在此函数中进行处理)
 */
- (void)receiveLowMemoryWarning
{
    NSLog(@"内存告警");
}


/** 解析路由  */
- (void)decodeRouterParams:(NSDictionary *)routerParams{
    //各个页面自己解析
    if (routerParams){
        if ([routerParams.allKeys containsObject:@"hideNavigationBar"]){
            self.hideNavigationBar = [[routerParams objectForKey:@"hideNavigationBar"] boolValue];
        }
    }
}

/** 默认不支持旋转  */
- (BOOL)shouldAutorotate
{
    return YES;
}

/** 默认竖屏  */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

/** 默认竖屏  */
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
