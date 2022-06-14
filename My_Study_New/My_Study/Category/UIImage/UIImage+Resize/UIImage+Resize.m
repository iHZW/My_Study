//
//  UIImage+Resize.m
//  TZYJ_IPhone
//
//  Created by Weirdln on 15/9/14.
//
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (UIImage *)resizedImageWithLeftCap:(float)x topCap:(float)y
{
    if([self respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        return [self resizableImageWithCapInsets:UIEdgeInsetsMake(y, x, y+1, x+1)];
    }
    else{
        return [self stretchableImageWithLeftCapWidth:x topCapHeight:y];
    }
}

- (UIImage *)resizeCenterStretchImage
{
    return [[self class] resizeImage:self resizingMode:UIImageResizingModeStretch];
}

- (UIImage *)resizeTileImage
{
    return [[self class] resizeImage:self resizingMode:UIImageResizingModeTile];
}

- (UIImage *)scaledImageToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)scaleImageToScale:(CGFloat)scaleSize
{
    CGRect rect = CGRectZero;
    rect.size = CGSizeMake(self.size.width * scaleSize, self.size.height * scaleSize);
    rect = CGRectIntegral(rect);
    UIGraphicsBeginImageContext(rect.size);
    [self drawInRect:rect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage *)centerResizeImage
{
    CGSize size = self.size;
    return [self resizedImageWithLeftCap:ceilf(size.width*.5) topCap:ceilf(size.height*.5)];
}

+ (UIImage *)resizeImage:(UIImage *)originImage resizingMode:(UIImageResizingMode)resizingMode
{
    UIEdgeInsets edgeInsets;
    if (UIImageResizingModeTile == resizingMode) // 平铺整个区域
    {
        edgeInsets = UIEdgeInsetsZero;
    }
    else     // 拉伸中间一个像素点
    {
        CGSize size = originImage.size;
        CGFloat x = ceilf(size.width * .5); // 防止模糊
        CGFloat y = ceilf(size.height * .5);
        edgeInsets =  UIEdgeInsetsMake(y, x, y + 1, x + 1);
    }

    if ([originImage respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
    {
        return [originImage resizableImageWithCapInsets:edgeInsets resizingMode:resizingMode];
    }
    
    return originImage;
}

+ (UIImage *)imageNamed:(NSString *)name bundle:(NSBundle *)bundle
{
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[bundle bundlePath], name]];
}

+ (UIImage *)retinaImageNamed:(NSString *)name bundle:(NSBundle *)bundle
{
    UIImage *img        = [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:nil]];
    CGImageRef cgimage  = img.CGImage;
    img                 = [UIImage imageWithCGImage:cgimage scale:2.0 orientation:UIImageOrientationUp];
    
    return img;
}

+ (UIImage *)retinaImageNamed:(NSString *)name
{
    return [self retinaImageNamed:name bundle:[NSBundle mainBundle]];
}

+ (UIImage *)scaleImageNamed:(NSString *)name scale:(CGFloat)factor bundle:(NSBundle *)bundle
{
    UIImage *img        = [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:nil]];
    CGImageRef cgimage  = img.CGImage;
    img                 = [UIImage imageWithCGImage:cgimage scale:factor orientation:UIImageOrientationUp];
    
    return img;
}

+ (UIImage *)scaleImage:(UIImage *)image scale:(CGFloat)factor
{
    UIImage *img = [UIImage imageWithCGImage:image.CGImage scale:factor orientation:UIImageOrientationUp];
    return img;
}

+ (UIImage *)scaleImageNamed:(NSString *)name scale:(CGFloat)factor
{
    return [self scaleImageNamed:name scale:factor bundle:[NSBundle mainBundle]];
}

@end
