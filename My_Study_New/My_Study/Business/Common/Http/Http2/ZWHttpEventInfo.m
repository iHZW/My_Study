//
//  ZWHttpEventInfo.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWHttpEventInfo.h"

const CGFloat DefaultTimeoutInterval = 15.0; // 默认超时时间

@implementation ZWHttpEventInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        self.timeoutInterval  = DefaultTimeoutInterval;
        self.cachePolicy      = NSURLRequestReloadIgnoringCacheData;
        self.progressMaskType = HttpProgressMaskTypeNone;
    }
    return self;
}

@end
