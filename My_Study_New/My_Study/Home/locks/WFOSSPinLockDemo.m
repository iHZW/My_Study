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

@end
