//
//  UIImage+None.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "UIImage+None.h"
#import <objc/runtime.h>
#import "NSObject+Customizer.h"

@implementation UIImage (None)

+ (void)load {
    [self swizzleClassMethods:[UIImage class] originalSelector:@selector(imageNamed:) swizzledSelector:@selector(wmm_none_imageNamed:)];
    if (@available(iOS 13.0, *)) {
        [self swizzleClassMethods:[UIImage class] originalSelector:@selector(imageNamed:inBundle:withConfiguration:) swizzledSelector:@selector(wmm_none_imageNamed:inBundle:withConfiguration:)];
    }
    [self swizzleClassMethods:[UIImage class] originalSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:) swizzledSelector:@selector(wmm_none_imageNamed:inBundle:compatibleWithTraitCollection:)];
}

+ (nullable UIImage *)wmm_none_imageNamed:(NSString *)name {
    if (ValidString(name)) { // 判断是否为空的方法
        return [self wmm_none_imageNamed:name];
    } else {
        return nil;
    }
}

+ (nullable UIImage *)wmm_none_imageNamed:(NSString *)name inBundle:(nullable NSBundle *)bundle withConfiguration:(nullable UIImageConfiguration *)configuration  API_AVAILABLE(ios(13.0)){
    if (ValidString(name)) { // 判断是否为空的方法
        return [self wmm_none_imageNamed:name inBundle:bundle withConfiguration:configuration];
    } else {
        return nil;
    }
}

+ (nullable UIImage *)wmm_none_imageNamed:(NSString *)name inBundle:(nullable NSBundle *)bundle compatibleWithTraitCollection:(nullable UITraitCollection *)traitCollection {
    if (ValidString(name)) { // 判断是否为空的方法
        return [self wmm_none_imageNamed:name inBundle:bundle compatibleWithTraitCollection:traitCollection];
    } else {
        return nil;
    }
}


@end
