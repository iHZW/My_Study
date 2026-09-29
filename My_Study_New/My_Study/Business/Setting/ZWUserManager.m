//
//  ZWUserManager.m
//  My_Study
//
//  Created by hzw on 2023/2/15.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "ZWUserManager.h"

@implementation ZWUserManager

+ (instancetype)sharedInstance {
    // 静态局部变量
    static ZWUserManager *instance = nil;
    // 通过dispatch_once方式, 确保instance在多线程环境下只被创建一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 调用父类的方法创建实例, 防止跟重写自身的allocWithZone发生循环调用
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

/// 重写自身的allocWithZone, 应对不使用sharedInstance方法直接通过alloc创建对象的情况
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (id)copy {
    return [self.class sharedInstance];
}

- (id)mutableCopy {
    return [self.class sharedInstance];
}

+ (id)copy {
    return [self.class sharedInstance];
}

+ (id)mutableCopy {
    return [self.class sharedInstance];
}

@end
