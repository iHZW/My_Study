//
//  ZWAlbumManager.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMObject.h"
#import "PHAssetModel.h"
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SelectImageComplete)(NSArray <PHAssetModel *> * obj,BOOL isOriginal);

typedef NS_ENUM(NSUInteger,ZWAlbumMediaType) {
    ZWAlbumMediaTypePhoto = 0, //照片
    ZWAlbumMediaTypeVideo,     //视频
    ZWAlbumMediaTypeAllMedia   //照片和视频
};

typedef NS_ENUM(NSUInteger,ZWAlbumSelectType) {
    ZWAlbumSelectTypeSingle = 0, //单选
    ZWAlbumSelectTypeMore,       //多选
};


@interface ZWAlbumManager : NSObject//CMObject

// 相册资源类型
@property (nonatomic ,assign) ZWAlbumMediaType mediaType;

// 最大可选数
@property (nonatomic ,assign) NSInteger maxSelectCount;

// 是否裁剪
@property (nonatomic ,assign) BOOL isCrop;

// 裁剪比例   高/宽
@property (nonatomic ,assign) CGFloat cropRatio;

// 单选/多选
@property (nonatomic ,assign) ZWAlbumSelectType selectType;

// 是否可预览
@property (nonatomic ,assign) BOOL allowPre;

@property (nonatomic ,copy ,readonly) NSString * rootDir;

@property (nonatomic ,strong ,readonly) PHImageRequestOptions * thumOption;

@property (nonatomic ,strong ,readonly) PHImageRequestOptions * thumPreOption;

@property (nonatomic ,strong ,readonly) PHImageRequestOptions * originalOption;


@property (nonatomic ,copy) SelectImageComplete selectImageComplete;

+ (ZWAlbumManager *)manager;

// 效验相册权限
- (void)checkCameraStatusComplete:(void (^)(BOOL success))complete;

// 效验PHAsset是否是视频
- (BOOL)checkIsVideo:(PHAsset *)asset;

// 更新所有相册列表
- (void)updateSystemAlbumList:(nullable void(^)(NSArray <PHAssetCollection *> * list,BOOL success))complete;

// 获取所有相册列表
- (void)systemAlbumList:(void(^)(NSArray <PHAssetCollection *> * list))complete;

// 单独获取相机胶卷里的资源列表
- (void)reqCameraRollList:(void(^)(PHAssetCollection * list))complete;

// 获取指定相册里的资源列表
- (NSArray <PHAssetModel *> *)photoList:(PHAssetCollection *)album;

// 获取图片对象的缩略图
- (void)thumbnail:(PHAsset *)asset complete:(void(^)(UIImage * result))complete;

// 获取图片对象的预览图
- (void)thumbnailPre:(PHAsset *)asset complete:(void(^)(UIImage * result))complete;

// 获取图片对象的原图
- (void)originalGraph:(PHAsset *)asset complete:(void(^)(UIImage * result,NSDictionary * info))complete;

// 获取图片的原始Data
- (void)originalGraphData:(PHAsset *)asset complete:(void(^)(NSData * _Nullable result))complete;

// 缓存asset
- (void)cacheAsset:(PHAsset *)asset option:(PHImageRequestOptions *)option;

// 停止缓存asset
- (void)stopCacheAsset:(PHAsset *)asset option:(PHImageRequestOptions *)option;

// 缓存asset数组
- (void)cacheAssetList:(NSArray <PHAsset*>*)assets option:(PHImageRequestOptions *)option;

// 停止缓存asset数组
- (void)stopCacheAssetList:(NSArray <PHAsset*>*)assets option:(PHImageRequestOptions *)option;


@end

NS_ASSUME_NONNULL_END
