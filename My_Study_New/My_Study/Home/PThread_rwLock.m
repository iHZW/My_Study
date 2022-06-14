//
//  PThread_rwLock.m
//  My_Study
//
//  Created by HZW on 2021/9/5.
//  Copyright © 2021 HZW. All rights reserved.
//

#import "PThread_rwLock.h"
#import <pthread/pthread.h>

@interface PThread_rwLock ()
{
    pthread_rwlock_t _rwLock;
}


@end

@implementation PThread_rwLock

- (void)viewDidLoad {
    [super viewDidLoad];
       
    pthread_rwlock_init(&_rwLock, NULL);
    // Do any additional setup after loading the view.
    
    for (int i = 0; i < 10; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self read];
        });
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self write];
        });
    }
    
    
    
}


- (void)read{
    pthread_rwlock_rdlock(&_rwLock);
    sleep(1);
    NSLog(@"%s--%@", __func__, [NSThread currentThread]);
    pthread_rwlock_unlock(&_rwLock);
}


- (void)write{
    pthread_rwlock_wrlock(&_rwLock);
    sleep(1);
    NSLog(@"%s--%@", __func__, [NSThread currentThread]);
    pthread_rwlock_unlock(&_rwLock);
}
 


@end
