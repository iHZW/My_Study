//
//  UIView+Util.h
//  PASecuritiesApp
//
//  Created by Weirdln on 16/9/30.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UIViewActionBlock)(UIView *view);


@interface UIView (Util)

- (void)addActionWithBlock:(UIViewActionBlock)block;

- (void)startRollingWithIndicatorStyle:(UIActivityIndicatorViewStyle)style;

- (void)startRollingWithIndicatorStyle:(UIActivityIndicatorViewStyle)style atRect:(CGRect)rect;

- (void)endRolling;

@end
