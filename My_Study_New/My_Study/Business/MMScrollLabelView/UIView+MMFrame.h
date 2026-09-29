//
//  UIView+TXFrame.h
//  TXSwipeTableViewTest
//
//  Created by tingxins on 9/1/16.
//  Copyright © 2016 tingxins. All rights reserved.
//  Welcome to my blog: https://tingxins.com
//

#import <UIKit/UIKit.h>

@interface UIView (MMFrame)
/** 设置x值 */
@property (assign, nonatomic) CGFloat mm_x;
/** 设置y值 */
@property (assign, nonatomic) CGFloat mm_y;
/** 设置width */
@property (assign, nonatomic) CGFloat mm_width;
/** 设置height */
@property (assign, nonatomic) CGFloat mm_height;
/** 设置size */
@property (assign, nonatomic) CGSize  mm_size;
/** 设置origin */
@property (assign, nonatomic) CGPoint mm_origin;
/** 设置center */
@property (assign, nonatomic) CGPoint mm_center;
/** 设置center.x */
@property (assign, nonatomic) CGFloat mm_centerX;
/** 设置center.y */
@property (assign, nonatomic) CGFloat mm_centerY;
/** 设置bottom */
@property (assign, nonatomic) CGFloat mm_bottom;
@end
