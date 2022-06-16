//
//  MDLogTableViewCell.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/15.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "MDLogTableViewCell.h"


@interface MDLogTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic, strong) UIButton *iconBtn;

@end

@implementation MDLogTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self loadSubViews];
    }
    return self;
}

- (void)loadSubViews
{
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.subTitleLabel];
    [self.contentView addSubview:self.iconBtn];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.left.equalTo(self.contentView.mas_left).offset(kCommonLeftSpace);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_left);
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.bottom.equalTo(self.contentView.mas_bottom);
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
        _titleLabel = [UILabel labelWithFrame:CGRectZero text:@"" textColor:UIColorFromRGB(0x111111) font:PASFont(16)];
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel
{
    if (!_subTitleLabel) {
        _subTitleLabel = [UILabel labelWithFrame:CGRectZero text:@"" textColor:UIColorFromRGB(0x666666) font:PASFont(12)];
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

@end
