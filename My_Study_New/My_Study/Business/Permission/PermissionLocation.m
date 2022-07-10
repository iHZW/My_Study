//
//  PermissionLocation.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "PermissionLocation.h"
#import <CoreLocation/CoreLocation.h>
#import "PermissionLocationWhenInUseHandler.h"

@interface PermissionLocation()

@property(nonatomic,assign) LocationType locationType;

@end

@implementation PermissionLocation

+ (instancetype)locationForType:(LocationType)locationType{
    PermissionLocation *permissionLocation = [[PermissionLocation alloc] init:locationType];
    return permissionLocation;
}

- (instancetype)init:(LocationType)locationType{
    self = [super init];
    if (self){
        self.locationType = locationType;
    }
    return self;
}

- (BOOL)isAuthorized{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedAlways){
        return YES;
    } else {
        if (self.locationType == LocationTypeWhenInUse){
            return status == kCLAuthorizationStatusAuthorizedWhenInUse;
        } else{
            return NO;
        }
    }
}

- (BOOL)isDenied{
    return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied;
}


- (void)request:(void (^)(void))block{
    if ([self isAuthorized] || [self isDenied]){
        BlockSafeRun(block);
    } else {
        [[PermissionLocationWhenInUseHandler shared] requestPermission:^(BOOL isAuthorized) {
            BlockSafeRun(block);
        }];
    }
}

@end
