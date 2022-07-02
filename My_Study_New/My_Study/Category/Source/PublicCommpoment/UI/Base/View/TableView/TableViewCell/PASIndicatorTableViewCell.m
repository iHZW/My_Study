//
//  PASIndicatorTableViewCell.m
//  PASecuritiesApp
//
//  Created by Weirdln on 16/7/6.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "PASIndicatorTableViewCell.h"
#import "UIViewCategory.h"
#import "ZWSDK.h"

@interface PASIndicatorTableViewCell ()

@property (nonatomic, strong) UIImageView *leftIconImageView;
@property (nonatomic, strong) UIImageView *rightIconImageView;

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *middleLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) UILabel *bottomLabel;

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UILabel *statusLabel;

@end

@implementation PASIndicatorTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        /** 默认显示右侧箭头  */
        self.isShowRightArrow = YES;
    }
    return self;
}

- (void)setIsShowRightArrow:(BOOL)isShowRightArrow
{
    _isShowRightArrow = isShowRightArrow;
    self.rightIconImageView.hidden = !self.isShowRightArrow;
}

#pragma mark -- setter / getter

- (UIImageView *)leftIconImageView
{
    if (!_leftIconImageView)
    {
        _leftIconImageView = [UIImageView imageViewForImage:nil withFrame:CGRectZero];
        [self.contentView addSubview:_leftIconImageView];
        
        [_leftIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.centerY.equalTo(self.contentView);
        }];
    }
    return _leftIconImageView;
}

- (UIImageView *)rightIconImageView
{
    if (!_rightIconImageView)
    {
        _rightIconImageView = [UIImageView imageViewForImage:[UIImage imageNamed:@"icon_arrow_right"] withFrame:CGRectZero];
        [self.contentView addSubview:_rightIconImageView];
        
        [_rightIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-15);
            make.size.mas_equalTo(CGSizeMake(25, 25));
            make.centerY.equalTo(self.contentView);
        }];
    }
    return _rightIconImageView;
}

- (UILabel *)leftLabel
{
    if (!_leftLabel)
    {
        _leftLabel = [UILabel lableWithText:@"" textColor:nil font:PASFont(14)];
        _leftLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_leftLabel];
        
        [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            if (_leftIconImageView)
                make.left.equalTo(_leftIconImageView.mas_right).offset(10);
            else
                make.left.mas_equalTo(15);
            make.centerY.equalTo(self.contentView);
        }];
    }
    return _leftLabel;
}

- (UILabel *)rightLabel
{
    if (!_rightLabel)
    {
        _rightLabel = [UILabel lableWithText:@"" textColor:nil font:PASFont(14)];
        _rightLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_rightLabel];
        
        [_rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            if (_rightIconImageView)
                make.right.equalTo(_rightIconImageView.mas_left).offset(-10);
            else
            {
                if (self.accessoryType == UITableViewCellAccessoryNone)
                    make.right.equalTo(self.contentView).offset(-15);
                else
                    make.right.equalTo(self.contentView).offset(0); // UITableViewCellAccessoryDisclosureIndicator本身有15
            }
            make.centerY.equalTo(self.contentView);
        }];
    }
    return _rightLabel;
}

- (UILabel *)middleLabel
{
    if (!_middleLabel)
    {
        _middleLabel = [UILabel lableWithText:@"" textColor:nil font:PASFont(14)];
        _middleLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_middleLabel];
        
        [_middleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.leftLabel);
            if (self.middleOffset > 0)
                make.left.equalTo(self.contentView).offset(self.middleOffset);
            else
                make.centerX.equalTo(self.contentView).priority(MASLayoutPriorityDefaultLow); // 低优先级，保证可以调整
        }];
    }
    return _middleLabel;
}

- (UILabel *)bottomLabel
{
    if (!_bottomLabel) {
        _bottomLabel = [UILabel lableWithText:@"" textColor:UIColorFromRGB(0xe2233e) font:PASFont(11)];
        _bottomLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_bottomLabel];
        
        [_bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self.middleLabel.mas_bottom).offset(6);
            make.right.equalTo(self).offset(-15);
            
            if (self.middleOffset > 0)
                make.left.equalTo(self.contentView).offset(self.middleOffset);
            else
            {
                make.centerX.equalTo(self.middleLabel);
                _bottomLabel.textAlignment = NSTextAlignmentCenter;
            }
        }];
    }
    return _bottomLabel;
}

- (UILabel *)statusLabel
{
    if (!_statusLabel) {
        _statusLabel = [UILabel lableWithText:@"" textColor:nil font:PASFont(11)];
        _statusLabel.adjustsFontSizeToFitWidth = YES;
        _statusLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_statusLabel];
        
        [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView).offset(15);
            if (self.middleOffset > 0)
                make.left.equalTo(self.contentView).offset(self.middleOffset);
            else
                make.centerX.equalTo(self.contentView).priority(MASLayoutPriorityDefaultLow); // 低优先级，保证可以调整
        }];
    }
    return _statusLabel;
}

- (UIButton *)button
{
    if (!_button)
    {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:_button];
        
        [_button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView).priority(MASLayoutPriorityDefaultLow);
            make.right.equalTo(self.contentView).offset(-15);
            make.width.mas_equalTo(60).priority(MASLayoutPriorityDefaultLow);
        }];
    }
    return _button;
}

- (UITextField *)textField
{
    if (!_textField)
    {
        self.accessoryType = UITableViewCellAccessoryNone; // 有输入框就默认不需要箭头指示
        _textField = [UITextField textFieldWithFrame:CGRectZero placeholder:@"请输入" font:PASFont(16) textColor:[UIColor grayColor] bgImage:nil];
        [self.contentView addSubview:_textField];
        [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.equalTo(self.contentView).insets(UIEdgeInsetsMake(0, 0, 0, 15)).priority(MASLayoutPriorityDefaultLow);
            make.centerY.equalTo(self.contentView);
            if (self.middleOffset > 0)
                make.left.equalTo(self.contentView).offset(self.middleOffset);
            else
            {
                // 如果存在leftlabel，则设置与leftlabel的间距，否则设置与contentView布局
                if (_leftLabel)
                    make.left.equalTo(_leftLabel.mas_right).offset(10);
                else
                    make.left.equalTo(self.contentView).offset(15);
            }

        }];
    }
    return _textField;
}


@end
