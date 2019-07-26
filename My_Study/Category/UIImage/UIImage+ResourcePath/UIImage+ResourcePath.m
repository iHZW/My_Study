//
//  UIImageResourcePath.m
//  LXIphone
//
//  Copyright (c) 2012年 xzq2325. All rights reserved.
//

#import "UIImage+ResourcePath.h"

@implementation UIImage (ResourcePath)

/**
 * 通过图片名字获取图片数据，图片名字可以不全 scale 几倍屏
 */
+ (NSData *)getDataWithImageName:(NSString *)name scale:(int)scale
{
    NSData *imgData = nil;
    NSArray *pathArr = [name componentsSeparatedByString:@"."];
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    
    NSString *filePath = [resourcePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@@%dx",[pathArr firstObject],scale]];
    
    NSString *resultPath = nil;
    
    //添加后缀
    if (pathArr.count >= 2) {//图片名自带后缀时
        resultPath = [filePath stringByAppendingString:pathArr[1]];
        imgData = [NSData dataWithContentsOfFile:resultPath];
    } else {//尝试添加后缀
        resultPath = [filePath stringByAppendingString:@".jpg"];
        imgData = [NSData dataWithContentsOfFile:resultPath];
        
        if (!imgData) { //当不是.jpg时，尝试png
            resultPath = [filePath stringByAppendingString:@".png"];
            imgData = [NSData dataWithContentsOfFile:resultPath];
        }
    }
    
    return imgData;
}

/**
 *  通过图片名字创建实例image，不支持asset中图片
 */
+ (UIImage*)imageWithResourcePathofFile:(NSString*)path
{
    if (path == NULL)
        return NULL;
    
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString* filePath = [resourcePath stringByAppendingPathComponent:path];
    NSData *imgData = [NSData dataWithContentsOfFile:filePath];
    if (!imgData) {//当文件名不对时，尝试屏幕分辨率比例
        imgData = [UIImage getDataWithImageName:path scale:(int)([UIScreen mainScreen].scale)];
        if (!imgData && ((int)[UIScreen mainScreen].scale != 2)) {//最后尝试2倍图
            imgData = [UIImage getDataWithImageName:path scale:2];
        }
    }
    return [UIImage imageWithData:imgData];
}

+ (UIImage *)adaptedimage:(NSString *)name
{
    if (name == NULL)
        return NULL;
    
    //4寸屏幕
    if (CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(320, 568)) == YES)
    {
        NSArray* pAry = [name componentsSeparatedByString:@"@"];
        if (pAry.count == 2) {
            return [UIImage imageNamed:[NSString stringWithFormat:@"%@-568h@%@",[pAry objectAtIndex:0],[pAry objectAtIndex:1]]];
        }
        
        pAry = [name componentsSeparatedByString:@"."];
        
        if ([pAry count] != 2)
            return [UIImage imageNamed:name];
        
        return [UIImage imageNamed:[NSString stringWithFormat:@"%@-568h.%@",[pAry objectAtIndex:0],[pAry objectAtIndex:1]]];
    }
    
    return [UIImage imageNamed:name];;
}



+ (UIImage *)colorizeImage:(UIImage *)image withColor:(UIColor *)color {
    
    if (image == NULL)
        return NULL;
    
    UIGraphicsBeginImageContext(image.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -area.size.height);
    
    CGContextSaveGState(context);
    CGContextClipToMask(context, area, image.CGImage);
    
    [color set];
    CGContextFillRect(context, area);
    
    CGContextRestoreGState(context);
    
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    
    CGContextDrawImage(context, area, image.CGImage);
    
    UIImage *colorizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return colorizedImage;
}

+ (UIImage *)createImageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)imageCutImageInView:(UIView *)view frame:(CGRect)frame {
    if (view == nil) {
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(640, 960), YES, 0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageRef = viewImage.CGImage;
    CGImageRef imageRefRect =CGImageCreateWithImageInRect(imageRef, frame);
    UIImage *cutImage = [[UIImage alloc] initWithCGImage:imageRefRect];
    CGImageRelease(imageRefRect);
    return cutImage;
}

+ (NSString *)pathCutImageInView:(UIView *)view frame:(CGRect)frame {
    if (view == nil) {
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(640, 960), YES, 0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageRef = viewImage.CGImage;
    CGImageRef imageRefRect =CGImageCreateWithImageInRect(imageRef, frame);
    UIImage *cutImage = [[UIImage alloc] initWithCGImage:imageRefRect];
    NSData *imageViewData = UIImagePNGRepresentation(cutImage);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:@"result.png"];
//    CMLogDebug(LogBusinessBasicLib, @"%@", savedImagePath);
    [imageViewData writeToFile:savedImagePath atomically:YES];
    CGImageRelease(imageRefRect);
    return savedImagePath;
}

+ (UIImage *)createTriangleImageWithfillColor:(UIColor *)fillColor
                                    pathColor:(UIColor *)pathColor
                                  orientation:(UIInterfaceOrientation)orientation
                                         size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, YES);
    
    /*画三角形*/
    //只要三个点就行跟画一条线方式一样，把三点连接起来
    CGPoint sPoints[3];//坐标点
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
        {
            sPoints[0] =CGPointMake(0, size.height);
            sPoints[1] =CGPointMake(size.width / 2, 0);
            sPoints[2] =CGPointMake(size.width, size.height);
        }
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            sPoints[0] =CGPointMake(0, 0);
            sPoints[1] =CGPointMake(size.width, 0);
            sPoints[2] =CGPointMake(size.width / 2, size.height);
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:
        {
            sPoints[0] =CGPointMake(0, 0);
            sPoints[1] =CGPointMake(size.width, size.height / 2);
            sPoints[2] =CGPointMake(0, size.height);
        }
            break;
        case UIInterfaceOrientationLandscapeRight:
        {
            sPoints[0] =CGPointMake(0, size.height / 2);
            sPoints[1] =CGPointMake(size.width, 0);
            sPoints[2] =CGPointMake(size.width, size.height);
        }
            break;
        default:
            break;
    }
    
    CGContextAddLines(context, sPoints, 3);//添加线
    CGContextClosePath(context);//封起来
    
    //根据坐标绘制
    if (pathColor) // 绘制边框
    {
        CGContextSetStrokeColorWithColor(context, [pathColor CGColor]);
        CGContextStrokePath(context);
    }
    
    if (fillColor) // 绘制背景内容
    {
        CGContextSetFillColorWithColor(context, [fillColor CGColor]);
        CGContextFillPath(context);
    }
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)image3xWithNamed:(NSString *)name bundle:(NSBundle *)bundle
{
    UIImage *img        = [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:nil]];
    CGImageRef cgimage  = img.CGImage;
    img                 = [UIImage imageWithCGImage:cgimage scale:3.0 orientation:UIImageOrientationUp];
    
    return img;
}

+ (UIImage *)image3xWithNamed:(NSString *)name
{
    return [self image3xWithNamed:name bundle:[NSBundle mainBundle]];
}

+ (UIImage *)scaleImageNamed:(NSString *)name scale:(CGFloat)factor bundle:(NSBundle *)bundle
{
    UIImage *img        = [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:nil]];
    CGImageRef cgimage  = img.CGImage;
    img                 = [UIImage imageWithCGImage:cgimage scale:factor orientation:UIImageOrientationUp];
    
    return img;
}

+ (UIImage *)scaleImageNamed:(NSString *)name scale:(CGFloat)factor
{
    return [self scaleImageNamed:name scale:factor bundle:[NSBundle mainBundle]];
}

@end
