//
//  BaseRouterIntercept.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//
/** 拦截器  */
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseRouterIntercept : NSObject

- (RouterParam *)doIntercept:(RouterParam *)routerParam;

//越小越优先 (默认1000)
- (NSInteger)interceptPriority;

@end


@interface NSError (RouterIntercept)
//默认不继续执行路由
+ (NSError *)defaultBreakError;
@end

NS_ASSUME_NONNULL_END
