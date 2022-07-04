//
//  RunLoopViewController.m
//  My_Study
//
//  Created by HZW on 2021/9/2.
//  Copyright © 2021 HZW. All rights reserved.
//

#import "RunLoopViewController.h"
#import "WFThread.h"
#import "YYKit.h"
#import "RunLoopPermanentViewController.h"
#import <libkern/OSAtomic.h> // OSSpinLock 自旋锁需要导入头文件
#import "WFOSSPinLockDemo.h"
#import "WFPThread_mutex.h"
#import "WFDispatchSerialQueueDemo.h"
#import "WF_os_unfair_loack_demo.h"
#import "PThread_rwLock.h"
#import "DispatchBarrierPage.h"
#import "DisplayLinkViewController.h"

/** 测试iOS锁  */

@interface RunLoopViewController ()
{
    /** 信号量 */
    dispatch_semaphore_t _semaphore_lock;
}

@property (nonatomic, strong) WFThread *wf_thread;

@property (nonatomic, assign) BOOL isLoop;

@property (nonatomic, strong) NSPort *port;

@property (nonatomic, assign) NSInteger ticketCount;

@property (nonatomic, strong) NSLock *lock;

@property (nonatomic, strong) NSLock *lock2;

@property (nonatomic, assign) OSSpinLock ossLock;

@property (nonatomic, strong) WFOSSPinLockDemo *osspinLockDemo;

@property (nonatomic, strong) WFDispatchSerialQueueDemo *queueDemo;

@property (nonatomic, strong) WF_os_unfair_loack_demo *os_unfair_demo;

@property (nonatomic, strong) WFPThread_mutex *mutex_demo;

@property (nonatomic, strong) dispatch_queue_t queue_t;

@end

@implementation RunLoopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0xeeeeee);
    self.isLoop = YES;
    
    self.lock = [[NSLock alloc] init];
    self.lock2 = [[NSLock alloc] init];
    
    /** 初始化 */
    _semaphore_lock = dispatch_semaphore_create(1);
    
    self.ossLock = OS_SPINLOCK_INIT;
    // Do any additional setup after loading the view.
    
    self.wf_thread = [[WFThread alloc] initWithTarget:[YYWeakProxy proxyWithTarget:self] selector:@selector(keepAlive) object:nil];
    
    self.port = [[NSPort alloc] init];
    
    self.queue_t = dispatch_queue_create("queueu_t", DISPATCH_QUEUE_SERIAL);
    
//    @pas_weakify_self
//    self.wf_thread =  [[WFThread alloc] initWithBlock:^{
//        @pas_strongify_self
//
////        NSLog(@"线程保活 currentThread = %@", [NSThread currentThread]);
////        [[NSRunLoop currentRunLoop] addPort:[NSPort new] forMode:NSDefaultRunLoopMode];
//////        [[NSRunLoop currentRunLoop] run];
////        while (self.isLoop && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
////        }
////        NSLog(@"Game over");
//
//        [self keepAlive];
//    }];
    
    [self.wf_thread start];
    
    NSArray *testNameArray = @[@"GCDAction",  @"自旋锁OSSpinLock", @"互斥锁pthread_mutex", @"串行队列serial_queue", @"高性能os_unfair_lock", @"IO安全pthread_rwLock", @"栅栏函数dispatch_barrier", @"测试displayLink"];
    NSArray *selNameArray = @[@"GCDAction", @"osspinLockTest", @"pthread_mutex_test", @"serialQueue", @"os_unfair_demo_test", @"pthread_rwLock", @"dispatch_barrier", @"displayLinkTest"];
    
    for (int i = 0; i < testNameArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(100, 100 + 80 *i, 200, 60);
        btn.backgroundColor = [UIColor blueColor];
        [btn setTitle:testNameArray[i] forState:UIControlStateNormal];
        SEL sel = NSSelectorFromString(selNameArray[i]);
        [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
}

- (void)GCDAction
{
    
    /** 并发队列 */
//    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    /** 串行队列 */
//    dispatch_queue_t queue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_SERIAL);
    /** 并发队列 */
    dispatch_queue_t queue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT);
    
//    dispatch_sync(queue, ^{
//        for (int i = 0; i < 10; i++) {
//            NSLog(@"执行任务一: %@", [NSThread currentThread]);
//        }
//    });
//
//    dispatch_sync(queue, ^{
//        for (int i = 0; i < 10; i++) {
//            NSLog(@"执行任务二: %@", [NSThread currentThread]);
//        }
//    });
    
    
    dispatch_async(queue, ^{
        
        NSLog(@"1: %@", [NSThread currentThread]);
        
        /** 不执行的原因: 子线程RunLoop默认关闭 */
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//        NSLog(@"2: %@", [NSThread currentThread]);
        [self performSelector:@selector(test) withObject:nil afterDelay:.0];

        NSLog(@"3: %@", [NSThread currentThread]);
    });
    
    dispatch_queue_t group_queue = dispatch_queue_create("my_thread", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group =  dispatch_group_create();
    dispatch_group_async(group, group_queue, ^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"111: %@", [NSThread currentThread]);
        }
    });
    
    dispatch_group_async(group, group_queue, ^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"222: %@", [NSThread currentThread]);
        }
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"333: %@", [NSThread currentThread]);
        }
    });

}

- (void)test{
    NSLog(@"2: %@", [NSThread currentThread]);
}





- (void)keepAlive
{
//    NSLog(@"线程保活 currentThread = %@", [NSThread currentThread]);
//    [[NSRunLoop currentRunLoop] addPort:[NSPort new] forMode:NSDefaultRunLoopMode];
//
//    /** 如果不想退出runloop可以使用第一种方式启动 run */
//    [[NSRunLoop currentRunLoop] run];
//
//    /** 使用第二种方式启动runloop，可以通过设置超时时间来退出 */
//    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
//
//    /** 使用第三种方式启动runloop，可以通过设置超时时间或者使用CFRunLoopStop方法来退出。 */
//    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//
//    NSLog(@"Game over");
    
    NSLog(@"线程保活 currentThread = %@", [NSThread currentThread]);
    [[NSRunLoop currentRunLoop] addPort:self.port forMode:NSDefaultRunLoopMode];
//        [[NSRunLoop currentRunLoop] run];
    while (self.isLoop && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    NSLog(@"Game over");
}

- (void)stop{
    NSLog(@"%sm --- %@", __func__, [NSThread currentThread]);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self performSelector:@selector(stop) onThread:self.wf_thread withObject:nil waitUntilDone:NO];
    
    [ZWM.router executeURL:ZWTabIndexFind];
//    [self.navigationController pushViewController:[RunLoopPermanentViewController new] animated:YES];
}



- (void)dealloc{
    NSLog(@"%s", __func__);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self performSelector:@selector(endThread) onThread:self.wf_thread withObject:nil waitUntilDone:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self keepAlive];
}

- (void)endThread
{
    self.isLoop = NO;
    CFRunLoopStop(CFRunLoopGetCurrent());
}


- (WFOSSPinLockDemo *)osspinLockDemo
{
    if (!_osspinLockDemo) {
        _osspinLockDemo = [[WFOSSPinLockDemo alloc] init];
    }
    return _osspinLockDemo;
}

- (WFDispatchSerialQueueDemo *)queueDemo
{
    if (!_queueDemo) {
        _queueDemo = [WFDispatchSerialQueueDemo new];
    }
    return _queueDemo;
}

- (WF_os_unfair_loack_demo *)os_unfair_demo
{
    if (!_os_unfair_demo) {
        _os_unfair_demo = [WF_os_unfair_loack_demo new];
    }
    return _os_unfair_demo;
}

- (WFPThread_mutex *)mutex_demo
{
    if (!_mutex_demo) {
        _mutex_demo = [WFPThread_mutex new];
    }
    return _mutex_demo;
}



#pragma mark - 线程安全测试

/** 自旋锁: 忙等 */
- (void)osspinLockTest
{
//    static OSSpinLock lock = OS_SPINLOCK_INIT;
//    OSSpinLockLock(&lock);
//    [self.osspinLockDemo ticketTest];
//    OSSpinLockUnlock(&lock);
//
    
//    WFOSSPinLockDemo *lockDemo = [[WFOSSPinLockDemo alloc] init];
//    [lockDemo ticketTest];
//    [lockDemo moneyTest];
    
    
//    dispatch_semaphore_wait(_semaphore_lock, DISPATCH_TIME_FOREVER);
//    [self.osspinLockDemo ticketTest];
//    dispatch_semaphore_signal(_semaphore_lock);
    
    for (int i = 0; i < 10; i++) {
        [self.osspinLockDemo ticketTest];
    }
}

/** 互斥锁: 休眠 */
- (void)pthread_mutex_test
{
//    WFPThread_mutex *mutex = [[WFPThread_mutex alloc] init];
//    [mutex ticketTest];
    
    for (int i = 0; i < 10; i++) {
        [self.mutex_demo ticketTest];
    }
}


- (void)serialQueue
{
//    WFDispatchSerialQueueDemo *queueModel = [WFDispatchSerialQueueDemo new];
//    [self.queueDemo ticketTest];
    
//    dispatch_async(self.queue_t, ^{
//        [self serialQueueTest];
//        NSLog(@"serialQueue - %s -- %@", __func__, [NSThread currentThread]);
//    });
    
    
    for (int i = 0; i < 10; i++) {
        [self.queueDemo ticketTest];
    }
}

- (void)serialQueueTest
{
    [self.queueDemo ticketTest];
}

- (void)os_unfair_demo_test
{
    for (int i = 0; i < 10; i++) {
        [self.os_unfair_demo ticketTest];
    }
}


- (void)pthread_rwLock
{
    [self.navigationController pushViewController:[PThread_rwLock new] animated:YES];
}

- (void)dispatch_barrier
{
    [self.navigationController pushViewController:[DispatchBarrierPage new] animated:YES];
}


- (void)displayLinkTest
{
    [self.navigationController pushViewController:[DisplayLinkViewController new] animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
