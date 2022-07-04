//
//  WFPermanentThread.m
//  My_Study
//
//  Created by HZW on 2021/9/4.
//  Copyright © 2021 HZW. All rights reserved.
//

/** 保活线程 */

#import "WFPermanentThread.h"
#import "WFThread.h"
#import "YYKit/YYKit.h"


@interface WFPermanentThread ()

@property (nonatomic, strong) WFThread *wf_thread;

/** 是否停止保活, 默认NO: 保活 */
@property (nonatomic, assign) BOOL isStop;
 
@property (nonatomic, copy) ExecuteTaskBlock taskBlock;

@end

@implementation WFPermanentThread


- (instancetype)init
{
    if (self = [super init]) {
        self.isStop = NO;
        self.wf_thread = [[WFThread alloc] initWithTarget:[YYWeakProxy proxyWithTarget:self] selector:@selector(keepSlive) object:nil];
        
//        @pas_weakify_self
//        self.wf_thread = [[WFThread alloc] initWithBlock:^{
//            @pas_strongify_self
//            [self keepSlive];
//        }];
        
        
        
    }
    return self;
}

/*
 * OC RunLoop 启动保活
 */
- (void)keepSlive
{
//    NSLog(@"%s -- %@", __func__, [NSThread currentThread]);
//
//    NSLog(@"%@ -- Game Start", NSStringFromClass([self class]));
//    [[NSRunLoop currentRunLoop] addPort:[NSPort new] forMode:NSDefaultRunLoopMode];
//    while (!self.isStop && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
//    }
//
//    NSLog(@"%@ -- Game Over", NSStringFromClass([self class]));
    
    [self keepSliveForC];
}

/*
 * C语言 RunLoop 启动保活
 */
- (void)keepSliveForC
{
    NSLog(@"%s -- %@", __func__, [NSThread currentThread]);

    /** 创建上下文context {0} 初始化一个结构体 */
    CFRunLoopSourceContext context = {0};
    /** 创建source */
    CFRunLoopSourceRef sources = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
    /** 添加source */
    CFRunLoopAddSource(CFRunLoopGetCurrent(), sources, kCFRunLoopDefaultMode);
    /** 启动runLoop */
    while (!self.isStop) {
        /** 第三个参数: 代表执行完source之后就会退出当前RunLoop */
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, true);
    }
    
    NSLog(@"%@ -- Game Over", NSStringFromClass([self class]));

}

- (void)start
{
    [self.wf_thread start];
    NSLog(@"%s", __func__);
}

- (void)stop
{
    [self performSelector:@selector(endThread) onThread:self.wf_thread withObject:nil waitUntilDone:NO];
    NSLog(@"%s", __func__);
}

/** 结束当前子线程 */
- (void)endThread
{
    self.isStop = YES;
    CFRunLoopStop(CFRunLoopGetCurrent());
    self.wf_thread = nil;
}

- (void)executeTask:(ExecuteTaskBlock)block
{
    if (self.taskBlock) {
        self.taskBlock(2);
    }
    self.taskBlock = block;
    NSLog(@"%s -- %@", __func__, [NSThread currentThread]);
//    [self performSelector:@selector(ececuteTaskOnDefaultThread:) onThread:self.wf_thread withObject:block waitUntilDone:NO];
    [self performSelector:@selector(executeTaskBlock) onThread:self.wf_thread withObject:nil waitUntilDone:NO];
}


- (void)ececuteTaskOnDefaultThread:(ExecuteTaskBlock)block
{
    NSLog(@"%s -- %@", __func__, [NSThread currentThread]);
    if (block) {
        block(1);
    }
}

- (void)executeTaskBlock
{
    NSLog(@"%s -- %@", __func__, [NSThread currentThread]);
    if (self.taskBlock) {
        self.taskBlock(1);
    }
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

@end
