//
//  PersonalCenterConfig.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/29.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "PersonalCenterConfig.h"

/** 用户信息  */
static NSString * const kUserInfoModule = @"userInfo";
/** 设置/登录  */
static NSString * const kSettingLogoutModule = @"settingLogout";


@interface PersonalCenterConfig ()

@property (nonatomic, strong) NSMutableArray *modulesKeyArray;

@end

@implementation PersonalCenterConfig
DEFINE_SINGLETON_T_FOR_CLASS(PersonalCenterConfig)

- (instancetype)init
{
    if (self = [super init]) {
        self.modulesKeyArray = [NSMutableArray array];
        self.modulekeys = @[kUserInfoModule, kSettingLogoutModule];
    }
    return self;
}



- (NSDictionary *)allModulesNameMap
{
    //key:unique key string, value: unique modules calss name
    return @{
             kUserInfoModule : @"ZWUserHeaderModule",
             kSettingLogoutModule : @"ZWSettingLogoutModule"
            };
}


+ (NSDictionary *)allModulesNameMap
{
    return [[PersonalCenterConfig sharedPersonalCenterConfig] allModulesNameMap];
}

@end
