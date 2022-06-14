//
//  WFBaseDemo.m
//  My_Study
//
//  Created by HZW on 2021/9/4.
//  Copyright © 2021 HZW. All rights reserved.
//

#import "WFBaseDemo.h"


@interface WFBaseDemo ()

@property (nonatomic, assign) NSInteger ticketCount;

@property (nonatomic, assign) NSInteger totalMoney;

/*
 * atom: 原子. 不可再分割的最小单位
 * atomic: 原子性
 * noatomic: 非原子性
 * 给属性添加atomic修饰, 可以保证属性的setter和getter都是原子性操作, 相当于属性内部的setter和getter添加了线程同步锁
 * (NSSMutableArray  设置atomic,  只能保证 setArray getArray 的时候是线程安全的,但是 进行 addObjec/removeObjec等操作的时候不是线程安全的) 设置atomic时 非常消耗性能,
 */
@property (atomic, assign) int age;

@end

@implementation WFBaseDemo

- (instancetype)init
{
    if (self = [super init]) {
        self.ticketCount = 10;
//        self.totalMoney = 100;
        
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    WFBaseDemo *demo = [[WFBaseDemo alloc] copyWithZone:zone];
    demo.demo_id = self.demo_id;
    return demo;
}

/** 卖票 */
- (void)ticketTest
{
//    self.ticketCount = 300;
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 100; i++) {
            [self saleTicket];
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 100; i++) {
            [self buyTicket];
        }
    });
}

//- (void)setTicketCount:(NSInteger)ticketCount
//{
//    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
//    _ticketCount = ticketCount;
//    dispatch_semaphore_signal(self.semaphore);
//}

/** 卖票 */
- (void)saleTicket
{
    NSInteger oldCount = self.ticketCount;
    oldCount--;
    self.ticketCount = oldCount;
    NSLog(@"剩余%@张票 -- %@", @(oldCount),[NSThread currentThread]);
}

/** 买票 */
- (void)buyTicket
{
    NSInteger oldCount = self.ticketCount;
    oldCount++;
    self.ticketCount = oldCount;
    NSLog(@"剩余%@张票 -- %@", @(oldCount),[NSThread currentThread]);
}



/** 存取钱测试 */
- (void)moneyTest
{
    self.totalMoney = 100;
    dispatch_queue_t queue = dispatch_queue_create("money_queue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 5; i++) {
            [self fetchMoney];
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            [self saveMoney];
        }
    });
}



/** 存钱 */
- (void)saveMoney
{
    NSInteger oldCount = self.totalMoney;
    oldCount += 50;
    self.totalMoney = oldCount;
    NSLog(@"剩余%@money -- %@", @(oldCount),[NSThread currentThread]);
}



/** 取钱 */
- (void)fetchMoney
{
    NSInteger oldCount = self.totalMoney;
    oldCount -= 20;
    self.totalMoney = oldCount;
    NSLog(@"剩余%@money -- %@", @(oldCount),[NSThread currentThread]);
}

@end
