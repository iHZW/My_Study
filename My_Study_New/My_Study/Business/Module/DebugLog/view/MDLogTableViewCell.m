//
//  MDLogTableViewCell.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/15.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "MDLogTableViewCell.h"

#define kTitleBetweenSpace       5


@interface MDLogTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic, strong) UIButton *iconBtn;
/* 包裹视图居中处理 */
@property (nonatomic, strong) UIView *containerView;

@end

@implementation MDLogTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self loadSubViews];
        self.subTitleName = @"";
    }
    return self;
}

- (void)loadSubViews
{
    [self.contentView addSubview:self.containerView];
    [self.contentView addSubview:self.iconBtn];
    [self.containerView addSubview:self.titleLabel];
    [self.containerView addSubview:self.subTitleLabel];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView.mas_right).offset(-kCommonLeftSpace-40);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self.containerView);
        make.left.equalTo(self.containerView.mas_left).offset(kCommonLeftSpace);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(kTitleBetweenSpace);
        make.bottom.equalTo(self.containerView.mas_bottom);
    }];
    
    [self.iconBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView.mas_right).offset(-kCommonLeftSpace);
//        make.width.mas_equalTo(80);
    }];
}

- (void)setTitleName:(NSString *)titleName
{
    _titleName = titleName;
    self.titleLabel.text = TransToString(titleName);
}

- (void)setSubTitleName:(NSString *)subTitleName
{
    _subTitleName = subTitleName;
    self.subTitleLabel.text = TransToString(subTitleName);
    
    if (ValidString(subTitleName)) {
        [self.subTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(kTitleBetweenSpace);
        }];
    } else {
        [self.subTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom);
        }];
    }
}


- (void)setIconName:(NSString *)iconName
{
    _iconName = iconName;
    [self.iconBtn setImage:[UIImage imageNamed:TransToString(iconName)] forState:UIControlStateNormal];
}


#pragma mark - lazyLoad
- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel labelWithFrame:CGRectZero text:@"" textColor:UIColorFromRGB(0x111111) font:PASFont(16) textAlignment:NSTextAlignmentLeft];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel
{
    if (!_subTitleLabel) {
        _subTitleLabel = [UILabel labelWithFrame:CGRectZero text:@"" textColor:UIColorFromRGB(0x666666) font:PASFont(12) textAlignment:NSTextAlignmentLeft];
    }
    return _subTitleLabel;
}

- (UIButton *)iconBtn
{
    if (!_iconBtn) {
        _iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_iconBtn setImage:[UIImage imageNamed:@"icon_arrow_right"] forState:UIControlStateNormal];
    }
    return _iconBtn;
}

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [UIView viewForColor:[UIColor clearColor] withFrame:CGRectZero];
    }
    return _containerView;
}

@end
