//
//  Permission.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "Permission.h"
#import "PermissionPhotoLibrary.h"
#import "PermissionLocation.h"
#import "PermissionCamera.h"
#import "PermissionMicrophone.h"
#import "PermissionContact.h"
#import "LogUtil.h"

@implementation Permission

static id<PermissionIntercept> _intercept;

+ (id<PermissionIntercept>)permissionIntercept{
    return _intercept;
}
+ (void)setIntercept:(id<PermissionIntercept>)intercept{
    _intercept = intercept;
}

+ (PermissionObject)objectForType:(PermissionType)type{
    NSString *usageDescriptionKey = [self usageDescriptionKeyForType:type];
    if (![[[NSBundle mainBundle] infoDictionary].allKeys containsObject:usageDescriptionKey]){
        [LogUtil error:@"权限未在Info.plist配置" flag:nil context:self];
    }
    
    PermissionObject permission = nil;
    switch (type) {
        case PermissionTypePhotoLibrary:
            permission = [[PermissionPhotoLibrary alloc] init];
            break;
        case PermissionTypeLocationWhenInUse:
            permission = [PermissionLocation locationForType:LocationTypeWhenInUse];
            break;
        case PermissionTypeLocationAlways:
            permission = [PermissionLocation locationForType:LocationTypeAlways];
            break;
        case PermissionTypeCamera:
            permission = [[PermissionCamera alloc] init];
            break;
        case PermissionTypeMicrophone:
            permission = [[PermissionMicrophone alloc] init];
            break;
        case PermissionTypeContact:
            permission = [[PermissionContact alloc] init];
            break;
    }
    [permission setPermissionType:type];
    return permission;
}


+ (void)requestForType:(PermissionType)type notAuthorizedMessage:(NSString *)message complete:(void (^)(PermissionAuthorizationStatus))block{
    id<PermissionProtocol> permission = [self objectForType:type];
    [self request:permission notAuthorizedMessage:message complete:block];
}


+ (void)request:(PermissionObject)permission notAuthorizedMessage:(NSString *)message complete:(void (^)(PermissionAuthorizationStatus))block{
    //权限请求后， 结果通知外部
    dispatch_block_t resultBlock = ^{
        if ([permission isAuthorized]){
            BlockSafeRun(block,PermissionAuthorizationStatusAuthorized);
        } else if ([permission isDenied]){
            BlockSafeRun(block,PermissionAuthorizationStatusDenied);
        } else {
            BlockSafeRun(block,PermissionAuthorizationStatusNotDetermined);
        }
    };
    
    if (_intercept){
        [_intercept request:permission notAuthorizedMessage:message complete:^{
            resultBlock();
        }];
    } else {
        [permission request:^{
            resultBlock();
        }];
    }
    
}


+ (NSString *)usageDescriptionKeyForType:(PermissionType)type{
    switch (type) {
        case PermissionTypePhotoLibrary:
            return @"NSPhotoLibraryUsageDescription";
            break;
        case PermissionTypeLocationAlways:
            return @"NSLocationAlwaysAndWhenInUseUsageDescription";
            break;
        case PermissionTypeLocationWhenInUse:
            return @"NSLocationWhenInUseUsageDescription";
            break;
        case PermissionTypeCamera:
            return @"NSCameraUsageDescription";
            break;
        case PermissionTypeMicrophone:
            return @"NSMicrophoneUsageDescription";
            break;
        case PermissionTypeContact:
            return @"NSContactsUsageDescription";
            break;
    }
}

@end
