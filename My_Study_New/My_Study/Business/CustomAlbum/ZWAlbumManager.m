//
//  ZWAlbumManager.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWAlbumManager.h"
#import "ZWUserInfoBridgeModule.h"

#define kThumWidth 125

@interface ZWAlbumManager ()

@property (nonatomic ,strong) NSMutableArray <PHAssetCollection *>* albumlist;

@property (nonatomic ,assign) BOOL reqAlbumComplete;

@property (nonatomic ,strong) PHImageRequestOptions * thumOption;

@property (nonatomic ,strong) PHImageRequestOptions * thumPreOption;

@property (nonatomic ,strong) PHImageRequestOptions * originalOption;

@property (nonatomic ,copy, readwrite) NSString *rootDir;

@end

@implementation ZWAlbumManager

+ (ZWAlbumManager *)manager{
    static ZWAlbumManager * _manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[ZWAlbumManager alloc] init];
    });
    return _manager;
}

- (instancetype)init{
    if (self = [super init]) {
        _mediaType = FvAlbumMediaTypeAllMedia;
        _selectType = FvAlbumSelectTypeMore;
        _maxSelectCount = 9;
        _allowPre = YES;
        _isCrop = NO;
        _cropRatio = 1;

        _reqAlbumComplete = YES;
        
        [self initCacheDir];
    }
    return self;
}

- (void)initCacheDir
{
    NSString *temPath = NSTemporaryDirectory();
    NSString * rootPath = [NSString stringWithFormat:@"%@/data/%@_image", temPath, [ZWUserInfoBridgeModule appName]];
    [[NSFileManager defaultManager] createDirectoryAtPath:rootPath withIntermediateDirectories:YES attributes:nil error:nil];
    self.rootDir = rootPath;
}

#pragma mark method

- (BOOL)checkIsVideo:(PHAsset *)asset{
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        return YES;
    }
    return NO;
}

- (void)checkCameraStatusComplete:(void (^)(BOOL success))complete{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        complete(YES);
    } else if (status == PHAuthorizationStatusDenied) {
        [Toast show:@"没有权限访问您的照片，请在“设置－隐私－照片”中允许使用"];
        complete(NO);
    } else if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    complete(YES);
                } else {
                    complete(NO);
                }
            });
        }];
    } else if (status == PHAuthorizationStatusRestricted) {
        complete(NO);
    }
}

- (void)updateSystemAlbumList:(void(^)(NSArray <PHAssetCollection *> * list,BOOL success))complete{
    __weak ZWAlbumManager * weakSelf = self;
    [self checkCameraStatusComplete:^(BOOL success) {
        if (success) {
            weakSelf.reqAlbumComplete = NO;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [weakSelf.albumlist removeAllObjects];
                // 获得相机胶卷
//                PHAssetCollection * cameraAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil].lastObject;
//                [weakSelf.albumlist addObject:cameraAlbum];
                      
                // 获得智能相册
                PHFetchResult<PHAssetCollection *> * smartAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
                [weakSelf addPhotoAlbums:smartAlbum];
                
                // 获得所有的自定义相簿
                PHFetchResult<PHAssetCollection *> * customAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
                [weakSelf addPhotoAlbums:customAlbums];
                
//
//                // 获得时刻相册
//                PHFetchResult<PHAssetCollection *> * momentAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeMoment subtype:PHAssetCollectionSubtypeAny options:nil];
//                [weakSelf addPhotoAlbums:momentAlbum];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.reqAlbumComplete = YES;
                    BlockSafeRun(complete,weakSelf.albumlist,YES);
                });
            });
        }
    }];
}

- (void)addPhotoAlbums:(PHFetchResult<PHAssetCollection *> *)sysAlbum{
    for (PHAssetCollection * album in sysAlbum) {
        if (self.mediaType == FvAlbumMediaTypePhoto) {
            if ([self checkHasPhotoType:album]) {
                [self.albumlist addObject:album];
            }
        }else if (self.mediaType == FvAlbumMediaTypeVideo){
            if ([self checkHasVideoType:album]) {
                [self.albumlist addObject:album];
            }
        }else if (self.mediaType == FvAlbumMediaTypeAllMedia){
            [self.albumlist addObject:album];
        }
    }
}

- (void)systemAlbumList:(void(^)(NSArray <PHAssetCollection *> * list))complete{
    if (self.albumlist.count > 0 && self.reqAlbumComplete) {
        BlockSafeRun(complete,self.albumlist);
    }else{
        [self updateSystemAlbumList:^(NSArray<PHAssetCollection *> * _Nonnull list, BOOL success) {
            if (success) {
                BlockSafeRun(complete,list);
            }
        }];
    }
}

- (void)reqCameraRollList:(void(^)(PHAssetCollection * list))complete{
    [self checkCameraStatusComplete:^(BOOL success) {
        if (success) {
            PHAssetCollection * cameraAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
            complete(cameraAlbum);
        }
    }];
}

- (NSArray <PHAssetModel *> *)photoList:(PHAssetCollection *)album{
    NSMutableArray <PHAssetModel *> * photoList = [NSMutableArray array];
    // 获得某个相簿中的所有PHAsset对象  options 排序  这里设置默认
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:album options:nil];
    for (PHAsset *asset in assets) {
        if (self.mediaType == FvAlbumMediaTypePhoto) {
            if (asset.mediaType == PHAssetMediaTypeImage) {
                PHAssetModel * assetModel = [PHAssetModel defaultItem];
                assetModel.asset = asset;
                [photoList addObject:assetModel];
            }
        }else if (self.mediaType == FvAlbumMediaTypeVideo){
            if (asset.mediaType == PHAssetMediaTypeVideo) {
                PHAssetModel * assetModel = [PHAssetModel defaultItem];
                assetModel.asset = asset;
                [photoList addObject:assetModel];
            }
        }else if (self.mediaType == FvAlbumMediaTypeAllMedia){
            PHAssetModel * assetModel = [PHAssetModel defaultItem];
            assetModel.asset = asset;
            [photoList addObject:assetModel];
        }
    }
    return [photoList copy];
}

- (void)thumbnail:(PHAsset *)asset complete:(void(^)(UIImage * result))complete{
//    [[FVCacheManager shared] requestImageForAsset:asset targetSize:CGSizeMake(kThumWidth, kThumWidth) contentMode:PHImageContentModeAspectFill options:self.thumOption resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//        if (complete) {
//            complete(result);
//        }
//    }];
}

- (void)thumbnailPre:(PHAsset *)asset complete:(void(^)(UIImage * result))complete{
    CGFloat ratio = (CGFloat)asset.pixelHeight / (CGFloat)asset.pixelWidth;
    CGFloat scale = [UIScreen mainScreen].scale;
//    [[FVCacheManager shared] requestImageForAsset:asset targetSize:CGSizeMake(kMainScreenWidth * scale, kMainScreenWidth * scale * ratio) contentMode:PHImageContentModeAspectFill options:self.thumPreOption resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//        if (complete) {
//            complete(result);
//        }
//    }];
}

- (void)originalGraph:(PHAsset *)asset complete:(void(^)(UIImage * result,NSDictionary * info))complete{
    // 获取PHImageManagerMaximumSize 图片打不开  暂时这样获取
    CGFloat ratio = (CGFloat)asset.pixelHeight / (CGFloat)asset.pixelWidth;
    CGFloat scale = [UIScreen mainScreen].scale;
//    [[FVCacheManager shared] requestImageForAsset:asset targetSize:CGSizeMake(kMainScreenWidth * scale, kMainScreenWidth * scale * ratio) contentMode:PHImageContentModeAspectFill options:self.originalOption resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//        if (complete) {
//            complete(result,info);
//        }
//    }];
}

- (void)originalGraphData:(PHAsset *)asset complete:(void(^)(NSData * _Nullable result))complete{
//    [[FVCacheManager shared] requestImageDataForAsset:asset options:self.originalOption resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//        if (complete) {
//            complete(imageData);
//        }
//    }];
}

- (void)cacheAsset:(PHAsset *)asset option:(PHImageRequestOptions *)option{
    CGFloat ratio = (CGFloat)asset.pixelHeight / (CGFloat)asset.pixelWidth;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize tagSize = CGSizeMake(kMainScreenWidth * scale, kMainScreenHeight * scale * ratio);
//    [[FVCacheManager shared] startCachingImagesForAssets:@[asset] targetSize:tagSize contentMode:PHImageContentModeAspectFill options:option];
}

- (void)stopCacheAsset:(PHAsset *)asset option:(PHImageRequestOptions *)option{
    CGFloat ratio = (CGFloat)asset.pixelHeight / (CGFloat)asset.pixelWidth;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize tagSize = CGSizeMake(kMainScreenWidth * scale, kMainScreenWidth * scale * ratio);
//    [[FVCacheManager shared] stopCachingImagesForAssets:@[asset] targetSize:tagSize contentMode:PHImageContentModeAspectFill options:option];
}

- (void)cacheAssetList:(NSArray <PHAsset*>*)assets option:(PHImageRequestOptions *)option{
    CGSize tagSize = CGSizeMake(kThumWidth, kThumWidth);
//    [[FVCacheManager shared] startCachingImagesForAssets:assets targetSize:tagSize contentMode:PHImageContentModeAspectFill options:option];
}

- (void)stopCacheAssetList:(NSArray <PHAsset*>*)assets option:(PHImageRequestOptions *)option{
    CGSize tagSize = CGSizeMake(kThumWidth, kThumWidth);
//    [[FVCacheManager shared] stopCachingImagesForAssets:assets targetSize:tagSize contentMode:PHImageContentModeAspectFill options:option];
}

#pragma mark other

// 检查相册中是否含有图片资源
- (BOOL)checkHasPhotoType:(PHAssetCollection *)collect{
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:collect options:nil];
    for (PHAsset * asset in assets) {
        if (asset.mediaType == PHAssetMediaTypeImage) {
            return YES;
        }
    }
    return NO;
}

// 检查相册中是否含有视频资源
- (BOOL)checkHasVideoType:(PHAssetCollection *)collect{
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:collect options:nil];
    for (PHAsset * asset in assets) {
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            return YES;
        }
    }
    return NO;
}


#pragma mark lazyLoad

- (NSMutableArray <PHAssetCollection *>*)albumlist{
    if (!_albumlist) {
        _albumlist = [NSMutableArray array];
    }
    return _albumlist;
}

- (PHImageRequestOptions *)thumOption{
    if (!_thumOption) {
        _thumOption = [[PHImageRequestOptions alloc] init];
        _thumOption.synchronous = YES;
        _thumOption.resizeMode = PHImageRequestOptionsResizeModeExact;
        _thumOption.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        _thumOption.networkAccessAllowed = YES;
    }
    return _thumOption;
}

- (PHImageRequestOptions *)thumPreOption{
    if (!_thumPreOption) {
        _thumPreOption = [[PHImageRequestOptions alloc] init];
        _thumPreOption.synchronous = YES;
        _thumPreOption.resizeMode = PHImageRequestOptionsResizeModeExact;
        _thumPreOption.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        _thumPreOption.networkAccessAllowed = YES;
    }
    return _thumPreOption;
}

- (PHImageRequestOptions *)originalOption{
    if (!_originalOption) {
        _originalOption = [[PHImageRequestOptions alloc] init];
        _originalOption.synchronous = YES;
        _originalOption.resizeMode = PHImageRequestOptionsResizeModeExact;
        _originalOption.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        _originalOption.networkAccessAllowed = YES;
    }
    return _originalOption;
}




@end
