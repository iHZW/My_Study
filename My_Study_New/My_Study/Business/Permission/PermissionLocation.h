//
//  PermissionLocation.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMObject.h"
#import "PermissionProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,LocationType){
    LocationTypeWhenInUse = 0,
    LocationTypeAlways
};

@interface PermissionLocation : NSObject<PermissionProtocol>

@property (nonatomic, assign) PermissionType permissionType;

- (instancetype)init:(LocationType)locationType;

+ (instancetype)locationForType:(LocationType)locationType;

@end

NS_ASSUME_NONNULL_END
