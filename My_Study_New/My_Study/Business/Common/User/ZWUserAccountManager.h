//
//  ZWUserAccountManager.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingletonTemplate.h"
#import "ZWUserInfoModel.h"

/** 用户管理 */
#define ZWSharedUserAccountManager [ZWUserAccountManager sharedZWUserAccountManager]
/** 当前用户信息 */
#define ZWCurrentUserInfo [ZWUserAccountManager sharedZWUserAccountManager].currentUserInfo


NS_ASSUME_NONNULL_BEGIN

@interface ZWUserAccountManager : NSObject <NSSecureCoding>
DEFINE_SINGLETON_T_FOR_HEADER(ZWUserAccountManager)

/** 当前用户所有信息  */
@property (nonatomic, strong) ZWUserInfoModel *currentUserInfo;

//跳转到登录页面的时候存在alert （退出登录 alert 和 闪验授权页面 present 存在冲突， 导致授权页不显示， 加上这个标志，是为了在alert 关闭之后，再去开始闪验授权）
@property (nonatomic, assign) BOOL loginPageWithAlert;

/**
 *  更新本地登录信息
 */
- (void)saveLoginStatusData;

/**
 *  清空本地登录信息
 */
- (void)cleanLoginStatusData;

@end

NS_ASSUME_NONNULL_END
