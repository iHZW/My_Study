//
//  MDLogTableViewCell.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/15.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDLogTableViewCell : ZWBaseTableViewCell

@property (nonatomic, copy) NSString *titleName;

@property (nonatomic, copy) NSString *subTitleName;

@property (nonatomic, copy) NSString *iconName;

@end

NS_ASSUME_NONNULL_END
