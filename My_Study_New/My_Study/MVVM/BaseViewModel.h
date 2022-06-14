//
//  BaseViewModel.h
//  My_Study
//
//  Created by HZW on 2021/9/11.
//  Copyright © 2021 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SuccessBlock) (id _Nullable data);
typedef void(^FailBlock) (id _Nullable data);

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewModel : NSObject

@property (nonatomic, copy) SuccessBlock successBlock;

@property (nonatomic, copy) FailBlock failBlock;

- (void)initWithBlock:(SuccessBlock)successBlock failBlock:(FailBlock)failBlock;

@end

NS_ASSUME_NONNULL_END
