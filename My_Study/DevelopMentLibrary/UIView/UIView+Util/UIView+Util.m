//
//  UIView+Util.m
//  PASecuritiesApp
//
//  Created by Weirdln on 16/9/30.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "UIView+Util.h"
#import "UIGestureRecognizer+Block.h"
#import "ZWSDK.h"

#define ROLLING_INDICATOR_TAG 231025
#define OVERLAY_VIEW_TAG 1652457

@implementation UIView (Util)

- (void)addActionWithBlock:(UIViewActionBlock)block
{
    self.userInteractionEnabled = YES;
    @pas_weakify_self
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id obj) {
        @pas_strongify_self
        if (block) {
            block(self);
        }
    }];
    [self addGestureRecognizer:gesture];
}

- (void)startRollingWithIndicatorStyle:(UIActivityIndicatorViewStyle)style
{
    UIActivityIndicatorView *aiv = (UIActivityIndicatorView*)[self viewWithTag:ROLLING_INDICATOR_TAG];
    if (!aiv) {
        aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
        aiv.tag = ROLLING_INDICATOR_TAG;
        aiv.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [self addSubview:aiv];
    }
    [aiv startAnimating];
}

- (void)startRollingWithIndicatorStyle:(UIActivityIndicatorViewStyle)style atRect:(CGRect)rect
{
    UIActivityIndicatorView *aiv = (UIActivityIndicatorView*)[self viewWithTag:ROLLING_INDICATOR_TAG];
    if (!aiv) {
        aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
        aiv.tag = ROLLING_INDICATOR_TAG;
        aiv.center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
        [self addSubview:aiv];
    }
    [aiv startAnimating];
}

- (void)endRolling
{
    UIActivityIndicatorView *aiv = (UIActivityIndicatorView*)[self viewWithTag:ROLLING_INDICATOR_TAG];
    [aiv stopAnimating];
    [aiv removeFromSuperview];
    [[self viewWithTag:OVERLAY_VIEW_TAG] removeFromSuperview];
}

@end
