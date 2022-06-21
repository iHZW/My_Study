//
//  MDLogViewController.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/15.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWBaseViewController.h"

typedef NS_ENUM(NSInteger, FromPageType) {
    FromPageTypeDeault = 0,
    
    FromPageTypeOne,
    
    FromPageTypeTwo
    
};

NS_ASSUME_NONNULL_BEGIN

@interface MDLogViewController : ZWBaseViewController

@property (nonatomic, assign) FromPageType pageType;

@property (nonatomic, copy) NSString *context;

@end

NS_ASSUME_NONNULL_END
