//
//  PermissionLocationWhenInUseHandler.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "PermissionLocationWhenInUseHandler.h"
#import <CoreLocation/CoreLocation.h>


@interface PermissionLocationWhenInUseHandler()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, copy) PermissionLocationCompleteBlock completeBlock;

@end

@implementation PermissionLocationWhenInUseHandler

+(instancetype)shared{
    static PermissionLocationWhenInUseHandler *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[PermissionLocationWhenInUseHandler alloc] init];
    });
    return _instance;
}

- (CLLocationManager *)locationManager{
    if (!_locationManager){
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusNotDetermined){
        return;
    }
    BlockSafeRun(self.completeBlock,[self isAuthorized]);
}

- (BOOL)isAuthorized{
    return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
}
- (void)requestPermission:(PermissionLocationCompleteBlock)completeBlock{
    self.completeBlock = completeBlock;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
        self.locationManager.delegate = self;
        [self.locationManager requestWhenInUseAuthorization];
    }
}

@end
