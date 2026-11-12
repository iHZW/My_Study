//
//  BaseRouterIntercept.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "BaseRouterIntercept.h"

@implementation BaseRouterIntercept

- (RouterParam *)doIntercept:(RouterParam *)routerParam
{
    return routerParam;
}

- (NSInteger)interceptPriority
{
    return 1000;
}

@end


@implementation NSError (RouterIntercept)

+ (NSError *)defaultBreakError
{
    NSError *error = [NSError errorWithDomain:@"RouterIntercept" code:-1 userInfo:nil];
    return error;
}

@end
