//
//  BaseTableViewCell.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/15.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWBaseView.h"
#import "ZWBaseViewModel.h"
#import "CMTableViewCell.h"

#define EmptyCellHeight 10.0f

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const emptyCellReuseIdentify;

@interface ZWPersonalBaseTableViewCell : CMTableViewCell

- (void)addViewModel:(ZWBaseViewModel *)viewModel;

- (void)addView:(ZWBaseView *)view;

@end

NS_ASSUME_NONNULL_END
