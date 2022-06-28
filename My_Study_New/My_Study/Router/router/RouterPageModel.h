//
//  RouterPageModel.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouterPageConfig.h"
#import "ZWHttpNetworkData.h"

@class RouterPageConfig;

NS_ASSUME_NONNULL_BEGIN

/* -------------------------------tab----------------------------  */
/** 首页  */
extern NSString *_Nullable ZWTabIndexHome;
/** 应用  */
extern NSString *_Nullable ZWTabIndexApplication;
/** CRM  */
extern NSString *_Nullable ZWTabIndexCRM;
/** 查找  */
extern NSString *_Nullable ZWTabIndexFind;
/** 个人中心  */
extern NSString *_Nullable ZWTabIndexPersonal;

/* -------------------------------tab----------------------------  */

/* -------------------------------page----------------------------  */
#pragma mark - log
/** 日志首页  */
extern NSString *_Nullable ZWDebugPageHome;
/** 通用webView  */
extern NSString *_Nullable ZWCommonWebViewPage;

/* -------------------------------page----------------------------  */


/** 路由界面配置  */
@interface RouterPageModel :ZWHttpNetworkData

@property (nonatomic, copy) NSArray<RouterPageConfig *> *configs;

+ (RouterPageModel *)getDefaultRouterPageModel;

@end

NS_ASSUME_NONNULL_END
