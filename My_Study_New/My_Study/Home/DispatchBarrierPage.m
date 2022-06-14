//
//  DispatchBarrierPage.m
//  My_Study
//
//  Created by HZW on 2021/9/5.
//  Copyright © 2021 HZW. All rights reserved.
//

/** 使用栅栏函数 必须使用自己创建的并发队列 */


#import "DispatchBarrierPage.h"

@interface DispatchBarrierPage ()

@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation DispatchBarrierPage

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.queue = dispatch_queue_create("barrier_queue", DISPATCH_QUEUE_CONCURRENT);
    
    for (int i = 0; i < 10; i++) {
        dispatch_async(self.queue, ^{
            [self read];
        });
        
        dispatch_async(self.queue, ^{
            [self write];
        });
    }
    
}


- (void)read{
    
    dispatch_async(self.queue, ^{
        sleep(1);
        NSLog(@"%s--%@", __func__, [NSThread currentThread]);
    });
}


- (void)write{
    
    dispatch_barrier_async(self.queue, ^{
        sleep(1);
        NSLog(@"%s--%@", __func__, [NSThread currentThread]);
    });
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
