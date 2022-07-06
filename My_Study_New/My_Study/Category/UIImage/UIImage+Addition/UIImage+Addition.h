//
//  UIImage+Addition.h
//  JCYProduct
//
//  Created by Howard on 15/10/24.
//  Copyright © 2015年 Howard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWSDK.h"

typedef enum  {
    topToBottom = 0,//从上到小
    leftToRight = 1,//从左到右
    upleftTolowRight = 2,//左上到右下
    uprightTolowLeft = 3,//右上到左下
}GradientType;


#define kRedGradientColorArray  @[UIColorFromRGB(0xf34141),UIColorFromRGB(0xe2233e)]
#define kDarkRedGradientColorArray  @[UIColorFromRGB(0xC23334),UIColorFromRGB(0xB41C31)]
#define kGreenGradientColorArray  @[UIColorFromRGB(0x2f9bf9),UIColorFromRGB(0x2978ff)]
#define kOrangeGradientColorArray  @[UIColorFromRGB(0xff9c00),UIColorFromRGB(0xff8000)]


@interface UIImage (Addition)

- (UIImage*)fillImageWithColor:(UIColor*)color;
+ (UIImage*)imageWithColor:(UIColor *)color;
+ (UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size;
+ (UIImage*)imageWithColor:(UIColor *)color size:(CGSize)size alpha:(CGFloat)alpha;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size andRoundSize:(CGFloat)roundSize;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

+ (UIImage*)imageWithPointNum:(NSInteger)num radius:(CGFloat)radius space:(CGFloat)space color:(UIColor*)color;

//截屏view
+ (UIImage *)screenShotsImageInView:(UIView *)view size:(CGSize)size;

/**
 *  scale 图片高清度，0：手机高清度， 1：1倍 2：2倍
 */
+ (UIImage *)screenShotsImageInView:(UIView *)view size:(CGSize)size scale:(CGFloat)scale;

//压缩图片
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;

/**
 图片上下拼接

 @param topImage    上面图片
 @param bottomImage 下面图片
 @param space       两者间隔

 @return 拼接好的图片
 */
+ (UIImage *)combineWithTopImage:(UIImage *)topImage bottomImage:(UIImage *)bottomImage space:(CGFloat)space;

// image是图片，blur是模糊度
+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;

// 拼接图片
+ (UIImage *)combineWithTopImage:(UIImage *)topImage
                     bottomImage:(UIImage *)bottomImage
                     qrCodeImage:(UIImage *)qrCodeImage;

+ (UIImage *)creatQRCodeImageWithString:(NSString *)string
                            logoImage:(UIImage *)logoImage;

/**
 生成一个渐变色image

 @param colors 颜色数组
 @param gradientType 类型
 @param size 尺寸
 @return image
 */
+ (UIImage*)creatImageFromColors:(NSArray*)colors
                    ByGradientType:(GradientType)gradientType
                              size:(CGSize)size;

/**
 红色渐变色
 
 @param size 尺寸
 @return image
 */
+ (UIImage *)creatRedGradientImageWithSize:(CGSize)size;
+ (UIImage *)creatDarkRedGradientImageWithSize:(CGSize)size;
+ (UIImage *)creatGreenGradientImageWithSize:(CGSize)size;
+ (UIImage *)creatOrangeGradientImageWithSize:(CGSize)size;
@end
