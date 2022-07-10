//
//  PermissionLocationWhenInUseHandler.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMObject.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^PermissionLocationCompleteBlock)(BOOL);

@interface PermissionLocationWhenInUseHandler : CMObject

+(instancetype)shared;

- (void)requestPermission:(PermissionLocationCompleteBlock)completeBlock;

@end

NS_ASSUME_NONNULL_END
