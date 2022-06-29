//
//  ZWAnimationCircleLayer.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/29.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWAnimationCircleLayer.h"

@interface ZWAnimationCircleLayer () <CAAnimationDelegate>

@property (nonatomic, strong) UIColor *arcStrokeColor;

@property (nonatomic, assign) CGPoint point;

@property (nonatomic, assign) CGFloat radius;

@property (nonatomic, assign) float oldValue;

@end

@implementation ZWAnimationCircleLayer

- (instancetype)initWithframe:(CGRect)frame
{
    if (self = [super init]) {
//        self.arcStrokeColor = [UIColor whiteColor];
        self.arcStrokeColor = kDefineStrokeColor;

        self.radius = MIN(CGRectGetWidth(frame), CGRectGetHeight(frame))/2.0;
         self.point = CGPointMake(self.radius, self.radius);
        self.frame = frame;
        [self configShape];
//        CMLogDebug(LogBusinessBasicLib, @"point:%@, radius:%f", NSStringFromCGPoint(self.point), self.radius);
    }
    return self;
}

- (void)configShape
{
    CGPoint arcCenterPoint = self.point;
    CGFloat arcRadius = self.radius;
    CGFloat arcStartAngle = -M_PI_2;
    CGFloat arcEndAngle = M_PI * 2 - M_PI_2 + M_PI / 8.0;
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:arcCenterPoint radius:arcRadius startAngle:arcStartAngle endAngle:arcEndAngle clockwise:YES];
    self.path = bezierPath.CGPath;
    self.fillColor = nil;
    self.strokeColor = self.arcStrokeColor.CGColor;
    self.lineWidth = 1.5;
    self.lineCap = kCALineCapRound;
    self.strokeStart = 0;
    self.strokeEnd = 0;
    self.hidden = YES;
}

- (void)setCircleStrokeColor:(UIColor *)color
{
    self.arcStrokeColor = color;
    [self configShape];
}

- (void)startCircleAnimation:(float)toValue
{
    CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.fromValue = @(self.oldValue);
    strokeEndAnimation.toValue = @(toValue);
    strokeEndAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    strokeEndAnimation.duration = 2;
    strokeEndAnimation.repeatCount = 1;
    strokeEndAnimation.fillMode = kCAFillModeBoth;
    strokeEndAnimation.removedOnCompletion = NO;
    self.oldValue = toValue;
    [self addAnimation:strokeEndAnimation forKey:@"strokeCircleEndAnimation"];
}

- (void)startAnimation
{
    [self removeAllAnimations];
    self.hidden = NO;
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = @(0);
    rotateAnimation.toValue = @(2 * M_PI);
    rotateAnimation.duration = 1;
    rotateAnimation.fillMode = kCAFillModeBoth;
    rotateAnimation.removedOnCompletion = NO;
    rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotateAnimation.repeatCount = HUGE;
    [self addAnimation:rotateAnimation forKey:@"rotateAnimation"];
    [self strokeEndAnimation];
}

- (void)stopAnimation
{
    self.hidden = YES;
    [self removeAllAnimations];
}

- (void)strokeEndAnimation
{
    CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.fromValue = @(0);
    strokeEndAnimation.toValue = @(.95);
    strokeEndAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    strokeEndAnimation.duration = 2;
    strokeEndAnimation.repeatCount = 1;
    strokeEndAnimation.fillMode = kCAFillModeBoth;
    strokeEndAnimation.removedOnCompletion = NO;
    strokeEndAnimation.delegate = self;
    [self addAnimation:strokeEndAnimation forKey:@"strokeEndAnimation"];
}

- (void)strokeStartAnimation
{
    CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    strokeStartAnimation.fromValue = @(0);
    strokeStartAnimation.toValue = @(.95);
    strokeStartAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    strokeStartAnimation.duration = 2;
    strokeStartAnimation.repeatCount = 1;
    strokeStartAnimation.fillMode = kCAFillModeForwards;
    strokeStartAnimation.removedOnCompletion = NO;
    strokeStartAnimation.delegate = self;
    [self addAnimation:strokeStartAnimation forKey:@"strokeStartAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        CABasicAnimation *basicAnimation = (CABasicAnimation *)anim;
        if ([basicAnimation.keyPath isEqualToString:@"strokeEnd"]) {
            [self strokeStartAnimation];
        } else if ([basicAnimation.keyPath isEqualToString:@"strokeStart"]){
            [self removeAnimationForKey:@"strokeStartAnimation"];
            [self removeAnimationForKey:@"strokeEndAnimation"];
            [self strokeEndAnimation];
        }
    }
}

@end
