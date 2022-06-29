//
//  BaseTableViewCell.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/15.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWBaseTableViewCell.h"

NSString *const emptyCellReuseIdentify = @"emptyCellReuseIdentify";

@implementation ZWBaseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = UIColorFromRGB(0xF2F2F2);
//        self.contentView.backgroundColor = PASFaceColorWithKey2(@"u6", UIColorFromRGB(0xF2F2F2), bolThemeChgUsercenterPage);
    }
    return self;
}

- (void)addViewModel:(ZWBaseViewModel *)viewModel
{
    [self removeAllSubViews];
    if (!viewModel) {
        return;
    }
    [viewModel refreshView];
    [viewModel.view removeFromSuperview];
    [self.contentView addSubview:viewModel.view];
}

- (void)addView:(ZWBaseView *)view
{
    [self removeAllSubViews];
    if (!view) {
        return;
    }
    [view removeFromSuperview];
    [self.contentView addSubview:view];
}

- (void)removeAllSubViews
{
    NSArray *subVs = [self.contentView subviews];
    [subVs enumerateObjectsUsingBlock:^(UIView *  _Nonnull v, NSUInteger idx, BOOL * _Nonnull stop) {
        [v removeFromSuperview];
    }];
}

- (void)notifyThemeChange:(NSNotification *)notification
{
    self.contentView.backgroundColor = UIColorFromRGB(0xF2F2F2);
//    self.contentView.backgroundColor = PASFaceColorWithKey2(@"u6", UIColorFromRGB(0xF2F2F2), bolThemeChgUsercenterPage);
}

@end
