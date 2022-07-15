//
//  PhotoActionSheetUtil.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "PhotoActionSheetUtil.h"
#import "ZWAlbumDetailsViewController.h"
#import "FileSelectManager.h"
#import "AlertView.h"
#import "PHAssetModel.h"
#import "UIColor+Ext.h"
#import "Permission.h"
#import "UIApplication+Ext.h"
#import "ZWNavigationController.h"
#import "UIColor+Ext.h"

@implementation PhotoActionSheetUtil

+ (void)showPhotoAlert:(void(^)(NSArray<PHAssetModel *>*))complete{
    AlertView *alertView = [[AlertView alloc] init];
    alertView.actionType = ActionTypeActionSheet;

    AlertAction * photoAction = [AlertAction action:@"拍照" textColor:[UIColor colorFromHexCode:@"#333333"] backgroudColor:[UIColor whiteColor] clickCallback:^{
        [alertView hidden];
        [PhotoActionSheetUtil goPhoto:complete];
    }];

    AlertAction * cameraAction = [AlertAction action:@"从相册选择" textColor:[UIColor colorFromHexCode:@"#333333"] backgroudColor:[UIColor whiteColor] clickCallback:^{
        [alertView hidden];
        [PhotoActionSheetUtil goCameraAlbum:9 complete:complete];
    }];
    
    alertView.actions = @[
        photoAction,cameraAction
    ];
        
    alertView.footerAction = [AlertAction action:@"取消" textColor:[UIColor colorFromHexCode:@"#999999"] backgroudColor:[UIColor whiteColor] clickCallback:^{
        [alertView hidden];
    }];
    [alertView show];
}

+ (void)showPhotoAlert:(NSInteger)maxCount
              complete:(void(^)(NSArray<PHAssetModel *>*))complete
            isShowFile:(BOOL)isShowFile{
    AlertView *alertView = [[AlertView alloc] init];
    alertView.actionType = ActionTypeActionSheet;

    AlertAction * photoAction = [AlertAction action:@"拍照" textColor:[UIColor colorFromHexCode:@"#333333"] backgroudColor:[UIColor whiteColor] clickCallback:^{
        [alertView hidden];
        [Permission requestForType:PermissionTypeCamera notAuthorizedMessage: @"此功能需要使用“相机”，打开后，可拍摄照片、视频应用于记录跟进。<br/><br/>是否同意使用相机？如需使用，请在“系统设置”或授权对话框中允许“相机”权限。" complete:^(PermissionAuthorizationStatus status) {
            if (status == PermissionAuthorizationStatusAuthorized){
                [PhotoActionSheetUtil goPhoto:complete];
            }
        }];
    }];

    AlertAction * cameraAction = [AlertAction action:@"从相册选择" textColor:[UIColor colorFromHexCode:@"#333333"] backgroudColor:[UIColor whiteColor] clickCallback:^{
        [alertView hidden];
        [Permission requestForType:PermissionTypePhotoLibrary notAuthorizedMessage: @"此功能需要使用“照片”，打开后，可从相册中选择图片、视频上传至应用内记录跟进。<br/><br/>是否同意使用照片？如需使用，请在“系统设置”或授权对话框中允许“照片”权限。" complete:^(PermissionAuthorizationStatus status) {
            if (status == PermissionAuthorizationStatusAuthorized){
                [PhotoActionSheetUtil goCameraAlbum:maxCount complete:complete];
            }
        }];
        
    }];
    
    AlertAction * fileAction = [AlertAction action:@"从本地文件选择" textColor:[UIColor colorFromHexCode:@"#333333"] backgroudColor:[UIColor whiteColor] clickCallback:^{
        [alertView hidden];
        [PhotoActionSheetUtil goFielSelect:maxCount complete:complete];
    }];
    
    NSArray *actionArr = @[photoAction,
                           cameraAction];
    
    if (isShowFile) {
        actionArr = @[photoAction,
                      cameraAction,
                      fileAction];
    }
    
    alertView.actions = actionArr;

    alertView.footerAction = [AlertAction action:@"取消" textColor:[UIColor colorFromHexCode:@"#999999"] backgroudColor:[UIColor whiteColor] clickCallback:^{
        [alertView hidden];
    }];
    [alertView show];
}

+ (void)goPhoto:(void(^)(NSArray<PHAssetModel *>*))complete{
    [ZWAlbumManager manager].isCrop = NO;
    [[ZWCameraManager sharedZWCameraManager] showSysCamera];
    [[ZWCameraManager sharedZWCameraManager] setCameraCompleteHander:^(NSArray<PHAssetModel *> * _Nonnull array, ZWCameraStyle style) {
        if (style == ZWCameraStylePhoto) {
            BlockSafeRun(complete,array);
        }
    }];
}

+ (void)goCameraAlbum:(NSInteger)maxCount complete:(void(^)(NSArray<PHAssetModel *>*))complete{
    [ZWAlbumManager manager].isCrop = NO;
    [ZWAlbumManager manager].selectType = ZWAlbumSelectTypeMore;
    [ZWAlbumManager manager].allowPre = YES;
    [ZWAlbumManager manager].maxSelectCount = maxCount;
    [ZWAlbumManager manager].mediaType = ZWAlbumMediaTypePhoto;

    [[ZWAlbumManager manager] setSelectImageComplete:^(NSArray<PHAssetModel *> * _Nonnull obj, BOOL isOriginal) {
        BlockSafeRun(complete,obj);
    }];
      
    [[ZWAlbumManager manager] reqCameraRollList:^(PHAssetCollection * _Nonnull list) {
        ZWAlbumDetailsViewController * vc = [[ZWAlbumDetailsViewController alloc]init];
        vc.collection = list;
        ZWNavigationController * na = [[ZWNavigationController alloc] initWithRootViewController:vc];
        na.modalPresentationStyle = UIModalPresentationFullScreen;
        [[UIApplication displayViewController] presentViewController:na animated:YES completion:nil];
    }];
}

/* 选择文件 */
+ (void)goFielSelect:(NSInteger)maxCount
            complete:(void(^)(NSArray<PHAssetModel *>*))complete{
    [[FileSelectManager sharedFileSelectManager] openFileSelectVc];
    [[FileSelectManager sharedFileSelectManager] setSelectFileComplete:^(NSArray<PHAssetModel *> *obj) {
        BlockSafeRun(complete, obj);
    }];
}


@end
