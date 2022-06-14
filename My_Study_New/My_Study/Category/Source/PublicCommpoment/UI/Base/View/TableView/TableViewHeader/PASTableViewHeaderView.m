//
//  PASTableViewHeaderView.m
//  PASecuritiesApp
//
//  Created by Weirdln on 16/8/9.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "PASTableViewHeaderView.h"
#import "UIViewCategory.h"
#import "ZWSDK.h"

@interface PASTableViewHeaderView ()

@property (nonatomic, strong) UILabel *leftLabel; /** left 15 左对齐 */
@property (nonatomic, strong) UILabel *middleLabel; /** 布局低优先级居中，可以调整 */
@property (nonatomic, strong) UILabel *rightLabel; /** right 15 右对齐 */
@property (nonatomic, strong) UILabel *rightLabel2;  /**      */

@end

@implementation PASTableViewHeaderView

- (UILabel *)leftLabel
{
    if (!_leftLabel)
    {
        _leftLabel = [UILabel lableWithText:@"" textColor:nil font:PASFont(13) textAlignment:NSTextAlignmentLeft];
        [self addSubview:_leftLabel];
        _leftLabel.adjustsFontSizeToFitWidth = YES;
        
        [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(5);
//            make.width.mas_equalTo(kMainScreenWidth * 0.33);
            make.centerY.equalTo(self);
        }];
    }
    return _leftLabel;
}

- (UILabel *)rightLabel
{
    if (!_rightLabel)
    {
        _rightLabel = [UILabel lableWithText:@"" textColor:nil font:PASFont(13) textAlignment:NSTextAlignmentRight];
        [self addSubview:_rightLabel];
        _rightLabel.adjustsFontSizeToFitWidth = YES;
        
        [_rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-5);
//            make.width.mas_equalTo(kMainScreenWidth * 0.33);
            make.centerY.equalTo(self);
        }];
    }
    return _rightLabel;
}

- (UILabel *)middleLabel
{
    if (!_middleLabel)
    {
        _middleLabel = [UILabel lableWithText:@"" textColor:nil font:PASFont(13)];
        [self addSubview:_middleLabel];
        _middleLabel.adjustsFontSizeToFitWidth = YES;
        
        [_middleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.width.mas_equalTo(kMainScreenWidth * 0.33);
            if (self.middleOffset > 0)
                make.left.equalTo(self).offset(self.middleOffset);
            else
                make.centerX.equalTo(self).priority(MASLayoutPriorityDefaultLow); // 低优先级，保证可以调整
        }];
    }
    return _middleLabel;
}

- (UILabel *)rightLabel2
{
    if (!_rightLabel2) {
        _rightLabel2 = [UILabel lableWithText:@"" textColor:nil font:PASFont(13)];
        [self addSubview:_rightLabel2];
        _rightLabel2.adjustsFontSizeToFitWidth = YES;
        
        [_rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-5);
            make.left.equalTo(_rightLabel.mas_right);
            make.centerY.equalTo(self);
        }];
    }
    return _rightLabel2;
}

/**
 *  如果有四个label的时候，重新约束全部的label
 */
- (void)updateAllSubViews
{
    [_leftLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.width.mas_equalTo(kMainScreenWidth * 0.25);
    }];
    
    _middleLabel.textAlignment = NSTextAlignmentCenter;
    [_middleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        if (self.middleOffset > 0){
            make.left.equalTo(self).offset(self.middleOffset + kMainScreenWidth * 0.25 * 0.5);
        }else{
            make.centerX.equalTo(self).offset(- kMainScreenWidth * 0.25 * 0.5);
        }
        
    }];
    [_rightLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self).offset(- kMainScreenWidth * 0.25);
        make.left.equalTo(self.mas_left).offset(kMainScreenWidth * 0.5);
        make.width.mas_equalTo(kMainScreenWidth * 0.25);
    }];
    
    _rightLabel2.textAlignment = NSTextAlignmentRight;
    [_rightLabel2 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(_rightLabel.mas_right);
        make.right.equalTo(self).offset(-15);
    }];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
