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
        
        [self performSelector:@selector(startPlay) onThread:self.wf_thread withObject:nil waitUntilDone:NO];
        
    }
    return self;
}


- (void)startPlay
{
    NSLog(@"%s", __func__);
}

/*
 * OC RunLoop 启动保活
 */
- (void)keepSlive
{
    NSLog(@"%s -- %@", __func__, [NSThread currentThread]);

    /** OC 语法线程保活  */
    [self keepSliveForOC];
    
    /** C语法保活  */
//    [self keepSliveForC];
}

/**
 * OC 语法线程保活
 */
- (void)keepSliveForOC
{
    NSLog(@"%@ -- Game Start", NSStringFromClass([self class]));
   
    /** 方案一  可以保活但是无法时RunLoop停止 */
//    [[NSRunLoop currentRunLoop] addPort:[NSPort new] forMode:NSDefaultRunLoopMode];
//    [[NSRunLoop currentRunLoop] run];
    
    /** 方案二  */
    [[NSRunLoop currentRunLoop] addPort:[NSPort new] forMode:NSDefaultRunLoopMode];
    while (self &&!self.isStop) {
        /** 这个方法在没有任务时就睡眠  任务完成就退出 RunLoop  */
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    NSLog(@"%@ -- Game Over", NSStringFromClass([self class]));
}


/*
 * C语言 RunLoop 启动保活
 */
- (void)keepSliveForC
{
    NSLog(@"%s -- %@", __func__, [NSThread currentThread]);

    /** 创建上下文context {0} 初始化一个结构体 结构体里所有成员都初始化为0 */
    CFRunLoopSourceContext context = {0};
    /** 创建source */
    CFRunLoopSourceRef sources = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
    /** 添加source */
    CFRunLoopAddSource(CFRunLoopGetCurrent(), sources, kCFRunLoopDefaultMode);
    
    /** 销毁source  */
    CFRelease(sources);
    
    /** 启动runLoop */
//    while (self && !self.isStop) {
//        /** 第三个参数: 代表执行完source之后就会退出当前RunLoop */
//        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, true);
//    }
    
//    可以直接传 false  这样执行任务之后不会退出
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, false);
    
    NSLog(@"%@ -- Game Over", NSStringFromClass([self class]));
    
//
//    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
//
//        switch (activity) {
//            case kCFRunLoopEntry:
//                <#statements#>
//                break;
//
//            default:
//                break;
//        }
//    });

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
    // 停止RunLoop
    CFRunLoopStop(CFRunLoopGetCurrent());
    self.wf_thread = nil;
}

- (void)executeTask:(ExecuteTaskBlock)block
{
//    if (self.taskBlock) {
//        self.taskBlock(2);
//    }
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
    [self stop];
    NSLog(@"%s", __func__);
}

@end
