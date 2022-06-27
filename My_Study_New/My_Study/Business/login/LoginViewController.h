//
//  LoginViewController.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//
/** 登录页  */

#import "ZWBaseViewController.h"

typedef void (^LoginCompletedBlock) (void);

NS_ASSUME_NONNULL_BEGIN

@interface LoginViewController : ZWBaseViewController

@property (nonatomic, copy) LoginCompletedBlock loginCompleted;

@end

NS_ASSUME_NONNULL_END
