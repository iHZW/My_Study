//
//  UIImage+Addition.m
//  JCYProduct
//
//  Created by Howard on 15/10/24.
//  Copyright © 2015年 Howard. All rights reserved.
//

#import "UIImage+Addition.h"
#import <Accelerate/Accelerate.h>
#import "SystemInfoFunc.h"
#import "UIColor+Extensions.h"

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

@implementation UIImage (Addition)

- (UIImage*)fillImageWithColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO,[UIScreen mainScreen].scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, rect, self.CGImage);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

+ (UIImage*)imageWithColor:(UIColor *)color
{
    CGSize size     = CGSizeMake(1, 1);
    UIImage *image  = [UIImage imageWithColor:color size:size];
    return image;
}

+ (UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size
{
    return [UIImage imageWithColor:color size:size alpha:1.0];
}

+ (UIImage*)imageWithColor:(UIColor *)color size:(CGSize)size alpha:(CGFloat)alpha
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAlpha(context, alpha);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, (CGRect){.size = size});
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color
                       size:(CGSize)size
               andRoundSize:(CGFloat)roundSize
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (roundSize > 0) {
        UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius: roundSize];
        [color setFill];
        [roundedRectanglePath fill];
    } else {
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, rect);
        
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    //    [rotatedViewBox release];
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage*)imageWithPointNum:(NSInteger)num radius:(CGFloat)radius space:(CGFloat)space color:(UIColor*)color
{
    CGSize size = CGSizeMake((radius * 2) * num + space * (num - 1), radius * 2); // 计算实际的size
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    for (NSInteger index = 0; index < num; index++)
    {
        CGContextAddArc(context, (radius * 2 + space) * index + radius, radius, radius, 0, 2 * M_PI, 0); //添加一个圆
        CGContextDrawPath(context, kCGPathFill);//绘制填充
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)screenShotsImageInView:(UIView *)view size:(CGSize)size
{
    return [UIImage screenShotsImageInView:view size:size scale:0];
}

+ (UIImage *)screenShotsImageInView:(UIView *)view size:(CGSize)size scale:(CGFloat)scale
{
    if (view == nil) {
        return nil;
    }
    UIGraphicsBeginImageContextWithOptions(size, YES, scale);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}

// 压缩图片
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (UIImage *)addImage:(UIImage *)subImage
           superImage:(UIImage *)superImage
         subImageRect:(CGRect)rect{
    if (!subImage) {
        return superImage;
    }
    CGFloat width = superImage.size.width;
    CGFloat height = superImage.size.height;
    CGSize imageSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    CGRect imageRect = CGRectMake(0, 0, width, height);
    [superImage drawInRect:imageRect];
    [subImage drawInRect:rect];
    UIImage *imageNew = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageNew;
}

// 拼接图片
+ (UIImage *)combineWithTopImage:(UIImage *)topImage
                     bottomImage:(UIImage *)bottomImage
                     qrCodeImage:(UIImage *)qrCodeImage
{
    if (bottomImage == nil) {
        return topImage;
    }
    
    CGFloat width = topImage.size.width;
    CGFloat height = topImage.size.height + bottomImage.size.height;
    CGSize offScreenSize = CGSizeMake(width, height);
    
    UIGraphicsBeginImageContextWithOptions(offScreenSize, NO, 2.0);
    
    CGRect rectTop = CGRectMake(0, 0, width, topImage.size.height);
    [topImage drawInRect:rectTop];
    
    CGRect rectBottom = CGRectMake(0, topImage.size.height+1 , width, bottomImage.size.height);
    [bottomImage drawInRect:rectBottom];
    CGFloat widht = 90;
    CGRect qrImageRect = CGRectMake(25, height-widht-25, widht, widht);
    [qrCodeImage drawInRect:qrImageRect];
    
    UIImage *imageNew = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageNew;
}

// 拼接图片
+ (UIImage *)combineWithTopImage:(UIImage *)topImage bottomImage:(UIImage *)bottomImage space:(CGFloat)space
{
    if (bottomImage == nil) {
        return topImage;
    }
    
    CGFloat width = topImage.size.width;
    CGFloat height = topImage.size.height + bottomImage.size.height + space;
    CGSize offScreenSize = CGSizeMake(width, height);
    
    UIGraphicsBeginImageContextWithOptions(offScreenSize, NO, [UIScreen mainScreen].scale);
    
    CGRect rectTop = CGRectMake(0, 0, width, topImage.size.height);
    [topImage drawInRect:rectTop];
    
    CGRect rectBottom = CGRectMake(0, topImage.size.height + space, width, bottomImage.size.height);
    [bottomImage drawInRect:rectBottom];
    
    UIImage *imageNew = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageNew;
}

// image是图片，blur是模糊度
+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur
{
    if (!image) {
        return nil;
    }
    
    double memFree = [[[SystemInfoFunc memoryStatus] objectForKey:kMemFreed] doubleValue];
    
    if (memFree/1024.0/1024.0 < 50) {
        return nil;
    }
    // 模糊度,
    if (blur < 0.025f) {
        blur = 0.025f;
    } else if (blur > 1.0f) {
        blur = 1.0f;
    }
    
    // boxSize必须大于0
    int boxSize = (int)(blur * 100);
    boxSize     -= (boxSize % 2) + 1;
    
    // 图像处理
    CGImageRef img = CGImageRetain(image.CGImage);

    // 数据源提供者，Defines an opaque type that supplies Quartz with data.
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    if (inProvider == NULL) {
        CGImageRelease(img);
        return nil;
    }
    
    // fix crash that ERROR_CGDataProvider_BufferIsNotReadable in iOS 11
    if (@available(iOS 11.0, *)) {
        NSMutableData *data = CGDataProviderGetInfo(inProvider);
        if (data.bytes == nil) {
            CGImageRelease(img);
            return nil;
        }
    }
    
    // provider’s data.
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    CFMutableDataRef mutableBitData = CFDataCreateMutableCopy(0, 0, inBitmapData);
    CFRelease(inBitmapData);
    
    // 图像缓存,输入缓存，输出缓存
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    
    // 像素缓存
    void *pixelBuffer;
    

    //宽，高，字节/行，data
    inBuffer.width      = CGImageGetWidth(img);
    inBuffer.height     = CGImageGetHeight(img);
    inBuffer.rowBytes   = CGImageGetBytesPerRow(img);
    inBuffer.data       = (void*)CFDataGetMutableBytePtr(mutableBitData);

    //像数缓存，字节行*图片高
    pixelBuffer         = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    outBuffer.data      = pixelBuffer;
    outBuffer.width     = CGImageGetWidth(img);
    outBuffer.height    = CGImageGetHeight(img);
    outBuffer.rowBytes  = CGImageGetBytesPerRow(img);
    
    // Convolves a region of interest within an ARGB8888 source image by an implicit M x N kernel that has the effect of a box filter.
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);

    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    // 颜色空间DeviceRGB
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 用图片创建上下文,CGImageGetBitsPerComponent(img),7,8
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(image.CGImage));
    
    // 根据上下文，处理过的图片，重新组件
    CGImageRef imageRef  = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    // clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    CFRelease(mutableBitData);
    CGImageRelease(img);
    CGImageRelease(imageRef);
    
    return returnImage;
}

+ (UIImage *)creatQRCodeImageWithString:(NSString *)string
                            logoImage:(UIImage *)logoImage{
    if (string.length == 0) {
        return nil;
    }
    NSArray *filter = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
    NSLog(@"%@", filter);
    // 二维码过滤器
    CIFilter *filterImage = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 将二位码过滤器设置为默认属性
    [filterImage setDefaults];
    // 将文字转化为二进制
    NSData *dataImage = [string dataUsingEncoding:NSUTF8StringEncoding];
    // 打印输入的属性
    NSLog(@"%@", filterImage.inputKeys);
    // KVC 赋值
    [filterImage setValue:dataImage forKey:@"inputMessage"];
    // 取出输出图片
    CIImage *outputImage = [filterImage outputImage];
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(20, 20)];
    // 转化图片
    UIImage *image = [UIImage imageWithCIImage:outputImage];
    // 为二维码加自定义图片
    // 开启绘图, 获取图片 上下文<图片大小>
    UIGraphicsBeginImageContext(image.size);
    // 将二维码图片画上去
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    CGFloat smallImageWidth = image.size.width*0.20;
    // 将小图片画上去
    UIImage *smallImage = logoImage;
    [smallImage drawInRect:CGRectMake((image.size.width - smallImageWidth) / 2, (image.size.width - smallImageWidth) / 2, smallImageWidth, smallImageWidth)];
    // 获取最终的图片
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    // 关闭上下文
    UIGraphicsEndImageContext();
    return finalImage;
}


/**
 * 根据CIImage生成指定大小的UIImage
 *
 * @param image CIImage
 * @param size 图片宽度
 */
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    CGColorSpaceRelease(cs);
    UIImage *resultImage = [UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    return resultImage;
}

+ (UIImage*) creatImageFromColors:(NSArray*)colors
                    ByGradientType:(GradientType)gradientType
                              size:(CGSize)size{
    NSMutableArray *ar = [NSMutableArray array];
    for(UIColor *c in colors) {
        [ar addObject:(id)c.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(size, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    CGPoint start;
    CGPoint end;
    switch (gradientType) {
        case 0:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(0.0, size.height);
            break;
        case 1:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(size.width, 0.0);
            break;
        case 2:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(size.width, size.height);
            break;
        case 3:
            start = CGPointMake(size.width, 0.0);
            end = CGPointMake(0.0,size.height);
            break;
        default:
            break;
    }
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
//    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)creatRedGradientImageWithSize:(CGSize)size
{
    return [UIImage creatImageFromColors:kRedGradientColorArray ByGradientType:leftToRight size:size];
}

+ (UIImage *)creatDarkRedGradientImageWithSize:(CGSize)size
{
    return [UIImage creatImageFromColors:kDarkRedGradientColorArray ByGradientType:leftToRight size:size];
}

+ (UIImage *)creatGreenGradientImageWithSize:(CGSize)size
{
    return [UIImage creatImageFromColors:kGreenGradientColorArray ByGradientType:leftToRight size:size];
}
+ (UIImage *)creatOrangeGradientImageWithSize:(CGSize)size
{
    return [UIImage creatImageFromColors:kOrangeGradientColorArray ByGradientType:leftToRight size:size];
}

@end
