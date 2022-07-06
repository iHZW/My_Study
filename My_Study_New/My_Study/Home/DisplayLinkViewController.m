//
//  DisplayLinkViewController.m
//  My_Study
//
//  Created by HZW on 2021/9/5.
//  Copyright © 2021 HZW. All rights reserved.
//

#import "DisplayLinkViewController.h"
#import "YYKit.h"

/** 可以查看aotorelease 的入栈情况 */
//extern void _objc_autoreleasePoolPrint(void)

@interface DisplayLinkViewController ()

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) dispatch_source_t sourceTimer;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation DisplayLinkViewController

/** MRC 中 set方法 */
//- (void)setName:(NSString *)name
//{
//    if (_name != name) {
//        [_name release];
//        _name = [name retain];
//    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
/** 64bit之后 引入tagged pointer 技术, 用于优化 NSmumber, NSDate, NSString 等小对象存储 */
    
    
    self.semaphore = dispatch_semaphore_create(1);
    
    for (int i = 0; i < 1000; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            self.name = [NSString stringWithFormat:@"hzw%d", i];
//            dispatch_semaphore_signal(self.semaphore);
        });

    }
        
    NSLog(@"%s", __func__);
     
    
//
//    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction)];
//    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
//    self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    /** 循环引用, 解决办法如下 */
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    
    /** 一: 使用一个弱代理 */
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:[YYWeakProxy proxyWithTarget:self] selector:@selector(timerAction) userInfo:nil repeats:YES];

    /** 二: 使用block方式创建, iOS 10之后可以使用 */
//    @pas_weakify_self
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        @pas_strongify_self
//        [self timerAction];
//    }];

    /** 三:  */
//    self.timer = [NSTimer timerWithTimeInterval:1.0 target:[YYWeakProxy proxyWithTarget:self] selector:@selector(timerAction) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
//    self.timer
    
    
    
    uint64_t start = 2;
    uint64_t interval = 1;
    dispatch_queue_t queue = dispatch_queue_create("gcd_timer", DISPATCH_QUEUE_CONCURRENT);
    dispatch_source_t gcd_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(gcd_timer,
                              dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC),
                              interval * NSEC_PER_SEC,
                              0);
    /** 使用dispatch_source_set_event_handler */
    @pas_weakify_self
    dispatch_source_set_event_handler(gcd_timer, ^{
        @pas_strongify_self
        [self loadGCDTimer];
//        NSLog(@"%s -- %@", __func__, [NSThread currentThread]);
    });
    dispatch_resume(gcd_timer);
//    self.sourceTimer = gcd_timer;
}

- (void)displayLinkAction
{
    NSLog(@"%s", __func__);
}

- (void)timerAction{
    
    NSLog(@"%s", __func__);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    /** 取消GCDTimer */
    dispatch_source_cancel(self.sourceTimer);
    
    
    NSNumber *number1 = @1;
    NSNumber *number2 = @2;
    NSNumber *number3 = @(4);
    NSNumber *number4 = @(0xFFFFF);

    NSLog(@"\n numbre1=%p\n numbre2=%p\n numbre3=%p\n numbre4=%p\n", number1, number2, number3, number4);
}


- (void)dealloc{
    
    NSLog(@"%s", __func__);
//    [self.timer invalidate];
//    self.timer = nil;

//    /** 取消GCDTimer */
//    dispatch_source_cancel(self.sourceTimer);
}

- (void)loadGCDTimer
{
    NSLog(@"%s -- %@", __func__, [NSThread currentThread]);
    

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
