//
//  ZWImageUtil.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWImageUtil.h"
#import "PHAssetModel.h"
#import "ProgressHUD.h"
#import "ZWAlbumManager.h"
#import "UIApplication+Ext.h"
#import "NSFileManager+Ext.h"

@implementation ZWImageUtil

+ (void)configPathWithModel:(NSArray<PHAssetModel *>*)selectArr complete:(void(^)(NSArray<PHAssetModel *>*))complete{
    __block NSInteger index = 0;
    [ProgressHUD showHUDAddedTo:[UIApplication displayWindow]];
    for (PHAssetModel * model in selectArr) {
        if (!model.asset) { // 拍照进来
            if (model.originalImage) {
                NSString *fileName = [[NSFileManager defaultManager] generateRandomImageName];
                NSString *fullPath = [[ZWAlbumManager manager].rootDir stringByAppendingPathComponent:fileName];
                [self saveImage:model.cropImage ? model.cropImage : model.originalImage toPath:fullPath];
                NSURL *fileURL = [NSURL fileURLWithPath:fullPath];
                model.originalPath = fileURL.absoluteString;
                model.thumPath = fileURL.absoluteString;
                if (index == selectArr.count - 1) {
                      [ProgressHUD hideHUDProgress:[UIApplication displayWindow]];
                      complete(selectArr);
                }
                index ++;
            }
        }else{
            if (model.asset.mediaType == PHAssetMediaTypeImage) {
                if (model.cropImage) { // 裁剪后进来
                    NSString *fileName = [[NSFileManager defaultManager] generateRandomImageName];
                    NSString *fullPath = [[ZWAlbumManager manager].rootDir stringByAppendingPathComponent:fileName];
                    [self saveImage:model.cropImage toPath:fullPath];
                    NSURL *fileURL = [NSURL fileURLWithPath:fullPath];
                    model.originalPath = fileURL.absoluteString;
                    model.thumPath = fileURL.absoluteString;
                    if (index == selectArr.count - 1) {
                          [ProgressHUD hideHUDProgress:[UIApplication displayWindow]];
                          complete(selectArr);
                    }
                    index ++;
                }else{ // 正常流程
                    [[ZWAlbumManager manager] originalGraph:model.asset complete:^(UIImage * _Nonnull result, NSDictionary * _Nonnull info) {
                        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                        if (!downloadFinined) {
                            return;
                        }
//                        NSURL * url = [info objectForKey:@"PHImageFileURLKey"];
//                        if (url) {
//                            model.originalPath = url.absoluteString;
//                        }else{
                            NSString *fileName = [[NSFileManager defaultManager] generateRandomImageName];
                            NSString *fullPath = [[ZWAlbumManager manager].rootDir stringByAppendingPathComponent:fileName];
                            [self saveImage:result toPath:fullPath];
                            model.originalPath = [NSURL fileURLWithPath:fullPath].absoluteString;
//                        }
                        [ZWImageUtil compressedImage:result maxSize:600 complete:^(UIImage * _Nonnull img, NSData * _Nullable data) {
                            
                            NSString *fileName = [[NSFileManager defaultManager] generateRandomImageName];
                            NSString *fullPath = [[ZWAlbumManager manager].rootDir stringByAppendingPathComponent:fileName];
                            [self saveImage:img toPath:fullPath];
                            
                            NSURL *fileURL = [NSURL fileURLWithPath:fullPath];
                            model.thumPath = fileURL.absoluteString;
                            
                            if (index == selectArr.count - 1) {
                                [ProgressHUD hideHUDProgress:[UIApplication displayWindow]];
                                complete(selectArr);
                            }
                            index ++;
                        }];
                    }];
                }
            }else{
                // 视频暂时不兼容
            }
        }
    }
}

+ (BOOL)saveImage:(UIImage *)image toPath:(NSString *)filePath{
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    return [self saveData:imageData toPath:filePath];
}

+ (BOOL)saveData:(NSData *)imageData toPath:(NSString *)filePath{
    return [imageData writeToFile:filePath atomically:YES];
}

+ (void)compressedImage:(UIImage *)image maxSize:(CGFloat)maxSize complete:(void(^)(UIImage * _Nonnull img ,NSData * _Nullable data))complete{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSData * data = UIImageJPEGRepresentation(image, 1.0);
        CGFloat dataKBytes = data.length/1000.0;
      
        if (dataKBytes < maxSize) {
            dispatch_async(dispatch_get_main_queue(), ^{
                BlockSafeRun(complete,[UIImage imageWithData:data],data);
            });
        }
      
        CGFloat maxQuality = 0.9f;
        while (dataKBytes > maxSize && maxQuality > 0.1f) {
            maxQuality = maxQuality - 0.1f;
            data = UIImageJPEGRepresentation(image, maxQuality);
            dataKBytes = data.length / 1000.0;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            BlockSafeRun(complete,[UIImage imageWithData:data],data);
        });
    });
}

+ (UIImage*)scaleImage:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
