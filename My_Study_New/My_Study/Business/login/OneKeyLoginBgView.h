//
//  OneKeyLoginBgView.h
//  My_Study
//
//  Created by Zhiwei Han on 2023/1/17.
//  Copyright © 2023 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class OneKeyLoginBgView;

@protocol OneKeyLoginBgViewDelegate<NSObject>

- (void)viewDidClickClose:(OneKeyLoginBgView *)view;
//微信登录
//- (void)viewWxButtonDidClickClicked:(OneKeyLoginBgView *)view;
// 手机号登录
- (void)viewPhoneButtonDidClickClicked:(OneKeyLoginBgView *)view;
//其它账号绑定
//- (void)otherLoginButtonDidClickClicked:(OneKeyLoginBgView *)view;

@end


@interface OneKeyLoginBgView : UIView

@property (nonatomic, weak) id<OneKeyLoginBgViewDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
