//
//  PersonalCenterConfig.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/29.
//  Copyright © 2022 HZW. All rights reserved.
//
/** 个人中心配置  */
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PersonalCenterConfig : NSObject
DEFINE_SINGLETON_T_FOR_HEADER(PersonalCenterConfig)

/** 模块key数组  */
@property (nonatomic, strong) NSArray *modulekeys;

/** 获取所有的模块信息字典  */
+ (NSDictionary *)allModulesNameMap;

@end

NS_ASSUME_NONNULL_END
