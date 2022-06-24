//
//  UIView+SVG.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/24.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (SVG)

- (void)svg_setImageNamed:(NSString *)svgName;

- (void)svg_setImageNamed:(NSString *)svgName inBundle:(nullable NSBundle *)bundle;

@end


@interface UIImage (SVG)

+ (UIImage *)svg_imageNamed:(NSString *)svgName;

+ (UIImage *)svg_imageNamed:(NSString *)svgName inBundle:(nullable NSBundle *)bundle;

+ (UIImage *)svg_imageNamed:(NSString *)svgName scaleToFitInside:(CGSize)maxSize;

+ (UIImage *)svg_imageNamed:(NSString *)svgName inBundle:(nullable NSBundle *)bundle scaleToFitInside:(CGSize)maxSize;

@end

NS_ASSUME_NONNULL_END
