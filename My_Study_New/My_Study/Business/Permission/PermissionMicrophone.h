//
//  PermissionMicrophone.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMObject.h"
#import "PermissionProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PermissionMicrophone : CMObject<PermissionProtocol>

@property (nonatomic, assign) PermissionType permissionType;

@end

NS_ASSUME_NONNULL_END
