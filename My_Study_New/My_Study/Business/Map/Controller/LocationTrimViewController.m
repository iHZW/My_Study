//
//  LocationTrimViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/6.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "LocationTrimViewController.h"
#import "LocationTrimAdapter.h"
#import "LocationAuthority.h"
#import "LoadingUtil.h"
#import "LocationTrimDataLoader.h"
#import "ZWBaseTableView.h"
#import "Config.h"
#import "LocationManager.h"
#import "Permission.h"
#import "Toast.h"
#import "TrimHeaderView.h"


//#import "TrimAddressViewModel.h"


@interface LocationTrimViewController ()<LocationTrimAdapterDidSelectProtocol>

@property (nonatomic, strong) ZWBaseTableView *tableView;

@property (nonatomic, strong) LocationTrimAdapter *tableAdapter;

@property (nonatomic, strong) LocationTrimDataLoader *dataLoader;

@property (nonatomic, copy) NSString *locationName;

@property (nonatomic, strong) TrimHeaderView *headerView;

@end

@implementation LocationTrimViewController

/** 路由传参把 当前位置传过来  */
- (void)decodeRouterParams:(NSDictionary *)routerParams{
    [super decodeRouterParams:routerParams];
    if (routerParams) {
        self.coordinate = CLLocationCoordinate2DMake([routerParams[@"latitude"] doubleValue], [routerParams[@"longitude"] doubleValue]);
    }
    
    self.coordinate = CLLocationCoordinate2DMake(35.948511, 120.160931);
}

- (void)initExtendedData
{
    [super initExtendedData];
    self.title = @"周边信息";
}

- (void)loadUIData
{
    [super loadUIData];
    
    [self getLocationAddress];
}

- (void)getLocationAddress
{
    BOOL isAuth = [LocationAuthority determineWhetherTheAPPOpensTheLocation];
    if (!isAuth) {
        [LocationAuthority showActionViewWithNoPop];
    }
//    NSString *permissonStr = [Session userSession].accountId == kkAccountID ?@"此功能需要使用“位置”，打开后，可使用定位签到、记录跟进。是否同意使用位置？如需使用，请在“系统设置”或授权对话框中允许“位置”权限。" :@"My_Study被禁止访问您的“位置”，将无法使用定位签到、记录跟进。<br/><br/>如需使用，请在“系统设置”或授权对话框中允许“位置”权限。"
    
    NSString *permissonStr = @"My_Study被禁止访问您的“位置”，将无法使用定位签到、记录跟进。<br/><br/>如需使用，请在“系统设置”或授权对话框中允许“位置”权限。" ;
    @pas_weakify_self
    [Permission requestForType:PermissionTypeLocationWhenInUse notAuthorizedMessage: permissonStr complete:^(PermissionAuthorizationStatus status) {
        @pas_strongify_self
        if (status == PermissionAuthorizationStatusAuthorized){
            [self requestLocation];
        } else {
//            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}


- (void)requestLocation
{
    @pas_weakify_self
    [[LocationManager shareLocationManager] requestLocationWithReGeocode:YES completionBlock:^(JXLocation * _Nonnull location, NSError * _Nonnull error) {
        @pas_strongify_self
        /** 这是经纬度  */
        self.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
        
        NSString *str = [NSString stringWithFormat:@"当前位置: %@ - 国家: %@ - 城市: %@ - POIName: %@ - AOIName: %@", TransToString(location.name), TransToString(location.country), TransToString(location.cityName), TransToString(location.POIName), TransToString(location.AOIName)];
        self.dataLoader.currentCity = TransToString(location.cityName);
        [Toast show:str];
        self.locationName = location.name;
        [self getLocationAuth];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [LoadingUtil hide];
}


//获取定位权限
- (void)getLocationAuth {
    BOOL isAuth = [LocationAuthority determineWhetherTheAPPOpensTheLocation];
    [self configUI:isAuth];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification  {
    [self getLocationAuth];
}

- (void)configUI:(BOOL)isAuth {
//    self.navigationItem.rightBarButtonItems = @[];
    
    if (isAuth) {
        [self.view addSubview:self.tableView];
        [self.tableView reloadData];
        [self requestData];
    }else {
        [_tableView removeFromSuperview];
        _tableView = nil;
        [LocationAuthority showActionView];
    }
}

- (void)requestData
{
    [self sendRequestPageCount:1];
}

- (void)sendRequestPageCount:(NSInteger)pageCount
{
    self.dataLoader.coordinate = self.coordinate;
    [LoadingUtil show];
    @pas_weakify_self
    [self.dataLoader sendRequestLocationDataPageCount:pageCount blcok:^(NSInteger status, id  _Nullable obj)
     {
         @pas_strongify_self
         [LoadingUtil hide];
         if (status == 1){
             if (self.type == 1) {
                 NSMutableArray <POIAnnotation *> * array = [NSMutableArray array];
                 POIAnnotation * annot = [obj objectAtIndex:0];
                 POIAnnotation * po = [[POIAnnotation alloc]initWithPOI:annot.poi];
                 po.tag = 13579;
                 [array addObject:po];
                 [array addObjectsFromArray:obj];
                 self.tableAdapter.poisList = array;
             }else{
                 self.tableAdapter.poisList = obj;
             }
             [self.tableView.mj_footer endRefreshing];
             [self.tableView reloadData];
         }else {
             [Toast show:@"地图请求失败"];
 //            [self.navigationController popViewControllerAnimated:YES];
         }
     }];
}

#pragma mark - lazyLoad
- (ZWBaseTableView *)tableView
{
    if (!_tableView) {
        _tableView = [[ZWBaseTableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight - kMainNavHeight - kSysStatusBarHeight) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self.tableAdapter;
        _tableView.dataSource = self.tableAdapter;
        
        
        _tableView.estimatedRowHeight = 100;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        
        _tableView.tableHeaderView = self.headerView;
        
        @pas_weakify_self
        [_tableView loadMoreView:^{
            @pas_strongify_self
            /** 加载更多  */
            if (self.dataLoader.noMore) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            } else {
//                [self sendRequestPageCount:(self.dataLoader.requestNo + 1)];
                [self sendRequestPageCount:1];
            }
        }];
    }
    return _tableView;
}


- (LocationTrimDataLoader *)dataLoader
{
    if (!_dataLoader) {
        _dataLoader = [[LocationTrimDataLoader alloc] init];
    }
    return _dataLoader;
}

- (LocationTrimAdapter *)tableAdapter {
    if (!_tableAdapter) {
        _tableAdapter = [[LocationTrimAdapter alloc]init];
        _tableAdapter.ownerController = self;
        _tableAdapter.delegate = self;
    }
    _tableAdapter.tableView = self.tableView;
    return _tableAdapter;
}

- (TrimHeaderView *)headerView
{
    if (!_headerView) {
        _headerView = [[TrimHeaderView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 200)];
        _headerView.loadingTip = @"小爱正在努力......";
    }
    return _headerView;
}


//MARK: delegate --
-(void)locationTableViewDidSelect {
    [self rightButtonAction];
}

#pragma mark - action
//确定微调的地址
- (void)rightButtonAction {
    if (self.tableAdapter.selectedModel) {
        
        POIAnnotation *model = self.tableAdapter.selectedModel;
        
        BlockSafeRun(self.tapAnnoItemHandler, model);
        BlockSafeRun(self.routerParamObject.successBlock, model);

        /** 选中返回  */
        [self.navigationController popViewControllerAnimated:YES];
    }
}





@end
