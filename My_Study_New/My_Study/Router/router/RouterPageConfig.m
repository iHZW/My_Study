//
//  RouterPageModel.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "RouterPageConfig.h"
#import "JsonUtil.h"
#import "MJExtension.h"

/* -------------------------------tab----------------------------  */

NSString *const ZWTabIndexHome              = @"tab/index/home";
NSString *const ZWTabIndexApplication       = @"tab/index/application";
NSString *const ZWTabIndexCRM               = @"tab/index/crm";
NSString *const ZWTabIndexFind              = @"tab/index/find";
NSString *const ZWTabIndexPersonal          = @"tab/index/personal";

/* -------------------------------tab----------------------------  */


/* -------------------------------page----------------------------  */

NSString *const ZWRouterPageDebugLogHome             = @"debug/log/home";
NSString *const ZWRouterPageCommonWebView            = @"common/webView";
NSString *const ZWRouterPageSettingViewController    = @"setting/home";
NSString *const ZWRouterPageShowAlertViewController  = @"tools/show/alertview";
NSString *const ZWRouterPageChangeEnvViewController  = @"config/change/env";
/** 通用单选页  */
NSString *const ZWRouterPageSelectedViewController   = @"common/selected/page";
/** 地址微调页  */
NSString *const ZWRouterPageLocationTrimViewController = @"tools/location/trim/page";
/** 文件选择界面  */
NSString *const ZWRouterPageFileSelectViewController = @"tools/file/selectpage";
/* -------------------------------page----------------------------  */


@implementation RouterPageConfig

+ (NSDictionary *)mj_objectClassInArray{
    return @{
        @"pageItems" : @"RouterPageItem"
    };
}

+ (RouterPageConfig *)getDefaultRouterPageConfig
{
    NSDictionary *pageDict = @{
        @"pageItems" : @[
            /* -------------------------------tab----------------------------  */
            /** 首页  */
            @{
                @"url" : ZWTabIndexHome,
                @"clsName": @"HomeViewController",
                @"type" : @(RouterTypeNavigateTab),
                @"attachValue" : @{}
            },
            /** 应用  */
            @{
                @"url" : ZWTabIndexApplication,
                @"clsName": @"ApplicationViewController",
                @"type" : @(RouterTypeNavigateTab),
                @"attachValue" : @{}
            },
            /** CRM  */
            @{
                @"url" : ZWTabIndexCRM,
                @"clsName": @"CRMViewController",
                @"type" : @(0),
                @"attachValue" : @{}
            },
            /** 查找  */
            @{
                @"url" : ZWTabIndexFind,
                @"clsName": @"FindViewController",
                @"type" : @(RouterTypeNavigateTab),
                @"attachValue" : @{}
            },
            /** 个人中心  */
            @{
                @"url" : ZWTabIndexPersonal,
                @"clsName": @"PersonalViewController",
                @"type" : @(RouterTypeNavigateTab),
                @"attachValue" : @{}
            },
            
            /* -------------------------------page----------------------------  */
            /** 日志 首页  */
            @{
                @"url" : ZWRouterPageDebugLogHome,
                @"clsName": @"MDDebugViewController",
                @"type" : @(RouterTypeNavigate),
                @"attachValue" : @{}
            },
            /** 通用webView */
            @{
                @"url" : ZWRouterPageCommonWebView,
                @"clsName": @"ZWCommonWebPage",
                @"type" : @(RouterTypeNavigate),
                @"attachValue" : @{}
            },
            /** 设置界面  */
            @{
                @"url" : ZWRouterPageSettingViewController,
                @"clsName": @"SettingViewController",
                @"type" : @(RouterTypeNavigate),
                @"attachValue" : @{}
            },
            /** 展示AlertView的VC  */
            @{
                @"url" : ZWRouterPageShowAlertViewController,
                @"clsName": @"ShowAlertViewController",
                @"type" : @(RouterTypeNavigate),
                @"attachValue" : @{}
            },
//            /** 切换环境  */
            @{
                @"url" : ZWRouterPageChangeEnvViewController,
                @"clsName": @"ZWChangeEnvViewController",
                @"type" : @(RouterTypeNavigate),
                @"attachValue" : @{}
            },
//            /** 通用单选页  */
            @{
                @"url" : ZWRouterPageSelectedViewController,
                @"clsName": @"SelectedViewController",
                @"type" : @(RouterTypeNavigate),
                @"attachValue" : @{}
            },
            /** 地址微调页   */
            @{
                @"url" : ZWRouterPageLocationTrimViewController,
                @"clsName": @"LocationTrimViewController",
                @"type" : @(RouterTypeNavigate),
                @"attachValue" : @{}
            },
            /** 文件选择界面   */
            @{
                @"url" : ZWRouterPageFileSelectViewController,
                @"clsName": @"FileSelectViewController",
                @"type" : @(RouterTypeNavigate),
                @"attachValue" : @{}
            },
            
        ]
    };
        
    RouterPageConfig *routerPageConfig = [JSONUtil parseObject:pageDict targetClass:RouterPageConfig.class];
    return  routerPageConfig;
}

@end
