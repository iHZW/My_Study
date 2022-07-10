//
//  JXLocation.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWHttpNetworkData.h"
#import "MapHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface JXLocation : ZWHttpNetworkData

@property (nonatomic, assign) CLLocationDegrees longitude; //经度
@property (nonatomic, assign) CLLocationDegrees latitude;

@property (copy, nonatomic) NSString *country;//国家
@property (nonatomic, copy) NSString *provinceName;
@property (copy, nonatomic) NSString *province;//省编号
@property (nonatomic, copy) NSString *cityName;
@property (copy, nonatomic) NSString *city;//市编号
@property (nonatomic, copy) NSString *zoneName;
@property (copy, nonatomic) NSString *zone;//区级编号
@property (copy, nonatomic) NSString *street;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *streetNumber;
@property (copy, nonatomic) NSString *number;
@property (copy, nonatomic) NSString *POIName;
@property (copy, nonatomic) NSString *AOIName;

@end

NS_ASSUME_NONNULL_END
