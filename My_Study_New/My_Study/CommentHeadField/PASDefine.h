//
//  PASDefine.h
//  PASecuritiesApp
//
//  Created by vince on 16/3/15.
//  Copyright © 2016年 PAS. All rights reserved.
//

#ifndef PASDefine_h
#define PASDefine_h

#import "NSObject+UUID.h"
//#import "PASNavigator.h"

/**
 *  URL identifier
 */
#define kPASURLId       @"com.pingan.stock"

/**
 *  安e理财Scheme命令
 */
#define kPASchemeName   [[PASNavigator sharedPASNavigator] schemeNameWithURLId:kPASURLId]

/**
 *  开启布点
 */
#define TALKINGDATA_ENABLED

/**
 *  ZW域名
 */
#define kPASchemeHost   @"zw.scheme.com"

#define kPAAppName      @"ZWApp"

#define SYS_CLIENTVER   [PASSiteAddressManager appVersion]

#ifndef APPSTORE_ONLY

#define __BACKDOOR

#endif

#define Environment [PASSiteAddressManager getCurrentEnvironment]

/**
 *  新版本Rest接口请求 requestId 定义
 */
#define kRequestId      [NSString stringWithFormat:@"ZWAPP%@", [NSObject shortUUIDString]]

#define KAccountSaveInfoKey                 @"accountSaveInfoKey"
#define KNotificationWithLogoutName         @"UserLogoutNotification"
#define KNotificationWithLoginName          @"UserLoginNotification"
#define KNotificationWithShowSecondLogin    @"UserLoginShowSecondLogin"
#define KSuspendNotificationRefreshName @"suspendRefreshingNotification"

#define KNotificationHomeBGImgShow   @"homeIconBackgroundImageShow" // 6.17version 首页营销图控制是显示
#define KNotificationHomeBGImgHidden   @"homeIconBackgroundImageHidden" // 6.17version 首页营销图控制否显示

#define USERSERVICERSA_ENABLED      // 账户体系是否进行RSA加密处理


#endif /* PASDefine_h */
