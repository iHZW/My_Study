//
//  LocationTrimDataLoader.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/6.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "LocationTrimDataLoader.h"
#import "POIAnnotation.h"

@interface LocationTrimDataLoader ()<AMapSearchDelegate, AMapLocationManagerDelegate>

@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) NSMutableArray *poiAnnotations;

@property (nonatomic, assign) NSInteger pageNum;

@property (nonatomic, copy) ResponseLoaderBlock loaderBlock;
/** 搜索关键字  */
@property (nonatomic, copy) NSString *searchKeywords;

@end


@implementation LocationTrimDataLoader

- (instancetype)init
{
    if (self = [super init]) {
        
        self.search = [[AMapSearchAPI alloc] init];
        self.search.delegate = self;
        self.searchKeywords = @"长江路30弄";
        
    }
    return self;
}

- (void)sendRequestLocationData:(ResponseLoaderBlock)block
{
    [self sendRequestLocationDataPageCount:1 blcok:block];
}

- (void)sendRequestLocationDataPageCount:(NSInteger)page blcok:(ResponseLoaderBlock)block
{
    self.requestNo = page;
    self.loaderBlock = block;
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    
    request.location            = [AMapGeoPoint locationWithLatitude:self.coordinate.latitude                           longitude:self.coordinate.longitude];
    request.page                = page;
    request.offset              = 10;
    /* 按照距离排序. */
    request.sortrule            = 0;
//    request.requireExtension    = YES;
    request.radius = 100;
    request.types = @"汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施";
    
    if (self.poiAnnotations.count <= 0 || request.page > 1) { // 防止 becomeActive时，重复请求
        [self.search AMapPOIAroundSearch:request];
    }else {
        AMapInputTipsSearchRequest *requestInput = [[AMapInputTipsSearchRequest alloc] init];
        requestInput.keywords = self.searchKeywords;
        requestInput.city = self.currentCity;
        [self.search AMapInputTipsSearch:requestInput];
        
        
//        [self refresh];
    }
    
}

/** 刷新  */
- (void)refresh
{
    BlockSafeRun(self.loaderBlock, 0, @[]);
}

#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    //请求失败后返回失败数据
//     [self refresh];
}

/* 位置更新回调 */
- (void)amapLocationManager:(AMapLocationManager *)manager
          didUpdateLocation:(CLLocation *)location
                  reGeocode:(AMapLocationReGeocode *)reGeocode
{
    //经纬度
    NSLog(@"location:{lat:%f; lon:%f}", location.coordinate.latitude, location.coordinate.longitude);
//    self.coordinate = location;
    
    //逆地理编码
    [self reGoecodeWithLocation:location];
    
    //发起周边搜索
//    [self searchAroundWithKeywords:nil];
    
    //停止定位
//    [self.locationManager stopUpdatingLocation];
}

//逆地理编码
- (void)reGoecodeWithLocation:(CLLocation *)location
{
    AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc] init];
    request.location =[AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    [self.search AMapReGoecodeSearch:request];
}

/* 逆地理编码查询回调函数 */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    self.currentCity = response.regeocode.addressComponent.city;
    if (!ValidString(self.currentCity)) {
        self.currentCity = response.regeocode.addressComponent.province;
    }
    NSLog(@"当前定位城市 = %@", self.currentCity);
}

/**
 * @brief POI查询回调函数
 * @param request  发起的请求，具体字段参考 AMapPOISearchBaseRequest 及其子类。
 * @param response 响应结果，具体字段参考 AMapPOISearchResponse 。
 */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (response.pois.count < 10) { //搜索一页的数据小于10条，说明是最后一页了
        self.noMore = YES;
    }
    
    if (response.pois.count == 0) {
        [self refresh];
        return;
    }
    
    if (!self.poiAnnotations || request.page <= 1) {
        self.poiAnnotations = [NSMutableArray array];
    }
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        [self.poiAnnotations addObject:[[POIAnnotation alloc] initWithPOI:obj]];
    }];
    
    self.pageNum = request.page;
    BlockSafeRun(self.loaderBlock, 1, TransToArray(self.poiAnnotations));
    
//    [self refresh];
}

/**
 * @brief 输入提示查询回调函数
 * @param request  发起的请求，具体字段参考 AMapInputTipsSearchRequest 。
 * @param response 响应结果，具体字段参考 AMapInputTipsSearchResponse 。
 */
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response
{
    
    
    
}


@end
