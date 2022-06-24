//
//  UIView+SVG.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/24.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "UIView+SVG.h"
#import <SVGKit/SVGKit.h>

@implementation UIImageView (SVG)
- (void)svg_setImageNamed:(NSString *)svgName{
    [self svg_setImageNamed:svgName inBundle:nil];
}

- (void)svg_setImageNamed:(NSString *)svgName inBundle:(nullable NSBundle *)bundle{
    if (svgName.length == 0){
        return;
    }
    
    NSBundle *destBundle = bundle != nil ? bundle : [NSBundle mainBundle];
    self.image = [SVGKImage imageNamed:svgName inBundle:destBundle].UIImage;
}
@end

@implementation UIImage (SVG)

+ (UIImage *)svg_imageNamed:(NSString *)svgName{
    return [self svg_imageNamed:svgName inBundle:nil];
}

+ (UIImage *)svg_imageNamed:(NSString *)svgName inBundle:(nullable NSBundle *)bundle{
    if (svgName.length == 0){
        return nil;
    }
    NSBundle *destBundle = bundle != nil ? bundle : [NSBundle mainBundle];
    SVGKImage *svgImage = [SVGKImage imageNamed:svgName inBundle:destBundle];
    return svgImage.UIImage;
}


+ (UIImage *)svg_imageNamed:(NSString *)svgName scaleToFitInside:(CGSize)maxSize{
    return [self svg_imageNamed:svgName inBundle:nil scaleToFitInside:maxSize];
}

+ (UIImage *)svg_imageNamed:(NSString *)svgName inBundle:(nullable NSBundle *)bundle scaleToFitInside:(CGSize)maxSize{
    if (svgName.length == 0){
        return nil;
    }
    
    NSBundle *destBundle = bundle != nil ? bundle : [NSBundle mainBundle];
    SVGKImage *svgImage = [SVGKImage imageNamed:svgName inBundle:destBundle];
    [svgImage scaleToFitInside:maxSize];
    return svgImage.UIImage;
}

@end
