//
//  WFDispatchSerialQueueDemo.m
//  My_Study
//
//  Created by HZW on 2021/9/4.
//  Copyright © 2021 HZW. All rights reserved.
//

#import "WFDispatchSerialQueueDemo.h"

@interface WFDispatchSerialQueueDemo ()

@property (nonatomic, strong) dispatch_queue_t serial_queue;

@property (nonatomic, strong) dispatch_semaphore_t semaphore_t;

@end

@implementation WFDispatchSerialQueueDemo

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.serial_queue = dispatch_queue_create("serial_queue", DISPATCH_QUEUE_SERIAL);
        self.semaphore_t = dispatch_semaphore_create(1);
    }
    return self;
}


- (void)ticketTest
{
    [super ticketTest];
}



- (void)saleTicket
{
    dispatch_semaphore_wait(self.semaphore_t, DISPATCH_TIME_FOREVER);
    [super saleTicket];
    dispatch_semaphore_signal(self.semaphore_t);
}

- (void)buyTicket
{
    dispatch_semaphore_wait(self.semaphore_t, DISPATCH_TIME_FOREVER);
    [super buyTicket];
    dispatch_semaphore_signal(self.semaphore_t);
}




@end
