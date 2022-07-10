//
//  MapTypeHelper.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/6.
//  Copyright © 2022 HZW. All rights reserved.
//

//高德地图、腾讯地图以及谷歌中国区地图使用的是GCJ-02坐标系
//百度地图使用的是BD-09坐标系
//苹果自带地图在国内使用高德提供的数据,所以使用的是GCJ-02坐标系

#import "MapTypeHelper.h"
#import "MapHeader.h"
#import "UIApplication+Ext.h"
#import <MapKit/MapKit.h>

@interface MapTypeHelper ()

@property (nonatomic, assign) double baidu_latitude;

@property (nonatomic, assign) double baidu_longitude;

@end

@implementation MapTypeHelper

- (instancetype)initMapTypeHelper:(double)latitude longitude:(double)longitude address:(NSString *)address {
    self = [super init];
    if (self) {
        self.latitude = latitude;
        self.longitude = longitude;
        self.address = address;
        if (self.address.length <=0) {
            self.address = @"目的地";
        }
    }
    return self;
}

- (NSMutableArray *)getInstalledMapAppWithEndLocation {
     NSMutableArray *maps = [[NSMutableArray alloc] init];
    
    if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"http://maps.apple.com:/"]]) {
       NSMutableDictionary *iosMapDic = [[NSMutableDictionary alloc] init];
        iosMapDic[@"title"] = @"苹果地图";

        [maps addObject:iosMapDic];
    }
    
   
    
    //苹果地图
    
//    NSMutableDictionary *iosMapDic = [[NSMutableDictionary alloc] init];
//    iosMapDic[@"title"] = @"苹果地图";
//
//    [maps addObject:iosMapDic];

    //百度地图
    if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        
        //高德坐标转百度坐标  （不需要特意转换，coord_type设为gcj02，百度地图内部会自动转换为百度坐标）
//        [self gaodeToBdWithLat:self.latitude andLon:self.longitude];

        NSMutableDictionary *baiduMapDic = [NSMutableDictionary dictionary];
        baiduMapDic[@"title"] = @"百度地图";
        NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&location=%f,%f&destination=%@ &mode=driving&coord_type=gcj02",self.latitude, self.longitude,self.address ]stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        baiduMapDic[@"url"] = urlString;
        [maps addObject:baiduMapDic];
    }
    
    //高德地图
    if([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {

        NSMutableDictionary *gaodeMapDic = [NSMutableDictionary dictionary];

        gaodeMapDic[@"title"] = @"高德地图";
        
        //t = 0：驾车 =1：公交 =2：步行
         NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&sid=BGVIS1&slat=&slon=&sname=&did=BGVIS2&dlat=%f&dlon=%f&dname=%@&dev=0&t=0",@"朱雀",self.latitude, self.longitude,self.address]stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

        gaodeMapDic[@"url"] = urlString;

        [maps addObject:gaodeMapDic];
   }
    
    //腾讯地图

    if([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {

        NSMutableDictionary *qqMapDic = [NSMutableDictionary dictionary];

        qqMapDic[@"title"] = @"腾讯地图";

        NSString *urlString = [[NSString stringWithFormat:@"qqmap://map/routeplan?from=我的位置&type=drive&tocoord=%f,%f&to=%@&coord_type=1&policy=0",self.latitude, self.longitude,self.address]stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

        qqMapDic[@"url"] = urlString;

        [maps addObject:qqMapDic];
    }
    
   return maps;
}

//高德坐标转百度坐标
//- (void)gaodeToBdWithLat:(double)gg_lat andLon:(double)gg_lon {
//
//    double x_pi = 3.14159265358979324 * 3000.0 / 180.0;
//    double x = gg_lon, y = gg_lat;
//    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
//    double theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
//    self.baidu_longitude = z * cos(theta) + 0.0065;
//    self.baidu_latitude = z * sin(theta) + 0.006;
//}


#pragma mark - UIActionSheet

- (void)showActionView {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSInteger index = self.maps.count;
    
    for (int i = 0; i < index; i++) {
        NSString *title = self.maps[i][@"title"];
        if (i == 0){
            UIAlertAction *action = [UIAlertAction actionWithTitle:title style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                [self navAppleMap];
            }];
            [alertController addAction:action];
            continue;
        }
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            NSString *urlString = self.maps[i][@"url"];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];
        }];
        
        [alertController addAction:action];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:cancelAction];
    
    [[UIApplication displayViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)navAppleMap {
    
    MKMapItem *mylocation = [MKMapItem mapItemForCurrentLocation];
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(self.latitude, self.longitude); //目标地址的经纬度

    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coord addressDictionary:nil]];
    toLocation.name = self.address;
    NSDictionary *options = @{ MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsMapTypeKey: [NSNumber numberWithInteger:MKMapTypeStandard], MKLaunchOptionsShowsTrafficKey:@YES };
    
    [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:mylocation, toLocation, nil] launchOptions:options];
}


@end
