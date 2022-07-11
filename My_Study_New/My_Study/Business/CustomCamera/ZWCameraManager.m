//
//  ZWCameraManager.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWCameraManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ZWCameraViewController.h"
#import "ZWCameraPreViewController.h"
#import "PHAssetModel.h"
#import "ZWCameraUtil.h"
#import "ZWUserInfoBridgeModule.h"
#import "ZWNavigationController.h"
#import "UIApplication+Ext.h"
#import "UIViewController+Additions.h"


@interface ZWCameraManager ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *picker;

@property (nonatomic ,copy) NSString * rootDir;

@end

@implementation ZWCameraManager
DEFINE_SINGLETON_T_FOR_CLASS(ZWCameraManager)

- (instancetype)init
{
    if (self = [super init]) {
        
        self.videoMaximumDuration = 100000000.0f;
        [self initCacheDir];
    }
    return self;
}

- (void)initCacheDir
{
    NSString *temPath = NSTemporaryDirectory();
    NSString * rootPath = [NSString stringWithFormat:@"%@/data/%@_video",temPath, [ZWUserInfoBridgeModule appName]];
    [[NSFileManager defaultManager] createDirectoryAtPath:rootPath withIntermediateDirectories:YES attributes:nil error:nil];
    self.rootDir = rootPath;
}


/** 检测相机权限  */
- (void)checkCameraPermissionsIfNeeded:(void (^)(BOOL success))handler
{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        if (handler) handler(YES);
    } else if(authStatus == AVAuthorizationStatusDenied) {
        if (handler) handler(NO);
    } else if(authStatus == AVAuthorizationStatusRestricted) {
        if (handler) handler(NO);
    } else if(authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(granted){
                    if (handler) handler(YES);
                } else {
                    if (handler) handler(NO);
                }
            });
        }];
    } else {
        // impossible, unknown authorization status
        if (handler) handler(NO);
    }
}
/** 展示系统相机  */
- (void)showSysCamera
{
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"模拟器");
#else
    [self checkCameraPermissionsIfNeeded:^(BOOL success) {
        if (success && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            ZWCameraViewController *vc = [[ZWCameraViewController alloc]init];
    
            ZWNavigationController *na = [[ZWNavigationController alloc]initWithRootViewController:vc];
            na.modalPresentationStyle = UIModalPresentationFullScreen;
            [[UIApplication displayViewController] presentViewController:na animated:YES completion:nil];
        }
    }];
#endif
}
/** 展示系统录像  */
- (void)showSysVideotape
{
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"模拟器");
#else
    __weak ZWCameraManager * weakSelf = self;
    [self checkCameraPermissionsIfNeeded:^(BOOL success) {
        if (success && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            weakSelf.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            weakSelf.picker.mediaTypes =  [[NSArray alloc] initWithObjects:(NSString*)kUTTypeMovie,nil];
            weakSelf.picker.videoMaximumDuration = weakSelf.videoMaximumDuration; // 视频的最大录制时长
            weakSelf.picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
            weakSelf.picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo; //相机的模式 拍照/摄像
            [[UIApplication displayViewController] presentViewController:self.picker animated:YES completion:nil];
        }
    }];
#endif
}
/** 选择视频(过滤掉图片)  */
- (void)showAlbumVideo
{
    __weak ZWCameraManager * weakSelf = self;
    [self checkCameraPermissionsIfNeeded:^(BOOL success) {
        if (success && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            weakSelf.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            weakSelf.picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeMovie,nil];
            [[UIApplication displayViewController] presentViewController:self.picker animated:YES completion:nil];
        }
    }];
}



#pragma mark delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        // 图片处理
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        PHAssetModel * data = [[PHAssetModel alloc]init];
        data.originalImage = image;
        
//        FvAlbumCropViewController * vc = [[FvAlbumCropViewController alloc]init];
//        __weak FvCameraManager * weakSelf = self;
//        [[FvAlbumManager manager] setSelectImageComplete:^(NSArray<PHAssetModel *> * _Nonnull obj, BOOL isOriginal) {
//            BlockSafeRun(weakSelf.cameraCompleteHander,obj,FvCameraStylePhoto);
//        }];
//        vc.data = data;
//        [self.picker.navigationController pushViewController:vc animated:YES];
    }else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.picker dismissViewControllerAnimated:YES completion:^{
            __block AVAssetExportSession *exportSession = nil;
            __block BOOL isCanceled = NO;
            UIViewController *currentVC = [UIApplication rootViewController];
            @weakify(currentVC)
            [currentVC showProgress:nil title:@"上传中..." tapHandler:^{
                @strongify(currentVC)
                [currentVC hideProgress];
                isCanceled = YES;
                [exportSession cancelExport];
            }];
            // 视频处理
            NSURL * videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
            
            __weak ZWCameraManager * weakSelf = self;
                exportSession = [ZWCameraUtil changeMp4:videoUrl complete:^(NSURL * _Nonnull resultUrl) {
                if (isCanceled){
                    return;
                }
                [currentVC hideProgress];
                PHAssetModel * data = [[PHAssetModel alloc]init];
                data.mediaURL = resultUrl.absoluteString;
                BlockSafeRun(weakSelf.cameraCompleteHander,@[data],ZWCameraStyleVideo);
            }];
        }];
    }
}




#pragma mark lazyLoad

- (UIImagePickerController *)picker{
    if (!_picker) {
        _picker = [[UIImagePickerController alloc] init];
        _picker.modalPresentationStyle = UIModalPresentationFullScreen;
        _picker.delegate = self;
        _picker.navigationBar.translucent=NO;
    }
    return _picker;
}


@end
