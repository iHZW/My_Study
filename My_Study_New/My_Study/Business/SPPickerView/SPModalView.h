//
//  SPModalView.h
//  SPPickerView
//
//  Created by Libo on 2018/9/1.
//  Copyright © 2018年 Cookie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SPModalViewDelegate <NSObject>

- (void)closeControlForSPModalView;

@end

@interface SPModalView : UIView

- (instancetype)initWithView:(UIView *)view inBaseViewController:(UIViewController *)baseViewController;

// 是关闭背景层的3D动画，默认NO
@property (nonatomic, assign) BOOL narrowedOff;

@property (nonatomic, weak) id<SPModalViewDelegate> delegate;

- (void)show;
- (void)hide;
- (void)close;


@end
