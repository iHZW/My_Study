//
//  LoginManager.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/12.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "LoginManager.h"
#import "NSObject+KeyedArchiver.h"
#import "ZWCommonUtil.h"

#define kSaveLoginInfoKey           @"kSaveLoginInfoKey"

@implementation LoginManager
DEFINE_SINGLETON_T_FOR_CLASS(LoginManager)

- (void)loadConfig
{
    ZWUserAccountManager *loginInfo = [self getLoginInfo];
    if (loginInfo) {
        ZWUserAccountManager *accountManager = ZWSharedUserAccountManager;
        accountManager.currentUserInfo = loginInfo.currentUserInfo;
    }
}

/**
 *  获取登录信息
 */
- (ZWUserAccountManager * _Nullable)getLoginInfo
{
    //获取缓存登录数据
    NSData *data = (NSData *)[ZWCommonUtil getObjectWithKey:kSaveLoginInfoKey];
    if (data) {
        ZWUserAccountManager *tempInfoModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return tempInfoModel;
    }
    return nil;
}

/**
 *  保存登录信息
 *  @param loginInfo    登录信息
 */
- (void)saveLoginInfo:(ZWUserAccountManager *)loginInfo
{
    NSData *archiverData = [NSKeyedArchiver archivedDataWithRootObject:loginInfo];
    if (archiverData) {
        [ZWCommonUtil setObject:archiverData forKey:kSaveLoginInfoKey];
    }
}

@end
