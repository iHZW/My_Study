//
//  ZWCacheManager.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/12.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWCacheManager.h"

@implementation ZWCacheManager

+ (ZWCacheManager *)shared{
    static ZWCacheManager * _manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[ZWCacheManager alloc] init];
    });
    return _manager;
}

- (instancetype)init{
    if (self = [super init]) {
    }
    return self;
}

- (void)dealloc{
    
}

@end
