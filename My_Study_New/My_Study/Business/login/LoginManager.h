//
//  LoginManager.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/12.
//  Copyright © 2022 HZW. All rights reserved.
//
/** 登录管理类 , 保存登录信息使用 */
#import "CMObject.h"

@class ZWUserInfoModel;
NS_ASSUME_NONNULL_BEGIN

@interface LoginManager : CMObject
DEFINE_SINGLETON_T_FOR_HEADER(LoginManager)

/**
 *  加载登录配置信息
 */
- (void)loadConfig;

/**
 *  获取登录信息
 */
- (ZWUserAccountManager * _Nullable)getLoginInfo;

/**
 *  保存登录信息
 *  @param loginInfo    登录信息
 */
- (void)saveLoginInfo:(ZWUserInfoModel *)loginInfo;


@end

NS_ASSUME_NONNULL_END
