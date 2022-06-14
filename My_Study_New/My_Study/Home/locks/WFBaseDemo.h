//
//  WFBaseDemo.h
//  My_Study
//
//  Created by HZW on 2021/9/4.
//  Copyright © 2021 HZW. All rights reserved.
//

/*
 * iOS 中的锁性能排序如下
 * os_unfair_lock
 * OSSpinkLock
 * dispatch_semaphore        -----------(推荐使用)
 * pthread_mutex(NULL 默认锁) -----------(推荐使用)
 * dispatch_queue(DISPATCH_QUEUE_SERIAL)
 * NSLock (对pthread_mutex 默认锁的封装)
 * NSCondition
 * pthread_mutex(recursive)(递归锁 性能普遍低)
 * NSRecursiveLock(对 pthread_mutex(recursive) 的封装)
 * NSConditionLock
  */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WFBaseDemo : NSObject<NSCopying>

@property (nonatomic, copy) NSString *demo_id;

/** 卖票测试 */
- (void)ticketTest;

/** 存取钱测试 */
- (void)moneyTest;


/** 卖票 */
- (void)saleTicket;
/** 买票 */
- (void)buyTicket;
/** 存钱 */
- (void)saveMoney;
/** 取钱 */
- (void)fetchMoney;

@end

NS_ASSUME_NONNULL_END
