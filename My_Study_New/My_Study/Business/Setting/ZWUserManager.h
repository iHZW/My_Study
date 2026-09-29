//
//  ZWUserManager.h
//  My_Study
//
//  Created by hzw on 2023/2/15.
//  Copyright © 2023 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZWUserManager : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) NSInteger age;

@property (nonatomic, assign) NSInteger gender;

@property (nonatomic, copy) NSString *nichName;

/// 供外部统一使用的单例类方法
+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
