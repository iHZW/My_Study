//
//  AskLineChartModel.h
//  My_Study
//
//  Created by Zhiwei Han on 2023/9/7.
//  Copyright © 2023 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KLineChart.h"

NS_ASSUME_NONNULL_BEGIN

@interface AskLineChartModel : NSObject

@property (nonatomic, strong)NSArray<id<KLineAbstract,VolumeAbstract,QueryViewAbstract>> *kLineArray;

@property (nonatomic, assign) KLineStyle kType;

@end

NS_ASSUME_NONNULL_END
