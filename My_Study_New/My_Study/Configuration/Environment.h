//
//  Environment.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/5.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnvConfigObject.h"
#import "EnvironmentType.h"

NS_ASSUME_NONNULL_BEGIN

@class SubEnvInfo;

@interface Environment : NSObject
DEFINE_SINGLETON_T_FOR_HEADER(Environment)

@property (nonatomic,assign, readonly) EnvironmentType currentEnvironmentType;

/** 更新环境  */
- (void)updateEnvironment:(EnvironmentType)toEnv;
/** 加载环境配置  */
- (EnvConfigObject *)loadEvnConfigObject;

//子环境值
- (void)saveSubEnv:(SubEnvInfo *)subEnv;

- (SubEnvInfo *)fetchSubEnv;

//开启，关闭IM互踢，默认关闭; 只有在测试包有效，线上包开启互踢
- (BOOL)isIMForceOffline;

- (void)saveIMForceOffline:(BOOL)offline;

@end





@interface SubEnvInfo: NSObject

@property (nonatomic, copy) NSString *value;

@property (nonatomic, assign) BOOL on;

+ (instancetype)init:(NSString *)value on:(BOOL)on;

@end

NS_ASSUME_NONNULL_END
