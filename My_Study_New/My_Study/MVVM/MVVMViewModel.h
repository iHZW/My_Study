//
//  MVVMViewModel.h
//  My_Study
//
//  Created by HZW on 2021/9/6.
//  Copyright © 2021 HZW. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "BaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class MVVMModel;

@interface MVVMViewModel : BaseViewModel

@property (nonatomic, strong) MVVMModel *mvvmModel;

@end

NS_ASSUME_NONNULL_END
