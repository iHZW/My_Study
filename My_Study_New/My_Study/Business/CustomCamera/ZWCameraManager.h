//
//  ZWCameraManager.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMObject.h"
#import "PHAssetModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,ZWCameraStyle) {
    /** 图片  */
    ZWCameraStylePhoto = 0,
    /** 视频  */
    ZWCameraStyleVideo
};

typedef void(^CameraDidComplete)(NSArray <PHAssetModel *> *,ZWCameraStyle);

@interface ZWCameraManager : CMObject
DEFINE_SINGLETON_T_FOR_HEADER(ZWCameraManager)
/** 根路径  */
@property (nonatomic, copy, readonly) NSString *rootDir;
/** 拍照完成回调  */
@property (nonatomic ,copy) CameraDidComplete cameraCompleteHander;
/** 视频最小持续时间  */
@property (nonatomic ,assign) CGFloat videoMaximumDuration;


/** 检测相机权限  */
- (void)checkCameraPermissionsIfNeeded:(void (^)(BOOL success))handler;
/** 展示系统相机  */
- (void)showSysCamera;
/** 展示系统录像  */
- (void)showSysVideotape;
/** 选择视频(过滤掉图片)  */
- (void)showAlbumVideo;

@end

NS_ASSUME_NONNULL_END
