//
//  MMPrivacyManager.h
//  My_Study
//
//  Created by hzw on 2023/2/17.
//  Copyright © 2023 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// NSInteger 点击的第几个按钮
typedef void (^PrivacyButtonClick)(NSInteger index);

@interface MMPrivacyManager : NSObject

+ (instancetype)sharedInstance;

// 显示隐私弹框
- (void)showPrivacyAlert:(UIView *)inView clickResult:(PrivacyButtonClick)clickResult;
// 协议更新提示
- (void)showPrivacyUpgradeAlert:(UIView *)inView clickResult:(PrivacyButtonClick)clickResult;


- (void)showPrivacyAlert:(UIView *)inView
                   title:(NSString *)title
                 message:(NSString *)message
             clickResult:(PrivacyButtonClick)clickResult;

// 显示app 内置的弹框控制； 只会在启动的时候显示一次
- (BOOL)hasShowedAppPrivacy;

- (void)markAppPrivacyShowed;

@end

NS_ASSUME_NONNULL_END
