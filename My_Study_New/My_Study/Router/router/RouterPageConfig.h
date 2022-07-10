//
//  RouterPageModel.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouterPageItem.h"
#import "ZWHttpNetworkData.h"

@class RouterPageItem;

NS_ASSUME_NONNULL_BEGIN

/* -------------------------------tab----------------------------  */
/** 首页  */
UIKIT_EXTERN NSString *const ZWTabIndexHome;
/** 应用  */
UIKIT_EXTERN NSString *const ZWTabIndexApplication;
/** CRM  */
UIKIT_EXTERN NSString *const ZWTabIndexCRM;
/** 查找  */
UIKIT_EXTERN NSString *const ZWTabIndexFind;
/** 个人中心  */
UIKIT_EXTERN NSString *const ZWTabIndexPersonal;

/* -------------------------------tab----------------------------  */

/* -------------------------------page----------------------------  */
#pragma mark - log
/** 日志首页  */
UIKIT_EXTERN NSString *const ZWRouterPageDebugLogHome;
/** 通用webView  */
UIKIT_EXTERN NSString *const ZWRouterPageCommonWebView;
/** 设置界面  */
UIKIT_EXTERN NSString *const ZWRouterPageSettingViewController;
/** AlertView 使用页  */
UIKIT_EXTERN NSString *const ZWRouterPageShowAlertViewController;
/** 切换环境  */
UIKIT_EXTERN NSString *const ZWRouterPageChangeEnvViewController;
/** 通用单选页  */
UIKIT_EXTERN NSString *const ZWRouterPageSelectedViewController;
/** 地址微调页  */
UIKIT_EXTERN NSString *const ZWRouterPageLocationTrimViewController;

/* -------------------------------page----------------------------  */


/** 路由界面配置  */
@interface RouterPageConfig :ZWHttpNetworkData

@property (nonatomic, copy) NSArray<RouterPageItem *> *pageItems;

+ (RouterPageConfig *)getDefaultRouterPageConfig;

@end

NS_ASSUME_NONNULL_END
