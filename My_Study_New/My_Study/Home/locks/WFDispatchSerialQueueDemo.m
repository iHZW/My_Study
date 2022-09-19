//
//  WFDispatchSerialQueueDemo.m
//  My_Study
//
//  Created by HZW on 2021/9/4.
//  Copyright © 2021 HZW. All rights reserved.
//

#import "WFDispatchSerialQueueDemo.h"
#import "ZWSDK.h"

@interface WFDispatchSerialQueueDemo ()

@property (nonatomic, strong) dispatch_queue_t serial_queue;

@property (nonatomic, strong) dispatch_semaphore_t semaphore_t;

@property (nonatomic, strong) dispatch_semaphore_t ticket_lock;

@end

@implementation WFDispatchSerialQueueDemo

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.serial_queue = dispatch_queue_create("serial_queue", DISPATCH_QUEUE_SERIAL);
        self.semaphore_t = dispatch_semaphore_create(1);
        
        self.ticket_lock = dispatch_semaphore_create(1);
    }
    return self;
}


- (void)ticketTest
{
    [super ticketTest];
}


- (void)saleTicket
{
//    dispatch_semaphore_wait(self.semaphore_t, DISPATCH_TIME_FOREVER);
//    [super saleTicket];
//    dispatch_semaphore_signal(self.semaphore_t);
    
    ZW_LOCK(self.ticket_lock);
    [super saleTicket];
    ZW_UNLOCK(self.ticket_lock);
}

- (void)buyTicket
{
//    dispatch_semaphore_wait(self.semaphore_t, DISPATCH_TIME_FOREVER);
//    [super buyTicket];
//    dispatch_semaphore_signal(self.semaphore_t);
    
    ZW_LOCK(self.ticket_lock);
    [super buyTicket];
    ZW_UNLOCK(self.ticket_lock);
}




@end
