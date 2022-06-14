//
//  WFOSSPinLockDemo.m
//  My_Study
//
//  Created by HZW on 2021/9/4.
//  Copyright © 2021 HZW. All rights reserved.
//

#import "WFOSSPinLockDemo.h"
#import <libkern/OSAtomic.h>

@interface WFOSSPinLockDemo ()

@property (nonatomic, assign) OSSpinLock osspinLock;

@property (nonatomic, assign) OSSpinLock ticketOSSpinLock;

@property (nonatomic, assign) OSSpinLock testOSSpinLock;

@end

@implementation WFOSSPinLockDemo

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.osspinLock = OS_SPINLOCK_INIT;
        self.ticketOSSpinLock = OS_SPINLOCK_INIT;
        self.testOSSpinLock = OS_SPINLOCK_INIT;
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
    OSSpinLockLock(&_ticketOSSpinLock);

    [super buyTicket];

    OSSpinLockUnlock(&_ticketOSSpinLock);
}


- (void)saleTicket
{
    OSSpinLockLock(&_ticketOSSpinLock);

    [super saleTicket];

    OSSpinLockUnlock(&_ticketOSSpinLock);

}

- (void)saveMoney
{
    OSSpinLockLock(&_osspinLock);

    [super saveMoney];
    
    OSSpinLockUnlock(&_osspinLock);
}

- (void)fetchMoney
{
    OSSpinLockLock(&_osspinLock);

    [super fetchMoney];
    
    OSSpinLockUnlock(&_osspinLock);
}

@end
