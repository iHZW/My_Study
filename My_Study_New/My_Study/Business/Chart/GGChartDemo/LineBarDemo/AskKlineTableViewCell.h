//
//  AskKlineTableViewCell.h
//  My_Study
//
//  Created by Zhiwei Han on 2023/9/7.
//  Copyright © 2023 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AskLineChartModel.h"

#define kLineViewHeight      (300)
#define kKLineTopSpace       (25)
#define kKLineBetweenSpace   (15)
#define kKBgViewBottomSpace  (10)

NS_ASSUME_NONNULL_BEGIN

@interface AskKlineTableViewCell : UITableViewCell

- (void)configModel:(AskLineChartModel *)model;

@end

NS_ASSUME_NONNULL_END
