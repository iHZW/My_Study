//
//  PermissionMicrophone.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "PermissionMicrophone.h"
#import <AVFoundation/AVFoundation.h>

@implementation PermissionMicrophone


- (BOOL)isAuthorized{
    return [AVAudioSession sharedInstance].recordPermission == AVAudioSessionRecordPermissionGranted;
}

- (BOOL)isDenied{
    return [AVAudioSession sharedInstance].recordPermission == AVAudioSessionRecordPermissionDenied;
}

- (void)request:(void (^)(void))block{
    if ([self isAuthorized] || [self isDenied]){
        BlockSafeRun(block);
    } else {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                BlockSafeRun(block);
            });
        }];
    }
}

@end
