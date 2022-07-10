//
//  PermissionTypes.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#ifndef PermissionTypes_h
#define PermissionTypes_h

typedef NS_ENUM(NSUInteger,PermissionType) {
    PermissionTypeLocationWhenInUse = 0, //位置
    PermissionTypeLocationAlways, //位置
    PermissionTypePhotoLibrary, //相册权限
    PermissionTypeCamera,   //拍照权限
    PermissionTypeMicrophone, //麦克风
    PermissionTypeContact //通讯录
};

typedef NS_ENUM(NSInteger, PermissionAuthorizationStatus) {
    PermissionAuthorizationStatusNotDetermined = 0,
    PermissionAuthorizationStatusDenied        = 1,
    PermissionAuthorizationStatusAuthorized    = 2,
};

#endif /* PermissionTypes_h */
