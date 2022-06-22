//
//  ZWMainAppDelegateService.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/22.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWMainAppDelegateService.h"
#import "ZWHttpNetworkManager.h"
#import "ZWCommonUtil.h"

@implementation ZWMainAppDelegateService

+ (void)initialize
{
    [super initialize];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions
{
    
    [[ZWHttpNetworkManager sharedHttpManager] initializeData];
    [ZWCommonUtil checkAndWriteLocalCMSDataToCache];
    return YES;
}

@end
