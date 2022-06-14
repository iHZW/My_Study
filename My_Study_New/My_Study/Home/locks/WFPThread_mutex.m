//
//  WFPThread_mutex.m
//  My_Study
//
//  Created by HZW on 2021/9/4.
//  Copyright © 2021 HZW. All rights reserved.
//

#import "WFPThread_mutex.h"
#import <pthread/pthread.h>

@interface WFPThread_mutex ()

@property (nonatomic, assign) pthread_mutex_t ticketMutex;

@property (nonatomic, assign) pthread_mutex_t moneyMutex;

@end

@implementation WFPThread_mutex

- (id)copyWithZone:(NSZone *)zone
{
    WFPThread_mutex *mutex = [super copyWithZone:zone];
    mutex.mutex_id = self.mutex_id;
    return mutex;
}


- (void)__intMutex:(pthread_mutex_t *)mutex
{
    /** 初始化 pthread_mutexattr_t  属性 */
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    /** 设置 pthread_mutexattr_t 的 属性 */
    /**
     PTHREAD_MUTEX_RECURSIVE: 递归锁
     PTHREAD_MUTEX_NORMAL == PTHREAD_MUTEX_DEFAULT: 默认锁
     PTHREAD_MUTEX_ERRORCHECK: 错误锁
     */
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL);

    {
        /** 条件 */
        pthread_cond_t cond_t;
        pthread_cond_init(&cond_t, NULL);
        {
            /** 使用方法 */
//            /** 等待条件(进入休眠, 放开mutex锁, 被激活之后会在对mutex加锁) */
//            pthread_cond_wait(&cond_t, mutex);
//            /** 激活一个等待该条件的线程 */
//            pthread_cond_signal(&cond_t);
        }
        
        /** 销毁条件  */
        pthread_cond_destroy(&cond_t);
    }
    
    /** 初始化 pthread_mutex 互斥锁*/
    pthread_mutex_init(mutex, &attr);
    
    /** 销毁 pthread_mutexattr_t 属性 */
    pthread_mutexattr_destroy(&attr);
    

    /** 可以直接属性传 NULL 初始化 互斥锁 */
//    pthread_mutex_init(mutex, NULL);

}


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self __intMutex:&_ticketMutex];
        [self __intMutex:&_moneyMutex];
    }
    return self;
}

- (void)saleTicket
{
    pthread_mutex_lock(&_ticketMutex);
    [super saleTicket];
    pthread_mutex_unlock(&_ticketMutex);
}

- (void)buyTicket
{
    pthread_mutex_lock(&_ticketMutex);
    [super buyTicket];
    pthread_mutex_unlock(&_ticketMutex);
}

- (void)saveMoney
{
    pthread_mutex_lock(&_moneyMutex);
    [super saveMoney];
    pthread_mutex_unlock(&_moneyMutex);
}

- (void)fetchMoney
{
    pthread_mutex_lock(&_moneyMutex);
    [super fetchMoney];
    pthread_mutex_unlock(&_moneyMutex);
}

- (void)dealloc
{
    pthread_mutex_destroy(&_ticketMutex);
    pthread_mutex_destroy(&_moneyMutex);
}

@end
