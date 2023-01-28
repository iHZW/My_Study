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

- (void)addActionWithBlock:(UIViewActionBlock)block {
    self.userInteractionEnabled = YES;
    @pas_weakify_self
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id obj) {
            @pas_strongify_self if (block) {
                block(self);
            }
        }];
    [self addGestureRecognizer:gesture];
}

- (void)startRollingWithIndicatorStyle:(UIActivityIndicatorViewStyle)style {
    UIActivityIndicatorView *aiv = (UIActivityIndicatorView *)[self viewWithTag:ROLLING_INDICATOR_TAG];
    if (!aiv) {
        aiv        = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
        aiv.tag    = ROLLING_INDICATOR_TAG;
        aiv.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [self addSubview:aiv];
    }
    [aiv startAnimating];
}

- (void)startRollingWithIndicatorStyle:(UIActivityIndicatorViewStyle)style atRect:(CGRect)rect {
    UIActivityIndicatorView *aiv = (UIActivityIndicatorView *)[self viewWithTag:ROLLING_INDICATOR_TAG];
    if (!aiv) {
        aiv        = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
        aiv.tag    = ROLLING_INDICATOR_TAG;
        aiv.center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
        [self addSubview:aiv];
    }
    [aiv startAnimating];
}

- (void)endRolling {
    UIActivityIndicatorView *aiv = (UIActivityIndicatorView *)[self viewWithTag:ROLLING_INDICATOR_TAG];
    [aiv stopAnimating];
    [aiv removeFromSuperview];
    [[self viewWithTag:OVERLAY_VIEW_TAG] removeFromSuperview];
}

/**
 * 移除所有子视图
 */
- (void)removeAllSubViews {
    NSArray *subViews = self.subviews;
    for (UIView *subview in subViews) {
        [subview removeFromSuperview];
    }
}

/**
 * 截图
 */
- (UIImage *)renderImage {
    CGFloat scale   = [UIScreen mainScreen].scale;
    CGSize shotSize = CGSizeMake(self.bounds.size.width * scale, self.bounds.size.height * scale);
    UIGraphicsBeginImageContextWithOptions(shotSize, false, 0); // 设置截屏大小
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageRef = viewImage.CGImage;
    CGRect rect         = CGRectMake(0, 0, shotSize.width, shotSize.height);
    // 这里可以设置想要截图的区域
    CGImageRef imageRefRect = CGImageCreateWithImageInRect(imageRef, rect);
    UIImage *image          = [[UIImage alloc] initWithCGImage:imageRefRect]; //
    return image;
}

@end
