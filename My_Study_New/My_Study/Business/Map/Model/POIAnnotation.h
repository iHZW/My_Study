//
//  POIAnnotation.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/6.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMObject.h"
#import "MapHeader.h"
#import "AMapSearchKit/AMapCommonObj.h"


NS_ASSUME_NONNULL_BEGIN

@interface POIAnnotation : CMObject <MAAnnotation>

- (id)initWithPOI:(AMapPOI *)poi;

@property (nonatomic, readonly, strong) AMapPOI *poi;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, assign) NSInteger tag;

/*!
 @brief 获取annotation标题
 @return 返回annotation的标题信息
 */
- (NSString *)title;

/*!
 @brief 获取annotation副标题
 @return 返回annotation的副标题信息
 */
- (NSString *)subtitle;

/*!
@brief 获取annotation城市
@return 返回annotation的城市信息
*/
- (NSString *)city;

@end

NS_ASSUME_NONNULL_END
