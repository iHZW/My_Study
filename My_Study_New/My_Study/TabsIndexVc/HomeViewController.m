//
//  HomeViewController.m
//  MainSubControllerDemo
//
//  Created by HZW on 2019/5/22.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "HomeViewController.h"
//#import <Flutter/Flutter.h>
#import "BlockViewController.h"
#import "YYKit.h"
#import "WFThread.h"
#import "RunLoopViewController.h"
#import "UIViewController+CWLateralSlide.h"


@interface HomeViewController ()
{
    NSTimer *_timer;
    YYTimer *_yyTimer;
}
@property(nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, assign) int count;

@property (nonatomic, strong) WFThread *wf_thread;
@end

@implementation HomeViewController
#pragma mark - lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p1);

    self.title = @"首页";
//    if (@available(iOS 7.0, *)) {
//        // 让导航栏不是渐变色，变成没有穿透效果的纯色
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        self.automaticallyAdjustsScrollViewInsets = NO;
//    }
    __block int count = 0;
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

}

- (void)registWaster
{
    @pas_weakify_self
    [self cw_registerShowIntractiveWithEdgeGesture:NO transitionDirectionAutoBlock:^(CWDrawerTransitionDirection direction) {
        @pas_strongify_self
        if (direction == CWDrawerTransitionFromLeft) {
            [self gotoLeftDrawerPage];
        } else if (direction == CWDrawerTransitionFromRight) {
            [self gotoRightDrawerPage];
        }
    }];
}

- (void)initNav
{
    UIButton * backBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 40, 40, 40)];
    backBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [backBtn setImage:[UIImage imageNamed:@"icon_nav_edit"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(gotoLeftDrawerPage) forControlEvents:UIControlEventTouchUpInside];
    backBtn.titleLabel.font = PASFont(15);
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

/* 打开抽屉 */
- (void)gotoLeftDrawerPage
{
    [self cw_showDefaultDrawerViewController:[self getLeftDrawerPage]];
//    [self cw_showDrawerViewController:[self getLeftDrawerPage] animationType:CWDrawerAnimationTypeDefault configuration:nil];
}

- (void)gotoRightDrawerPage
{
    CWLateralSlideConfiguration *config = [[CWLateralSlideConfiguration alloc] initWithDistance:kMainScreenWidth * 0.5 maskAlpha:0.4 scaleY:1 direction:CWDrawerTransitionFromRight backImage:nil];
    [self cw_showDrawerViewController:[self getLeftDrawerPage] animationType:CWDrawerAnimationTypeDefault configuration:config];
}

- (ZWBaseViewController *)getLeftDrawerPage
{
    ZWBaseViewController *vc = [[ZWBaseViewController alloc] init];
    vc.title = @"抽屉";
    self.view.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p1);
    return vc;
}

- (void)keepAlive
{
    NSLog(@"线程保活 currentThread = %@", [NSThread currentThread]);
//    [[NSRunLoop currentRunLoop] addPort:[NSPort new] forMode:NSDefaultRunLoopMode];
//    [[NSRunLoop currentRunLoop] run];

    NSLog(@"Game over");
}


- (void)stop{
    NSLog(@"%sm --- %@", __func__, [NSThread currentThread]);
}

- (void)run
{
    self.count++;
    NSLog(@"self.count = %d", self.count);
}

- (void)startTimer{
    [_timer invalidate];
    _timer = [NSTimer timerWithTimeInterval:1 target:[YYWeakProxy proxyWithTarget:self] selector:@selector(run) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    
//    [_yyTimer invalidate];
//    _yyTimer = [YYTimer timerWithTimeInterval:1 target:self selector:@selector(stop) repeats:YES];
//    [_yyTimer fire];
}

- (void)endTimer{
    
    [_timer invalidate];
    _timer = nil;
//
//    [_yyTimer invalidate];
//    _yyTimer = nil;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self startTimer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self endTimer];
}


- (void)setupDatas
{
    [self.dataList addObject:[BaseCellModel modelWithTitle:@"跳转到Native页面" clazz:[RunLoopViewController class]]];
    [self.dataList addObject:[BaseCellModel modelWithTitle:@"Native->Flutter-first" flutterPageName:@"first"]];
    [self.dataList addObject:[BaseCellModel modelWithTitle:@"Native->Native(Flutter)-Native(flutter)" flutterPageName:@"testList"]];
    [self.dataList addObject:[BaseCellModel modelWithTitle:@"Native-Native(Flutter)-Flutter-Native(Flutter)" flutterPageName:@"TestFlutterJumpFlutter"]];
    [self.dataList addObject:[BaseCellModel modelWithTitle:@"Native-Flutter(全站导航)" flutterPageName:@"TotalNavigationPage"]];
    [self.dataList addObject:[BaseCellModel modelWithTitle:@"Native jump Flutter" flutterPageName:@"TestPage"]];
    BaseCellModel *model = [BaseCellModel modelWithTitle:@"跳转到Block测试页面" clazz:[BlockViewController class]];
    model.isFlutterPage = NO;
    [self.dataList addObject:model];
}
- (void)setupUI
{
    [self.view addSubview:self.tableView];

    /* 头部导航   底部tabBar */
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(SafeAreaTopStatusNavBarHeight);
        make.bottom.equalTo(self.view.mas_bottom).offset(-kMainTabbarHeight-SafeAreaBottomAreaHeight);
    }];
}
- (void)setupLayout
{
//    self.tableView.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight- (kSysStatusBarHeight + kMainNavHeight + kMainTabbarHeight));
}
#pragma mark - actions

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    NSDictionary *dict = @{@"pageNo": @(1), @"count" : @(20)};
    [self sendRequestUrl:kClientChatDetailURL dict:dict];
}

- (void)sendRequestUrl:(NSString *)url dict:(NSDictionary *)dict
{
    [ZWM.http requestWithPath:url method:HttpRequestPost paramenters:dict prepareExecute:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
 
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
            
        }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell cellFromCodeWithTableView:tableView];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    BaseCellModel *model = self.dataList[indexPath.row];
    cell.textLabel.text = model.title;
    cell.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p8);
    cell.textLabel.zh_textColorPicker = ThemePickerColorKey(ZWColorKey_p4);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* 点击效果 */
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    BaseCellModel *model = self.dataList[indexPath.row];
    NSString *url = kClientChatDetailURL;
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
    
    
    if(model.isFlutterPage){
//        [MyFlutterRouter.sharedRouter openPage:model.flutterPageName params:@{} animated:YES completion:^(BOOL isFinish){}];
        [self jump_flutterPage];
    }else if(model.clazz != nil){
        ZWBaseViewController *vc = [model.clazz new];
        vc.hidesBottomBarWhenPushed = YES;
        vc.title = model.title;
        [self.navigationController pushViewController:vc animated:YES];
    }

}

- (void)jump_flutterPage
{
    NewVC *vc = [[NewVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - getter && setter
- (NSMutableArray *)dataList
{
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
