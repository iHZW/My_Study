//
//  PermissionCamera.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "PermissionCamera.h"
#import <AVFoundation/AVFoundation.h>

@implementation PermissionCamera

- (BOOL)isAuthorized{
    return [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized;
}

- (BOOL)isDenied{
    return [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusDenied;
}
- (void)request:(void (^)(void))block{
    if ([self isAuthorized] || [self isDenied]){
        BlockSafeRun(block);
    } else {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            BlockSafeRun(block);
        }];
    }
}

@end
