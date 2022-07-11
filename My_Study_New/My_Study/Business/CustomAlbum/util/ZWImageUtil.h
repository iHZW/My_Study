//
//  ZWImageUtil.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMObject.h"

NS_ASSUME_NONNULL_BEGIN

@class PHAssetModel;

@interface ZWImageUtil : CMObject

+ (void)configPathWithModel:(NSArray<PHAssetModel *>*)selectArr complete:(void(^)(NSArray<PHAssetModel *>*))complete;

+ (void)compressedImage:(UIImage *)image maxSize:(CGFloat)maxSize complete:(void(^)(UIImage * _Nonnull img ,NSData * _Nullable data))complete;

+ (UIImage*)scaleImage:(UIImage*)image scaledToSize:(CGSize)newSize;


@end

NS_ASSUME_NONNULL_END
