//
//  PersonalViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "PersonalViewController.h"
#import "ZWBaseTableView.h"
#import "PersonalCenterConfig.h"
#import "ZWViewControllerAdapter.h"
#import "ZWTableViewAdapter.h"
#import "ZWRefreshHeader.h"
#import "ZWBaseTableViewCell.h"
#import "GCDCommon.h"
#import "LoadingUtil.h"

NSString  * const context = @"user center context";

NSString * const observerKeyPath = @"reloadTableView";

NSString * const contentOffsetKeyPath = @"contentOffset";


#define BackgroundImageHeight 215.0f

@interface PersonalViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) ZWBaseTableView *tableView;

@property (nonatomic, strong) NSMutableArray *modules;

@property (nonatomic, strong) NSMutableDictionary *modulesObjectMap;

@property (nonatomic, strong) NSMutableDictionary *modulesViewDidLoadMap;

@end

@implementation PersonalViewController

- (void)dealloc
{
    [self.tableView removeObserver:self forKeyPath:contentOffsetKeyPath];
    [self.modules enumerateObjectsUsingBlock:^(NSObject *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeObserver:self forKeyPath:observerKeyPath];
    }];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initWithModulesNames:[PersonalCenterConfig allModulesNameMap]];
    }
    return self;
}

#pragma mark - modules init and config
- (void)initWithModulesNames:(NSDictionary *)namesMap
{
    [namesMap enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, NSString *  _Nonnull className, BOOL * _Nonnull stop) {
        Class class = NSClassFromString(className);
        if (class && [class conformsToProtocol:@protocol(ZWTableViewAdapter)]) {
            id<ZWTableViewAdapter> module = [[class alloc] initWithData:nil];
            [self.modulesObjectMap setObject:module forKey:key];
        }
    }];
}

- (NSString *)moduleClassName:(NSObject *)obj
{
    return NSStringFromClass([obj class]);
}

- (void)configModule:(id<ZWTableViewAdapter>)module
{
    module.reloadTableView = NO;
    [(NSObject *)module addObserver:self forKeyPath:observerKeyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:(void *)context];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:observerKeyPath]) {
        BOOL value = [change[@"new"] boolValue];
        if (value) {
            [self.tableView reloadData];
            [self.tableView layoutIfNeeded];
        }
    } else if ([keyPath isEqualToString:contentOffsetKeyPath]) {
        
        CGPoint point =  [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
//        if (point.y + CGRectGetHeight(self.bgImageView.frame) < 0.0) {
//            self.bgImageView.mj_h = -point.y;
//        } else if (point.y > -0.00001 && point.y < 0.00001){
//            self.bgImageView.mj_h = kMainScreenHeight/4;
//        }
//        NSLog(@"back Image frame:%@", NSStringFromCGRect(self.bgImageView.frame));
//        NSLog(@"contentOffset point:%@", NSStringFromCGPoint(point));
        if (point.y < 0) {
            // 会偏移-StatusBarHeight
//            self.bgImageView.mj_h = kSysStatusBarHeight + BackgroundImageHeight - point.y;
        } else if (point.y < BackgroundImageHeight) {
//            self.bgImageView.mj_h = kSysStatusBarHeight + BackgroundImageHeight - point.y;
        } else {
//            self.bgImageView.mj_h = 0;
        }
        if (point.y + kSysStatusBarHeight < 0) {
//            self.navigationViewModel.view.hidden = YES;
        } else {
//            self.navigationViewModel.view.hidden = NO;
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - UIViewContorller life circle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"个人中心";
    
    self.navigationController.navigationBar.hidden = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = UIColorFromRGB(0xF2F2F2);
    
    [self loadSubViews];
}

- (void)loadSubViews
{
    [self.view addSubview:self.tableView];
    
    /** 设置刷新头  */
    @pas_weakify_self
    ZWRefreshHeader *refreshHeader = [ZWRefreshHeader headerWithRefreshingBlock:^{
        @pas_strongify_self
        [self pullRefresh];
    }];
    refreshHeader.offsetY = -kSysStatusBarHeight/2;
    self.tableView.mj_header = refreshHeader;
    
    /** 监听tableView的 contentOffset 改变  */
    [self.tableView addObserver:self forKeyPath:contentOffsetKeyPath options:NSKeyValueObservingOptionNew context:(void *)context];

    
    [self.modules enumerateObjectsUsingBlock:^(NSObject *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeObserver:self forKeyPath:observerKeyPath];
    }];
    [self.modules removeAllObjects];
    
    NSArray *sortModuels = [PersonalCenterConfig sharedPersonalCenterConfig].modulekeys;
    [sortModuels enumerateObjectsUsingBlock:^(NSString *  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        id<ZWTableViewAdapter> obj = [self.modulesObjectMap objectForKey:key];
        if (obj) {
            [self configModule:obj];
            [self.modules addObject:obj];
        }
    }];
    
    [self registNotificationForLogout];
    
    [self.modules enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(ZWViewControllerAdapter)]) {
            if ([obj respondsToSelector:@selector(viewDidLoad)]) {
                [obj viewDidLoad];
                [self.modulesViewDidLoadMap setObject:@YES forKey:[self moduleClassName:obj]];
            }
            /** 换肤  */
            if ([obj respondsToSelector:@selector(themeChangeNotification)]) {
                [obj themeChangeNotification];
            }
        }
    }];
    [self.tableView reloadData];
    
}

#pragma mark - 生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.navigationViewModel refreshView];
    [self.modules enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(ZWViewControllerAdapter)]) {
            BOOL viewDidLoad = [[self.modulesViewDidLoadMap objectForKey:[self moduleClassName:obj]] boolValue];
            if (!viewDidLoad && [obj respondsToSelector:@selector(viewDidLoad)]) {
                [obj viewDidLoad];
                [self.modulesViewDidLoadMap setObject:@YES forKey:[self moduleClassName:obj]];
            }
            if (!viewDidLoad && [obj respondsToSelector:@selector(themeChangeNotification)]) {
                [obj themeChangeNotification];
            }
            if ([obj respondsToSelector:@selector(viewWillAppear:)]) {
                [obj viewWillAppear:animated];
            }
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.modules enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(ZWViewControllerAdapter)]) {
            if ([obj respondsToSelector:@selector(viewDidAppear:)]) {
                [obj viewDidAppear:animated];
            }
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.modules enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(ZWViewControllerAdapter)]) {
            if ([obj respondsToSelector:@selector(viewWillDisappear:)]) {
                [obj viewWillDisappear:animated];
            }
        }
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.modules enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(ZWViewControllerAdapter)]) {
            if ([obj respondsToSelector:@selector(viewDidDisappear:)]) {
                [obj viewDidDisappear:animated];
            }
        }
    }];
}


/** 处理下拉刷新  */
- (void)pullRefresh
{
    [LoadingUtil show];
    [self.modules enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(ZWViewControllerAdapter)]) {
            if ([obj respondsToSelector:@selector(pullRefresh)]) {
                [obj pullRefresh];
            }
        }
    }];
    
    performBlockDelay(dispatch_get_main_queue(), 2.0, ^{
        [self endRefresh];
    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self endRefresh];
//    });
}

- (void)endRefresh
{
    [LoadingUtil hide];
    if ([self.tableView.mj_header isRefreshing]) {
        [self.tableView.mj_header endRefreshing];
    }
//    [self.navigationViewModel refreshView];
}

/** 注册通知  */
- (void)registNotificationForLogout
{
    
    
}

/** 换肤处理  */
- (void)themeChangeNotification
{
    
}


#pragma mark - tableview datasource & delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    __block NSInteger totalRows = 0;
    [self.modules enumerateObjectsUsingBlock:^(id<ZWTableViewAdapter>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        totalRows += [obj numberOfRows];
    }];
    return totalRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block float height = 0.001;
    __block NSInteger preTotalRows = 0;
    __block NSInteger totalRows = 0;
    NSInteger index = indexPath.row;
    [self.modules enumerateObjectsUsingBlock:^(id<ZWTableViewAdapter>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        totalRows += [obj numberOfRows];
        NSInteger count = index - totalRows;
        if (count < 0) {
            height = [obj tableView:tableView heightForRowAtIndex:(index - preTotalRows)];
            *stop = YES;
        }
        preTotalRows += [obj numberOfRows];
    }];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block UITableViewCell *cell;
    __block NSInteger preTotalRows = 0;
    __block NSInteger totalRows = 0;
    NSInteger index = indexPath.row;
    [self.modules enumerateObjectsUsingBlock:^(id<ZWTableViewAdapter>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        totalRows += [obj numberOfRows];
        NSInteger count = index - totalRows;
        if (count < 0) {
            cell = [obj tableView:tableView cellForRowAtIndex:(index - preTotalRows)];
            *stop = YES;
        }
        preTotalRows += [obj numberOfRows];
    }];
    
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:emptyCellReuseIdentify];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:emptyCellReuseIdentify];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block NSInteger preTotalRows = 0;
    __block NSInteger totalRows = 0;
    NSInteger index = indexPath.row;
    [self.modules enumerateObjectsUsingBlock:^(id<ZWTableViewAdapter>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        totalRows += [obj numberOfRows];
        NSInteger count = index - totalRows;
        if (count < 0) {
            if ([obj respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
                [obj tableView:tableView didSelectRowAtIndexPath:(index - preTotalRows)];
            }
            *stop = YES;
        }
        preTotalRows += [obj numberOfRows];
    }];
}


#pragma mark - lazyLoad
- (ZWBaseTableView *)tableView
{
    if (!_tableView) {
        _tableView = [[ZWBaseTableView alloc] initWithFrame:CGRectMake(0, kSysStatusBarHeight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - kSysStatusBarHeight) style:UITableViewStylePlain];
        _tableView.backgroundColor = UIColorFromRGB(0xF2F2F2);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (NSMutableArray *)modules
{
    if (!_modules) {
        _modules = [NSMutableArray array];
    }
    return _modules;
}

- (NSMutableDictionary *)modulesObjectMap
{
    if (!_modulesObjectMap) {
        _modulesObjectMap = [NSMutableDictionary dictionary];
    }
    return _modulesObjectMap;
}


- (NSMutableDictionary *)modulesViewDidLoadMap
{
    if (!_modulesViewDidLoadMap) {
        _modulesViewDidLoadMap = [NSMutableDictionary dictionary];
    }
    return _modulesViewDidLoadMap;
}


@end
