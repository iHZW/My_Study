//
//  NSObject+Params.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "NSObject+Params.h"
#import <objc/runtime.h>

@implementation NSObject (Params)

- (void)setRouterParamObject:(RouterParam *)routerParamObject{
    objc_setAssociatedObject(self, @selector(routerParamObject), routerParamObject, OBJC_ASSOCIATION_RETAIN);
}

- (RouterParam *)routerParamObject{
    return objc_getAssociatedObject(self, @selector(routerParamObject));
}

- (void)setRouterParams:(NSDictionary *)params{
    objc_setAssociatedObject(self, @selector(routerParams), params, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)routerParams{
    return objc_getAssociatedObject(self, @selector(routerParams));
}

@end
