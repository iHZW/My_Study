//
//  WFOSSPinLockDemo.m
//  My_Study
//
//  Created by HZW on 2021/9/4.
//  Copyright © 2021 HZW. All rights reserved.
//

#import "WFOSSPinLockDemo.h"
#import <libkern/OSAtomic.h>
#import <os/lock.h>

@interface WFOSSPinLockDemo ()
{
    /** os_unfair_lock 替换 不安全的OSSpinLock 自旋锁  */
    os_unfair_lock _ticket_lock;
}

/** OSSpinLock  不推荐使用了,  被 os_unfair_lock 替换使用  */

//@property (nonatomic, assign) OSSpinLock osspinLock;
//
//@property (nonatomic, assign) OSSpinLock ticketOSSpinLock;
//
//@property (nonatomic, assign) OSSpinLock testOSSpinLock;

@end

@implementation WFOSSPinLockDemo

- (instancetype)init
{
    self = [super init];
    if (self) {
//        self.osspinLock = OS_SPINLOCK_INIT;
//        self.ticketOSSpinLock = OS_SPINLOCK_INIT;
//        self.testOSSpinLock = OS_SPINLOCK_INIT;
        _ticket_lock = OS_UNFAIR_LOCK_INIT;
    }
    return self;
}

//- (void)ticketTest
//{
//    OSSpinLockLock(&_testOSSpinLock);
//
//    [super ticketTest];
//    
//    OSSpinLockUnlock(&_testOSSpinLock);
//}

- (void)buyTicket
{
//    OSSpinLockLock(&_ticketOSSpinLock);
//
//    [super buyTicket];
//
//    OSSpinLockUnlock(&_ticketOSSpinLock);

    os_unfair_lock_lock(&_ticket_lock);
    [super buyTicket];
    os_unfair_lock_unlock(&_ticket_lock);
}


- (void)saleTicket
{
//    OSSpinLockLock(&_ticketOSSpinLock);
//
//    [super saleTicket];
//
//    OSSpinLockUnlock(&_ticketOSSpinLock);
    
    os_unfair_lock_lock(&_ticket_lock);
    [super saleTicket];
    os_unfair_lock_unlock(&_ticket_lock);
}

- (void)saveMoney
{
//    OSSpinLockLock(&_osspinLock);
//
//    [super saveMoney];
//
//    OSSpinLockUnlock(&_osspinLock);
    
    os_unfair_lock_lock(&_ticket_lock);
    [super saveMoney];
    os_unfair_lock_unlock(&_ticket_lock);
}

- (void)fetchMoney
{
//    OSSpinLockLock(&_osspinLock);
//
//    [super fetchMoney];
//
//    OSSpinLockUnlock(&_osspinLock);
    
    os_unfair_lock_lock(&_ticket_lock);
    [super fetchMoney];
    os_unfair_lock_unlock(&_ticket_lock);
}


/**
 * OSSpinLock'已弃用:在iOS 10.0中首次弃用-使用
 * os_unfair_lock() from &lt;os/lock.h&gt代替
 * 可能出现优先级翻转,
 * thread1\thread2\thread3\...
 * 线程调度.10ms
 * 存在线程优先级高的, 会多分配点儿时间做事情
 *
 * 时间片轮转调度算法 (进程,线程)  实现多线程的方案
 *
 * 1: 低优先级线程开始做事情  加锁
 * 2: 这时候优先级高的线程进来要处理事情 发现锁没有放开, 他就在这里一直忙等
 * 3:CPU分配大量资源给高优先级线程,没有分配时间给低优先级线程
 * 4:这样低优先级线程没办法释放锁, 就导致了线程死锁现象
 *
 */
- (void)testOSSpinLock
{
    OSSpinLock lock = OS_SPINLOCK_INIT;

    OSSpinLockLock(&lock);
    NSLog(@"---testOSSpinLock----");
    OSSpinLockUnlock(&lock);
    
    /** 尝试加锁, 加锁失败不执行操作,也不会阻塞线程  */
    if (OSSpinLockTry(&lock)) {
        
    }
}



@end
