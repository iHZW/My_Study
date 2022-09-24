//
//  WFPermanentThread.h
//  My_Study
//
//  Created by HZW on 2021/9/4.
//  Copyright © 2021 HZW. All rights reserved.
//

/*
 * 使用限制
 * 1: 串行队列, 非并发
 * 2: 需要在子线程做事儿, 就不用频繁创建线程
 */

#import <Foundation/Foundation.h>

typedef void(^ExecuteTaskBlock) (NSInteger index);

NS_ASSUME_NONNULL_BEGIN

@interface WFPermanentThread : NSObject

- (void)start;

/** 可以主动停止当前子线程 */
- (void)stop;

/** 在当前子线程执行任务 */
- (void)executeTask:(ExecuteTaskBlock)block;

@end

NS_ASSUME_NONNULL_END
