//
//  ZWLaunchManage.h
//  My_Study
//
//  Created by hzw on 2023/7/29.
//  Copyright © 2023 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZWLaunchManage : NSObject

@property (nonatomic, assign) BOOL isSJ;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
