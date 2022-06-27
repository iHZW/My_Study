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

+ (UIImage *)scaleImageNamed:(NSString *)name
                       scale:(CGFloat)factor
                      bundle:(NSBundle *)bundle
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


#pragma mark - 压缩图片到指定大小(单位KB)
+ (NSData *)resetSizeOfImageData:(UIImage *)sourceImage maxSize:(NSInteger)maxSize {

    __block NSData *finallImageData = UIImageJPEGRepresentation(sourceImage,1.0);
    NSUInteger sizeOrigin   = finallImageData.length;
    NSUInteger sizeOriginKB = sizeOrigin / 1000;
    
    if (sizeOriginKB <= maxSize) {
        return finallImageData;
    }
    
    CGFloat sourceImageAspectRatio = sourceImage.size.width/sourceImage.size.height;

    CGSize defaultSize = CGSizeMake(1024, 1024/sourceImageAspectRatio);
    UIImage *newImage = [self newSizeImage:defaultSize image:sourceImage];
    
    finallImageData = UIImageJPEGRepresentation(newImage,1.0);
    
    NSMutableArray *compressionQualityArr = [NSMutableArray array];
    CGFloat avg   = 1.0/250;
    CGFloat value = avg;
    for (int i = 250; i >= 1; i--) {
        value = i*avg;
        [compressionQualityArr addObject:@(value)];
    }
    
    __block NSData *canCompressMinData = [NSData data];//当无法压缩到指定大小时，用于存储当前能够压缩到的最小值数据。
    [self halfFuntion:compressionQualityArr image:newImage sourceData:finallImageData maxSize:maxSize resultBlock:^(NSData *finallData, NSData *tempData) {
        finallImageData = finallData;
        canCompressMinData = tempData;
    }];
    while (finallImageData.length == 0) {
        CGFloat reduceWidth = 100.0;
        CGFloat reduceHeight = 100.0/sourceImageAspectRatio;
        if (defaultSize.width-reduceWidth <= 0 || defaultSize.height-reduceHeight <= 0) {
            break;
        }
        defaultSize = CGSizeMake(defaultSize.width-reduceWidth, defaultSize.height-reduceHeight);
        UIImage *image = [self newSizeImage:defaultSize
                                      image:[UIImage imageWithData:UIImageJPEGRepresentation(newImage,[[compressionQualityArr lastObject] floatValue])]];
        [self halfFuntion:compressionQualityArr image:image sourceData:UIImageJPEGRepresentation(image,1.0) maxSize:maxSize resultBlock:^(NSData *finallData, NSData *tempData) {
            finallImageData = finallData;
            canCompressMinData = tempData;
        }];
    }
    if (finallImageData.length==0) {
        finallImageData = canCompressMinData;
    }
    return finallImageData;
}

#pragma mark 调整图片分辨率/尺寸（等比例缩放）

+ (UIImage *)newSizeImage:(CGSize)size image:(UIImage *)sourceImage {
    CGSize newSize = CGSizeMake(sourceImage.size.width, sourceImage.size.height);
    
    CGFloat tempHeight = newSize.height / size.height;
    CGFloat tempWidth = newSize.width / size.width;
    
    if (tempWidth > 1.0 && tempWidth > tempHeight) {
        newSize = CGSizeMake(sourceImage.size.width / tempWidth, sourceImage.size.height / tempWidth);
    } else if (tempHeight > 1.0 && tempWidth < tempHeight) {
        newSize = CGSizeMake(sourceImage.size.width / tempHeight, sourceImage.size.height / tempHeight);
    }
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1);
    [sourceImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



#pragma mark 调整图片分辨率/尺寸（供tabbar 适用， 从上面newSizeImage 方法修改而来）

+ (UIImage *)tabbarSizeImage:(CGSize)size image:(UIImage *)sourceImage {
    CGSize newSize = CGSizeMake(sourceImage.size.width, sourceImage.size.height);
    
    CGFloat tempHeight = newSize.height / size.height;
    CGFloat tempWidth = newSize.width / size.width;
    
    if (tempWidth > 1.0 && tempWidth > tempHeight) {
        newSize = CGSizeMake(sourceImage.size.width / tempWidth, sourceImage.size.height / tempWidth);
    } else if (tempHeight > 1.0 && tempWidth < tempHeight) {
        newSize = CGSizeMake(sourceImage.size.width / tempHeight, sourceImage.size.height / tempHeight);
    } else if (tempWidth > 1.0 || tempHeight > 1.0){
        newSize = size;
    }
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, UIScreen.mainScreen.scale);
    [sourceImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark halfFuntion

+ (void)halfFuntion:(NSArray *)arr image:(UIImage *)image sourceData:(NSData *)finallImageData maxSize:(NSInteger)maxSize resultBlock:(void(^)(NSData *finallData, NSData *tempData))block {
    NSData *tempData = [NSData data];
    NSUInteger start = 0;
    NSUInteger end = arr.count - 1;
    NSUInteger index = 0;
    
    NSUInteger difference = NSIntegerMax;
    while(start <= end) {
        index = start + (end - start)/2;
        
        finallImageData = UIImageJPEGRepresentation(image,[arr[index] floatValue]);
        
        NSUInteger sizeOrigin = finallImageData.length;
        NSUInteger sizeOriginKB = sizeOrigin / 1000;
        
        if (sizeOriginKB > maxSize) {
            start = index + 1;
        } else if (sizeOriginKB < maxSize) {
            if (maxSize-sizeOriginKB < difference) {
                difference = maxSize-sizeOriginKB;
                tempData = finallImageData;
            }
            if (index<=0) {
                break;
            }
            end = index - 1;
        } else {
            break;
        }
    }
    NSData *d = [NSData data];
    if (tempData.length==0) {
        d = finallImageData;
    }
    if (block) {
        block(tempData, d);
    }
}




@end
