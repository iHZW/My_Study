//
//  PermissionProtocol.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#ifndef PermissionProtocol_h
#define PermissionProtocol_h

#import "PermissionTypes.h"

@protocol PermissionProtocol <NSObject>

- (BOOL)isAuthorized;

- (BOOL)isDenied;
//开始调用系统方法请求
- (void)request:(void (^)(void))block;

//权限类型
- (void)setPermissionType:(PermissionType)permissionType;

- (PermissionType)permissionType;

@end

typedef id<PermissionProtocol> PermissionObject;

@protocol PermissionIntercept <NSObject>
/**
 开始请求权限前操作
 */
- (void)request:(PermissionObject)permission notAuthorizedMessage:(NSString *)message complete:(void (^)(void))block;

@end




#endif /* PermissionProtocol_h */
