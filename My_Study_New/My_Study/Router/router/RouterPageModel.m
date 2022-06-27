//
//  RouterPageModel.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "RouterPageModel.h"
#import "JsonUtil.h"
#import "MJExtension.h"

/* -------------------------------tab----------------------------  */

NSString const *ZWTabIndexHome              = @"tab/index/home";
NSString const *ZWTabIndexApplication       = @"tab/index/application";
NSString const *ZWTabIndexFind              = @"tab/index/find";
NSString const *ZWTabIndexPersonal          = @"tab/index/personal";

/* -------------------------------tab----------------------------  */


/* -------------------------------page----------------------------  */

NSString const *ZWDebugPageHome              = @"debug/log/home";


/* -------------------------------page----------------------------  */


@implementation RouterPageModel

+ (NSDictionary *)mj_objectClassInArray{
    return @{
        @"configs" : @"RouterPageConfig"
    };
}

+ (RouterPageModel *)getDefaultRouterPageModel
{
    NSDictionary *pageDict = @{
        @"configs" : @[
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
            
            /** 日志 首页  */
            @{
                @"url" : ZWDebugPageHome,
                @"clsName": @"MDDebugViewController",
                @"type" : @(0),
                @"attachValue" : @{}
            }
//            ,
//            @{
//                @"url" : @"",
//                @"clsName": PASAppSiteCTKey,
//                @"type" : @(0),
//                @"attachValue" : @{}
//            },
//            @{
//                @"url" : @"",
//                @"clsName": PASAppSiteCTKey,
//                @"type" : @(0),
//                @"attachValue" : @{}
//            },
//            @{
//                @"url" : @"",
//                @"clsName": PASAppSiteCTKey,
//                @"type" : @(0),
//                @"attachValue" : @{}
//            },
        ]
    };
        
    RouterPageModel *pageModel = [JSONUtil parseObject:pageDict targetClass:RouterPageModel.class];
    return  pageModel;
}

@end
