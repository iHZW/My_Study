//
//  LocationTrimViewController.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/6.
//  Copyright © 2022 HZW. All rights reserved.
//
/** 获取当前位置周边地图信息  */
#import "ZWBaseViewController.h"
#import "MapHeader.h"

NS_ASSUME_NONNULL_BEGIN
@class POIAnnotation;

typedef void(^TapPOIAnnotationItemBlock) (POIAnnotation *);


@interface LocationTrimViewController : ZWBaseViewController

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) TapPOIAnnotationItemBlock tapAnnoItemHandler;

@property (nonatomic, assign) NSInteger type; // 0  默认  1 显示不显示位置

@end

NS_ASSUME_NONNULL_END
