//
//  ZWUserAccountManager.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWUserAccountManager.h"
#import "NSObject+MJCoding.h"
#import "ZWCommonUtil.h"

#define KAccountSaveInfoKey           @"accountSaveInfoKey"

@implementation ZWUserAccountManager
DEFINE_SINGLETON_T_FOR_CLASS(ZWUserAccountManager)

MJExtensionCodingImplementation

#pragma mark - NSSecureCoding
//+(NSArray *)mj_ignoredCodingPropertyNames
//{
//    return @[];
//}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)resetPropertyWithAccountManager:(ZWUserAccountManager *)manager
{
    if (manager) {
        self.currentUserInfo = manager.currentUserInfo;
    }
}

- (instancetype)init
{
    if (self = [super init]) {
        //获取缓存登录数据
        NSData *data = (NSData *)[ZWCommonUtil getObjectWithKey:KAccountSaveInfoKey];
        if (data) {
            ZWUserAccountManager *tempManager = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [self resetPropertyWithAccountManager:tempManager];
        }        
    }
    return self;
}

/**
 *  更新本地登录信息
 */
- (void)saveLoginStatusData
{
    //保存登录态现骨干信息
    ZWUserAccountManager *tradeConfig = self;
    NSData *archiverData = [NSKeyedArchiver archivedDataWithRootObject:tradeConfig];
    if (archiverData) {
        [ZWCommonUtil setObject:archiverData forKey:KAccountSaveInfoKey];
    }
}

/**
 *  清空本地登录信息
 */

- (void)cleanLoginStatusData
{
    [ZWCommonUtil setObject:nil forKey:KAccountSaveInfoKey];
}


@end
