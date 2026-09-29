//
//  UIView+Extension.m
//  gaocp
//
//  Created by shukai wu on 2022/5/9.
//  Copyright © 2022 SXSW. All rights reserved.
//

#import "UIView+Tool.h"
#import <objc/runtime.h>

@implementation UIView (Tool)
- (CAGradientLayer*)mm_createByCAGradientLayer:(UIColor *)startColor
                                      midColor:(UIColor *)midColor
                                      endColor:(UIColor *)endColor
                                    layerFrame:(CGRect)frame
                                     direction:(MMGradientType)direction {

    CAGradientLayer *layer = [CAGradientLayer layer];
    //存放渐变的颜色的数组
    UITraitCollection *traitCollection = [UIApplication sharedApplication].keyWindow.traitCollection;
    if (@available(iOS 13.0, *)) {
        layer.colors = @[(__bridge id)[startColor resolvedColorWithTraitCollection:traitCollection].CGColor,
                         (__bridge id)[midColor resolvedColorWithTraitCollection:traitCollection].CGColor,
                         (__bridge id)[endColor resolvedColorWithTraitCollection:traitCollection].CGColor];
    }
    else {
        layer.colors = @[(__bridge id)startColor.CGColor, (__bridge id)midColor.CGColor, (__bridge id)endColor.CGColor];
    }
    layer.locations = @[@0.0, @0.5, @1.0];
    //起点和终点表示的坐标系位置，(0,0)表示左上角，(1,1)表示右下角
    switch (direction) {
        case GradientTypeTopToBottom:
            layer.startPoint = CGPointMake(0.0, 0.0);
            layer.endPoint = CGPointMake(0.0, 1);
            break;
        case GradientTypeLeftToRight:
            layer.startPoint = CGPointMake(0.0, 0.0);
            layer.endPoint = CGPointMake(1, 0.0);
            break;
        default:
            break;
    }
    
    layer.frame = frame;
    [self.layer insertSublayer:layer atIndex:0];
    return layer;
}

- (CAGradientLayer*)mm_createByCAGradientLayer:(UIColor *)startColor
                                      endColor:(UIColor *)endColor
                                    layerFrame:(CGRect)frame
                                     direction:(MMGradientType)direction {
    CAGradientLayer *layer = [CAGradientLayer layer];
    //存放渐变的颜色的数组
    UITraitCollection *traitCollection = [UIApplication sharedApplication].keyWindow.traitCollection;
    if (@available(iOS 13.0, *)) {
        layer.colors = @[(__bridge id)[startColor resolvedColorWithTraitCollection:traitCollection].CGColor,
                         (__bridge id)[endColor resolvedColorWithTraitCollection:traitCollection].CGColor];
    }
    else {
        layer.colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
    }
    layer.locations = @[@0.0, @1.0];
    //起点和终点表示的坐标系位置，(0,0)表示左上角，(1,1)表示右下角
    switch (direction) {
        case GradientTypeTopToBottom:
            layer.startPoint = CGPointMake(0.0, 0.0);
            layer.endPoint = CGPointMake(0.0, 1);
            break;
        case GradientTypeLeftToRight:
            layer.startPoint = CGPointMake(0.0, 0.0);
            layer.endPoint = CGPointMake(1, 0.0);
            break;
        default:
            break;
    }
    
    layer.frame = frame;
    [self.layer insertSublayer:layer atIndex:0];
    return layer;
}

- (CAGradientLayer*)mm_createByCAGradientLayer:(UIColor *)startColor
                                      endColor:(UIColor *)endColor
                                    layerFrame:(CGRect)frame
                                     locations:(NSArray<NSNumber *> *)locations
                                     direction:(MMGradientType)direction {
    CAGradientLayer *layer = [CAGradientLayer layer];
    //存放渐变的颜色的数组
    UITraitCollection *traitCollection = [UIApplication sharedApplication].keyWindow.traitCollection;
    if (@available(iOS 13.0, *)) {
        layer.colors = @[(__bridge id)[startColor resolvedColorWithTraitCollection:traitCollection].CGColor,
                         (__bridge id)[endColor resolvedColorWithTraitCollection:traitCollection].CGColor];
    }
    else {
        layer.colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
    }
    layer.locations = locations;
    //起点和终点表示的坐标系位置，(0,0)表示左上角，(1,1)表示右下角
    switch (direction) {
        case GradientTypeTopToBottom:
            layer.startPoint = CGPointMake(0.0, 0.0);
            layer.endPoint = CGPointMake(0.0, 1);
            break;
        case GradientTypeLeftToRight:
            layer.startPoint = CGPointMake(0.0, 0.0);
            layer.endPoint = CGPointMake(1, 0.0);
            break;
        default:
            break;
    }
    
    layer.frame = frame;
    [self.layer insertSublayer:layer atIndex:0];
    return layer;
}

- (void)mm_addAllShadowWithColor:(UIColor *)color {
    // 阴影颜色
    self.layer.shadowColor = color.CGColor;
    // 阴影偏移，默认(0, -3)
    self.layer.shadowOffset = CGSizeMake(0,0);
    // 阴影透明度，默认0
    self.layer.shadowOpacity = 1;
    // 阴影半径，默认3
    self.layer.shadowRadius = 6;
}

- (UIViewController *)mm_currentController {
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}

/**
 * 获取截屏
 */
- (UIImage *)screenCaptureImage {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize shotSize =CGSizeMake(self.bounds.size.width*scale, self.bounds.size.height*scale);
    UIGraphicsBeginImageContextWithOptions(shotSize,false,0);//设置截屏大小
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* viewImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageRef = viewImage.CGImage;
    CGRect rect =CGRectMake(0,0, shotSize.width, shotSize.height);
    //这里可以设置想要截图的区域
    CGImageRef imageRefRect =CGImageCreateWithImageInRect(imageRef, rect);
    UIImage*image =[[UIImage alloc]initWithCGImage:imageRefRect];//
    return image;
}

/**
 * 移除所有子视图
 */
- (void)removeAllSubViews{
    NSArray *subViews = self.subviews;
    for (UIView *subview in subViews){
        [subview removeFromSuperview];
    }
}
@end
