//
//  Permission.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMObject.h"
#import "PermissionTypes.h"
#import "PermissionProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface Permission : CMObject

//权限拦截器
+ (id<PermissionIntercept>)permissionIntercept;

+ (void)setIntercept:(id<PermissionIntercept>)intercept;

//生成对应权限类
+ (PermissionObject)objectForType:(PermissionType)type;

//请求权限;notAuthorizedMessage 没权限的时候弹框中提示的message
+ (void)requestForType:(PermissionType)type notAuthorizedMessage:(NSString *)message complete:(void (^)(PermissionAuthorizationStatus))block;

+ (void)request:(PermissionObject)permission notAuthorizedMessage:(NSString *)message complete:(void (^)(PermissionAuthorizationStatus))block;

@end

NS_ASSUME_NONNULL_END
