//
//  TrimAddressCell.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/6.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "TrimAddressCell.h"
#import "UIColor+Ext.h"

@interface TrimAddressCell()

@property (nonatomic, strong) UIImageView *leftIconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIImageView *rightIconImageView;
@property (nonatomic, strong) UIView *lineView;

@end


@implementation TrimAddressCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setUI];
    }
    return self;
}

- (void)setUI {
    [self.contentView addSubview:self.leftIconImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.subTitleLabel];
    [self.contentView addSubview:self.rightIconImageView];
    [self.contentView addSubview:self.lineView];
    
    CGFloat padding = 16;
    
    [self.leftIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(padding);
        make.top.equalTo(self.contentView.mas_top).offset(19);
        make.width.equalTo(@ 14);
        make.height.equalTo(@ 14);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftIconImageView.mas_right).offset(5);
        make.right.equalTo(self.contentView.mas_right).offset(-40);
        make.top.equalTo(self.contentView.mas_top).offset(16);
    }];
    
    [self.rightIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-22);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.equalTo(@ 18);
        make.height.equalTo(@ 18);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(16);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(4);
        make.right.equalTo(self.contentView.mas_right).offset(-45);
      }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.equalTo(self.contentView.mas_left).offset(padding);
           make.right.equalTo(self.contentView.mas_right).offset(-padding);
           make.top.equalTo(self.subTitleLabel.mas_bottom).offset(padding);
           make.bottom.equalTo(self.contentView.mas_bottom);
           make.height.equalTo(@ 0.5);
    }];
}


//- (void)updateTrimWithModel:(POIAnnotation *)model isLastRow:(NSInteger)isLastRow
//{
//    self.leftLabel.adjustsFontSizeToFitWidth = YES;
//    self.rightLabel.adjustsFontSizeToFitWidth = YES;
//    self.leftLabel.text = TransToString(model.title);
//    self.rightLabel.text = TransToString(model.subtitle);
//}

- (void)updateTrimWithModel:(POIAnnotation *)model isLastRow:(NSInteger)isLastRow {
    
    _titleLabel.text = model.title;
    _subTitleLabel.text = model.subtitle;
    _leftIconImageView.image = [UIImage imageNamed:@"icon_map_location"];
    
    NSString *rightImageName = self.isSelected ? @"icon_selected": @"";
    
    _rightIconImageView.image = [UIImage imageNamed:rightImageName];
    
    if (isLastRow) {
        self.lineView.hidden = YES;
    }else {
        self.lineView.hidden = NO;
    }
}

- (UIImageView *)leftIconImageView {
    if (!_leftIconImageView) {
        _leftIconImageView = [[UIImageView alloc] init];
    }
    return _leftIconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = PASFont(13);
        _titleLabel.textColor = [UIColor colorFromHexCode:@"#333333"];
        _titleLabel.numberOfLines = 1;
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.font = PASFont(13);
        _subTitleLabel.textColor = [UIColor colorFromHexCode:@"#333333"];
        _subTitleLabel.numberOfLines = 1;
    }
    return _subTitleLabel;
}

- (UIImageView *)rightIconImageView {
    if (!_rightIconImageView) {
        _rightIconImageView = [[UIImageView alloc] init];
    }
    return _rightIconImageView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorFromHexCode:@"#F2F2F6"];
    }
    return _lineView;
}


@end
