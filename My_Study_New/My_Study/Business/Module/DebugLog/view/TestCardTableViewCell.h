//
//  TestCardTableViewCell.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/9/10.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestCardTableViewCell : UITableViewCell

+ (CGFloat)cellHeight;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic, strong) UIView *bgView;

@end

NS_ASSUME_NONNULL_END
