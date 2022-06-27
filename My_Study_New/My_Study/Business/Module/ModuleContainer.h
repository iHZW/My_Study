//
//  ModuleContainer.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/17.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingletonTemplate.h"
#import "HttpClient.h"
#import "RouterParam.h"
#import "RouterPageModel.h"

#define ZWM   [ModuleContainer sharedModuleContainer]

NS_ASSUME_NONNULL_BEGIN


@interface ModuleContainer : NSObject
DEFINE_SINGLETON_T_FOR_HEADER(ModuleContainer)

@property (nonatomic, strong, readonly) HttpClient *http;

- (void)registerConfig;

/**
 *  根据路由查找 RouterParam
 *
 *  @param route    路由
 *
 */
- (RouterParam *)findRouterParam:(NSString *)route;

/**
 *  根据类名查找 RouterPageConfig
 *
 *  @param clsName    类名
 *
 */
- (RouterPageConfig *)findRouterPageConfig:(NSString *)clsName;

@end


NS_ASSUME_NONNULL_END
