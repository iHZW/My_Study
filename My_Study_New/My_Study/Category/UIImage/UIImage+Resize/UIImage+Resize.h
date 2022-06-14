//
//  UIImage+Resize.h
//  TZYJ_IPhone
//
//  Created by Weirdln on 15/9/14.
//
//

#import <Foundation/Foundation.h>

@interface UIImage (Resize)

/**
 *  指定边距拉伸图片
 *
 *  @param x x轴边距位置
 *  @param y y轴边距位置
 *
 *  @return 返回拉伸后图片
 */
- (UIImage *)resizedImageWithLeftCap:(float)x topCap:(float)y;

/**
 *  拉伸最中间一个像素点来填充图片
 *
 *  @return 拉伸过后的image
 */
- (UIImage *)resizeCenterStretchImage;

/**
 *  重复显示整个图片来填充图片（平铺）
 *
 *  @return 平铺过后的image
 */
- (UIImage *)resizeTileImage;

/**
 *  缩放图片尺寸到指定Size
 *
 *  @param newSize
 *
 *  @return 返回缩放后图片
 */
- (UIImage *)scaledImageToSize:(CGSize)newSize;

/**
 等比例缩放图片

 @param centerResizeImage 缩放比例
 @return 返回缩放后图片
 */
- (UIImage *)scaleImageToScale:(CGFloat)scaleSize;

/**
 *  居中拉伸图片
 */
- (UIImage *)centerResizeImage;

+ (UIImage *)imageNamed:(NSString *)name bundle:(NSBundle *)bundle;

+ (UIImage *)retinaImageNamed:(NSString *)name bundle:(NSBundle *)bundle;

+ (UIImage *)retinaImageNamed:(NSString *)name;

+ (UIImage *)scaleImageNamed:(NSString *)name scale:(CGFloat)factor bundle:(NSBundle *)bundle;

+ (UIImage *)scaleImage:(UIImage *)image scale:(CGFloat)factor;

+ (UIImage *)scaleImageNamed:(NSString *)name scale:(CGFloat)factor;

@end
