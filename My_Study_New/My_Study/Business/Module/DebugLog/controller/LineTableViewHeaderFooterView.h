//
//  LineTableViewHeaderFooterView.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/9/9.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LineTableViewHeaderFooterView : UITableViewHeaderFooterView

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIView *lineView;

@end

NS_ASSUME_NONNULL_END
