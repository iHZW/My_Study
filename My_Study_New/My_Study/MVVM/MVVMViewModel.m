//
//  MVVMViewModel.m
//  My_Study
//
//  Created by HZW on 2021/9/6.
//  Copyright © 2021 HZW. All rights reserved.
//

#import "MVVMViewModel.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MVVMModel.h"

@interface MVVMViewModel ()

@end

@implementation MVVMViewModel

- (instancetype)init
{
    if (self = [super init]) {
        dispatch_after(2, dispatch_get_main_queue(), ^{
            self.mvvmModel.name = @"张三";
            self.mvvmModel.imageName = @"mvp";
        });
        
        [RACObserve(self, mvvmModel) subscribeNext:^(id  _Nullable x) {
            NSLog(@"点击了%@", x);
            
            if (self.successBlock) {
                self.successBlock(x);
            }
        }];
    }
    return self;
}


- (MVVMModel *)mvvmModel
{
    if (!_mvvmModel) {
        _mvvmModel = [MVVMModel new];
    }
    return _mvvmModel;
}


@end
