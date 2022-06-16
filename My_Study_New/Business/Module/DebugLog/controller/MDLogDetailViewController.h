//
//  MDLogDetailViewController.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/16.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWBaseViewController.h"

typedef NSUInteger(^LogQueryIDBlock)(BOOL,NSUInteger);


NS_ASSUME_NONNULL_BEGIN

@interface MDLogDetailViewController : ZWBaseViewController

@property (nonatomic, assign) NSUInteger identity;

@property (nonatomic, assign) NSUInteger index;

@property (nonatomic, copy) LogQueryIDBlock queryIdentityBlock;

@end

NS_ASSUME_NONNULL_END
