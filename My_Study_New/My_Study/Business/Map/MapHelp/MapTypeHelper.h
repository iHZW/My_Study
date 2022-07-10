//
//  MapTypeHelper.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/6.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface MapTypeHelper : CMObject

@property (nonatomic, strong) NSMutableArray *maps; //可选地图
@property (nonatomic, assign) double latitude; //纬度
@property (nonatomic, assign) double longitude; //经度
@property (nonatomic, copy) NSString *address;//地址名称

- (instancetype)initMapTypeHelper:(double)latitude longitude:(double)longitude address:(NSString *)address;

- (NSMutableArray *)getInstalledMapAppWithEndLocation;

- (void)showActionView;

@end

NS_ASSUME_NONNULL_END
