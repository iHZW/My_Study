//
//  WF_os_unfair_loack_demo.m
//  My_Study
//
//  Created by HZW on 2021/9/4.
//  Copyright © 2021 HZW. All rights reserved.
//

#import "WF_os_unfair_loack_demo.h"
#import <os/lock.h>

@interface WF_os_unfair_loack_demo ()
{
    os_unfair_lock _lock;
}

@property (nonatomic, strong) NSLock *nslock;

@end

@implementation WF_os_unfair_loack_demo

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.nslock = [NSLock new];
        _lock = OS_UNFAIR_LOCK_INIT;
    }
    return self;
}


- (void)saleTicket
{
    os_unfair_lock_lock(&_lock);
    [super saleTicket];
    os_unfair_lock_unlock(&_lock);
    
//    [self.nslock lock];
//    [super saleTicket];
//    [self.nslock unlock];
}

- (void)buyTicket
{
    os_unfair_lock_lock(&_lock);
    [super buyTicket];
    os_unfair_lock_unlock(&_lock);
    
//    [self.nslock lock];
//    [super buyTicket];
//    [self.nslock unlock];
}

@end
