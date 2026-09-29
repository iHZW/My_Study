//
//  AskLineChartModel.h
//  My_Study
//
//  Created by Zhiwei Han on 2023/9/7.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "KLineChart.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AskLineChartModel : NSObject

@property(nonatomic, strong) NSArray<id<KLineAbstract, VolumeAbstract, QueryViewAbstract>> *kLineArray;

@property(nonatomic, assign) KLineStyle kType;

@property (nonatomic, copy) NSString *desName;

+ (AskLineChartModel *)getDayDataModel;

+ (AskLineChartModel *)getWeekDataModel;

+ (AskLineChartModel *)getMonthDataModel;

@end

NS_ASSUME_NONNULL_END
