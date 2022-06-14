//
//  BaseViewModel.m
//  My_Study
//
//  Created by HZW on 2021/9/11.
//  Copyright © 2021 HZW. All rights reserved.
//

#import "BaseViewModel.h"

@implementation BaseViewModel

- (void)initWithBlock:(SuccessBlock)successBlock failBlock:(FailBlock)failBlock
{
    _successBlock = successBlock;
    _failBlock = failBlock;
}

@end
