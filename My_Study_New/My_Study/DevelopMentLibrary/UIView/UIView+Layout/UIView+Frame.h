//
//  UIView+Frame.h
//  TZYJ_IPhone
//
//  Created by Weirdln on 15/9/30.
//
//

#import <QuartzCore/QuartzCore.h>

@interface UIView (Frame)
@property (nonatomic, assign) UIImage *backgroundImage;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign, readonly) CGPoint rightBottomCorner;

- (void)setBackgroundImage:(UIImage *)backImg viewContentMode:(UIViewContentMode)viewContentMode;

// x,y
- (CGFloat)x;
- (CGFloat)y;
- (void)setX:(CGFloat)x;
- (void)setY:(CGFloat)y;

// height, width
- (CGFloat)height;
- (CGFloat)width;
- (void)setHeight:(CGFloat)height;
- (void)setWidth:(CGFloat)width;
- (void)heightEqualToView:(UIView *)view;
- (void)widthEqualToView:(UIView *)view;

// bottom,right
- (CGFloat)bottom;
- (CGFloat)right;

// size
- (CGSize)size;
- (void)setSize:(CGSize)size;

// origin
- (CGPoint)origin;
- (void)setOrigin:(CGPoint)origin;

// center
- (CGFloat)centerX;
- (CGFloat)centerY;
- (void)setCenterX:(CGFloat)centerX;
- (void)setCenterY:(CGFloat)centerY;

// 设置圆角和边框
- (void)setCornerRadius:(float)cornerRadius borderWidth:(float)borderWidth borderColor:(UIColor *)borderColor;

// 设置每个角圆角
- (void)applyRoundedCorners:(UIRectCorner)corners withRadius:(CGFloat)radius;

@end
