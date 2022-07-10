//
//  PermissionPhotoLibrary.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "PermissionPhotoLibrary.h"

@implementation PermissionPhotoLibrary

- (BOOL)isAuthorized{
    return [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized;
}

- (BOOL)isDenied{
    return [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied;
}

- (void)request:(void (^)(void))block{
    if ([self isAuthorized] || [self isDenied]){
        BlockSafeRun(block);
    } else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                BlockSafeRun(block);
            });
        }];
    }
}

@end
