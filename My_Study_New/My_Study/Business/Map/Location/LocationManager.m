//
//  LocationManager.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "LocationManager.h"
#import "AMapLocationKit/AMapLocationKit.h"
#import "AMapFoundationKit/AMapFoundationKit.h"
#import "PermissionProtocol.h"
#import "Permission.h"

@interface LocationManager()

@property (nonatomic, strong) AMapLocationManager* locationManager;

@end

@implementation LocationManager

+ (instancetype)shareLocationManager {
    static LocationManager *_shareConfig = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _shareConfig = [[self alloc] init];
    });
    
    return _shareConfig;
}

- (void)configAMapService:(NSString *)apiKey{
    [AMapServices sharedServices].apiKey = apiKey;
    [AMapServices sharedServices].enableHTTPS = YES;
    
    //检查隐私合规
    [MAMapView updatePrivacyShow:AMapPrivacyShowStatusDidShow privacyInfo:AMapPrivacyInfoStatusDidContain];
    [MAMapView updatePrivacyAgree:AMapPrivacyAgreeStatusDidAgree];
}

- (void)requestLocationWithReGeocode:(BOOL)reGeocode completionBlock:(JXLocationManagerBlock)funcBlock {
    
    dispatch_block_t block = ^{
        if (self.locationManager == nil) {
            self.locationManager = [[AMapLocationManager alloc] init];
            [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
            [self.locationManager setDistanceFilter:10];
            [self.locationManager setLocationTimeout:10];
            [self.locationManager setReGeocodeTimeout:10];
        }
        [self.locationManager requestLocationWithReGeocode:reGeocode completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
            
            if (error) {
                BlockSafeRun(funcBlock,nil,error);
            } else {
                CLLocationCoordinate2D loc = [location coordinate];
                JXLocation * location = [[JXLocation alloc] init];
                location.longitude = loc.longitude;
                location.latitude = loc.latitude;
                                
                if(regeocode) {
                    location.provinceName = regeocode.province;
                    location.cityName = regeocode.city ? regeocode.city : regeocode.province;
                    location.city = regeocode.citycode;
                    location.street = regeocode.street;
                    location.zoneName = regeocode.district;
                    location.zone = regeocode.adcode;
                    location.name = regeocode.formattedAddress;
                    location.number = regeocode.number;
                    location.AOIName = regeocode.AOIName;
                    location.POIName = regeocode.POIName;

                    BlockSafeRun(funcBlock,location,nil);
                    
                } else {
                    BlockSafeRun(funcBlock, location,nil);
                }
            }
        }];
    };
    id<PermissionProtocol> permission = [Permission objectForType:PermissionTypeLocationWhenInUse];
    [permission request:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([permission isAuthorized]){
                block();
            } else if ([permission isDenied]){
                NSError *error = [[NSError alloc] initWithDomain:@"com.zwapp.LocationManager"
                                                            code:-6666
                                                        userInfo:@{NSLocalizedDescriptionKey: @"授权失败"}];
                BlockSafeRun(funcBlock,nil,error);
            }
        });
    }];
}


@end
