//
//  UIView+Extension.h
//  gaocp
//
//  Created by shukai wu on 2022/5/9.
//  Copyright © 2022 SXSW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MMGradientType) {
    GradientTypeTopToBottom = 0,
    GradientTypeLeftToRight = 1,
};

NS_ASSUME_NONNULL_BEGIN

@class RACSignal;

@interface UIView (Tool)
-(CAGradientLayer*)mm_createByCAGradientLayer:(UIColor *)startColor
                                     endColor:(UIColor *)endColor
                                   layerFrame:(CGRect)frame
                                    direction:(MMGradientType)direction;

-(CAGradientLayer*)mm_createByCAGradientLayer:(UIColor *)startColor
                                     midColor:(UIColor *)midColor
                                     endColor:(UIColor *)endColor
                                   layerFrame:(CGRect)frame
                                    direction:(MMGradientType)direction;

- (CAGradientLayer*)mm_createByCAGradientLayer:(UIColor *)startColor
                                      endColor:(UIColor *)endColor
                                    layerFrame:(CGRect)frame
                                     locations:(NSArray<NSNumber *> *)locations
                                     direction:(MMGradientType)direction;

- (void)mm_addAllShadowWithColor:(UIColor *)color;

/**
 * 获取截屏
 */
- (UIImage *)screenCaptureImage;

/**
 * 移除所有子视图
 */
- (void)removeAllSubViews;
@end

NS_ASSUME_NONNULL_END
