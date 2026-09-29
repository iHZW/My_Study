//
//  ZWLaunchManage.m
//  My_Study
//
//  Created by hzw on 2023/7/29.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "ZWLaunchManage.h"

@implementation ZWLaunchManage

+ (instancetype)sharedInstance {
    static ZWLaunchManage *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

@end
