//
//  UIView+TXFrame.m
//  TXSwipeTableViewTest
//
//  Created by tingxins on 9/1/16.
//  Copyright © 2016 tingxins. All rights reserved.
//

#import "UIView+MMFrame.h"

@implementation UIView (MMFrame)

- (CGFloat)mm_x {
    return self.frame.origin.x;
}

- (void)setMm_x:(CGFloat)mm_x {
    CGRect frame = self.frame;
    frame.origin.x = mm_x;
    self.frame = frame;
}

- (CGFloat)mm_y {
    return self.frame.origin.y;
}

- (void)setMm_y:(CGFloat)mm_y {
    CGRect frame = self.frame;
    frame.origin.y = mm_y;
    self.frame = frame;
}

- (CGFloat)mm_width {
    return self.frame.size.width;
}

- (void)setMm_width:(CGFloat)mm_width {
    CGRect frame = self.frame;
    frame.size.width = mm_width;
    self.frame = frame;
}

- (CGFloat)mm_height {
    return self.frame.size.height;
}

- (void)setMm_height:(CGFloat)mm_height {
    CGRect frame = self.frame;
    frame.size.height = mm_height;
    self.frame = frame;
}

- (CGSize)mm_size {
    return self.frame.size;
}

- (void)setMm_size:(CGSize)mm_size {
    CGRect frame = self.frame;
    frame.size = mm_size;
    self.frame = frame;
}

- (CGPoint)mm_origin {
    return self.frame.origin;
}

- (void)setMm_origin:(CGPoint)mm_origin {
    CGRect frame = self.frame;
    frame.origin = mm_origin;
    self.frame = frame;
}

- (CGPoint)mm_center {
    return self.center;
}

- (void)setMm_center:(CGPoint)mm_center {
    self.center = mm_center;
}

- (CGFloat)mm_centerX {
    return self.center.x;
}

- (void)setMm_centerX:(CGFloat)mm_centerX {
    CGPoint center = self.center;
    center.x = mm_centerX;
    self.center = center;
}

- (CGFloat)mm_centerY {
    return self.center.y;
}

- (void)setMm_centerY:(CGFloat)mm_centerY {
    CGPoint center = self.center;
    center.y = mm_centerY;
    self.center = center;
}

- (CGFloat)mm_bottom {
    return CGRectGetMaxY(self.frame);
}

- (void)setMm_bottom:(CGFloat)mm_bottom {
    CGRect frame = self.frame;
    frame.origin.y = mm_bottom - frame.size.height;
    self.frame = frame;
}

@end
