//
//  WFPThread_mutex.h
//  My_Study
//
//  Created by HZW on 2021/9/4.
//  Copyright © 2021 HZW. All rights reserved.
//

/** 互斥锁, 递归锁, 条件锁, 都是pthread_mutex */

#import "WFBaseDemo.h"

NS_ASSUME_NONNULL_BEGIN

@interface WFPThread_mutex : WFBaseDemo<NSCopying>

@property (nonatomic, copy) NSString *mutex_id;

@end

NS_ASSUME_NONNULL_END
