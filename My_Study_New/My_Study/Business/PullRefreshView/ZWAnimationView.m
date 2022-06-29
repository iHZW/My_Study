//
//  ZWAnimationView.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/29.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWAnimationView.h"
#import "ZWAnimationCircleLayer.h"

@interface ZWAnimationView ()

@property (nonatomic, strong) ZWAnimationCircleLayer *animationLayer;

@property (nonatomic, strong) CAShapeLayer *circleLayer;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ZWAnimationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.animationLayer = [[ZWAnimationCircleLayer alloc] initWithframe:self.bounds];
        [self.animationLayer setCircleStrokeColor:kDefineStrokeColor];
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeCenter;
        UIImage *image = [UIImage imageNamed:@"refreshLog"];
//        UIImage *image = [UIImage imageNamed:@"loadingPAImage"];
        self.imageView.image = image;
//        CMLogDebug(LogBusinessBasicLib, @"imageSize:%@", NSStringFromCGSize(image.size));
        [self addSubview:self.imageView];
        [self.layer addSublayer:self.animationLayer];
        self.animationLayer.hidden = YES;
        
        self.circleLayer = [[CAShapeLayer alloc] init];
        self.circleLayer.frame = self.bounds;
        self.circleLayer.path = self.animationLayer.path;
//        self.circleLayer.fillColor = [UIColor clearColor].CGColor;
//        self.circleLayer.strokeColor = [UIColor whiteColor].CGColor;
        self.circleLayer.fillColor = [UIColor clearColor].CGColor;
        self.circleLayer.strokeColor = kDefineStrokeColor.CGColor;
        self.circleLayer.lineWidth = 1.5;
        self.circleLayer.lineCap = kCALineCapRound;
        self.circleLayer.lineJoin = kCALineJoinRound;
        
        [self.layer addSublayer:self.circleLayer];

    }
    return self;
}

- (void)setImageIcon:(UIImage *)imageIcon
{
    self.imageView.image = imageIcon;
    _imageIcon = imageIcon;
}

- (void)setCircleColor:(UIColor *)circleColor
{
    self.circleLayer.strokeColor = circleColor.CGColor;
    [self.animationLayer setCircleStrokeColor:circleColor];
    _circleColor = circleColor;
}

- (void)startAnimating:(float)value
{
    self.circleLayer.hidden = YES;
    self.animationLayer.hidden = NO;
    [self.animationLayer startCircleAnimation:value];
}

- (void)startAnimating
{
    self.circleLayer.hidden = YES;
    self.animationLayer.hidden = NO;
    [self.animationLayer startAnimation];
}

- (void)stopAnimating
{
    [self.animationLayer stopAnimation];
    self.animationLayer.hidden = YES;
    self.circleLayer.hidden = NO;
}

@end
