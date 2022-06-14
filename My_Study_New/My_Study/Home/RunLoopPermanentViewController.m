//
//  RunLoopPermanentViewController.m
//  My_Study
//
//  Created by HZW on 2021/9/4.
//  Copyright © 2021 HZW. All rights reserved.
//

#import "RunLoopPermanentViewController.h"
#import "WFPermanentThread.h"

@interface RunLoopPermanentViewController ()

@property (nonatomic, strong) WFPermanentThread *wf_thread;

@end

@implementation RunLoopPermanentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wf_thread = [[WFPermanentThread alloc] init];
    [self.wf_thread start];
    
//    [self.wf_thread setTaskBlock:^(NSInteger index) {
//        NSLog(@"%s --- %@", __func__, @(index));
//    }];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    @pas_weakify_self
    [self.wf_thread executeTask:^(NSInteger index) {
        @pas_strongify_self
        NSLog(@"执行任务--%@--%@", [NSThread currentThread], @(index));
    }];

}

- (void)dealloc
{
    NSLog(@"%s", __func__);
    [self.wf_thread stop];

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
