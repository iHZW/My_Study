//
//  NSObject+ZWDeallocExecutor.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/1.
//  Copyright © 2022 HZW. All rights reserved.
//
/** dealloc 释放 回调 */
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ZWDeallocExecutor)


- (void)zw_executeAtDealloc:(void (^)(void))block;

@end

NS_ASSUME_NONNULL_END
