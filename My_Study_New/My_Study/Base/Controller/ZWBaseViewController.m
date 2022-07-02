//
//  BaseViewController.m
//  MainSubControllerDemo
//
//  Created by HZW on 2019/5/22.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "ZWBaseViewController.h"

@interface ZWBaseViewController ()

@end

@implementation ZWBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self initExtendedData];
    }
    
    return self;
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

- (void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
//    self.navigationController.navigationBarHidden = YES;
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




#pragma mark --摇一摇功能 和 LookinServer功能
//让当前控制器成为第一响应者，只有这样才能接收事件，所以此段代码必须加到控制器中
- (BOOL)canBecomeFirstResponder
{
    return YES;// default is NO
}
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"开始摇动手机");
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"结束");
    if (motion == UIEventSubtypeMotionShake) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"Lookin功能列表" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"导出为 Lookin 文档" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Lookin_Export" object:nil];
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"进入 2D 模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Lookin_2D" object:nil];
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"进入 3D 模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Lookin_3D" object:nil];
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"取消");
}



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
    
}

@end
