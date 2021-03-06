//
//  HomeViewController.m
//  MainSubControllerDemo
//
//  Created by HZW on 2019/5/22.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "HomeViewController.h"
#import <Flutter/Flutter.h>


@interface HomeViewController ()
@property(nonatomic, strong) NSMutableArray *dataList;
@end

@implementation HomeViewController
#pragma mark - lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"首页";
//    if (@available(iOS 7.0, *)) {
//        // 让导航栏不是渐变色，变成没有穿透效果的纯色
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        self.automaticallyAdjustsScrollViewInsets = NO;
//    }
    [self setupUI];
    [self setupLayout];
    [self setupDatas];
}
- (void)setupDatas
{
    [self.dataList addObject:[BaseCellModel modelWithTitle:@"跳转到Native页面" clazz:[BaseViewController class]]];
    [self.dataList addObject:[BaseCellModel modelWithTitle:@"Native->Flutter-first" flutterPageName:@"first"]];
    [self.dataList addObject:[BaseCellModel modelWithTitle:@"Native->Native(Flutter)-Native(flutter)" flutterPageName:@"testList"]];
    [self.dataList addObject:[BaseCellModel modelWithTitle:@"Native-Native(Flutter)-Flutter-Native(Flutter)" flutterPageName:@"TestFlutterJumpFlutter"]];
    [self.dataList addObject:[BaseCellModel modelWithTitle:@"Native-Flutter(全站导航)" flutterPageName:@"TotalNavigationPage"]];
    [self.dataList addObject:[BaseCellModel modelWithTitle:@"Native jump Flutter" flutterPageName:@"TestPage"]];
    
}
- (void)setupUI
{
    [self.view addSubview:self.tableView];
}
- (void)setupLayout
{
    self.tableView.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight - kMainNavHeight);
}
#pragma mark - actions

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell cellFromCodeWithTableView:tableView];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    BaseCellModel *model = self.dataList[indexPath.row];
    cell.textLabel.text = model.title;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    });
//    BaseCellModel *model = self.dataList[indexPath.row];
//    if(model.isFlutterPage){
////        [MyFlutterRouter.sharedRouter openPage:model.flutterPageName params:@{} animated:YES completion:^(BOOL isFinish){}];
//    }else if(model.clazz != nil){
//        UIViewController *vc = [model.clazz new];
//        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:YES];
//    }

    [self jump_flutterPage];
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
    
    self.view.backgroundColor = [UIColor whiteColor];
    FlutterViewController *flutterVC = [[FlutterViewController alloc] initWithProject:nil nibName:nil bundle:nil];
    [self addChildViewController:flutterVC];
    flutterVC.view.frame = self.view.bounds;
    [flutterVC didMoveToParentViewController:self];
    [self.view addSubview:flutterVC.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBar.hidden = NO;
}

@end
