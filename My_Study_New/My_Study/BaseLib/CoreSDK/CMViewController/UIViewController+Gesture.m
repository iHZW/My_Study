//
//  UIViewController+Gesture.m
//  PASecuritiesApp
//
//  Created by Howard on 16/8/24.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "UIViewController+Gesture.h"
#import <objc/runtime.h>

static const char *NavAnimatingStatusKey = "NavAnimatingStatus";

@implementation UIViewController (Gesture)
@dynamic disableScreenEdgeGesture;
@dynamic navAnimatingStatus;


- (BOOL)disableScreenEdgeGesture
{
    id f = objc_getAssociatedObject(self, @selector(disableScreenEdgeGesture));
    return [f boolValue];
}

- (void)setDisableScreenEdgeGesture:(BOOL)disableScreenEdgeGesture
{
    objc_setAssociatedObject(self, @selector(disableScreenEdgeGesture), @(disableScreenEdgeGesture), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)navAnimatingStatus
{
    NSNumber *val = objc_getAssociatedObject(self, NavAnimatingStatusKey);
    
    return [val boolValue];
}

- (void)setNavAnimatingStatus:(BOOL)value
{
    objc_setAssociatedObject(self, NavAnimatingStatusKey, @(value), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
