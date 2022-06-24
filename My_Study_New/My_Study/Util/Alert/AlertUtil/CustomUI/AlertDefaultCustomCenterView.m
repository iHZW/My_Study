//
//  AlertDefaultCustomCenterView.m
//  CRM
//
//  Created by Zhiwei Han on 2022/6/17.
//  Copyright © 2022 CRM. All rights reserved.
//

#import "AlertDefaultCustomCenterView.h"
#import "UIColor+Ext.h"

@interface AlertDefaultCustomCenterView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *msgLabe;

@end


@implementation AlertDefaultCustomCenterView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self loadSuViews];
    }
    return self;
}


- (void)loadSuViews
{
    [self addSubview:self.titleLabel];
    [self addSubview:self.msgLabe];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(kAlertTitleLabelLeftSpace);
        make.right.equalTo(self.mas_right).offset(-kAlertTitleLabelLeftSpace);
        make.top.equalTo(self.mas_top).offset(16);
    }];
    
    [self.msgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(8);
        make.left.right.equalTo(self.titleLabel);
    }];
    
}


- (void)setTitleName:(NSString *)titleName
{
    _titleName = titleName;
    self.titleLabel.text = __String_Not_Nil(titleName);
}

- (void)setMsg:(NSString *)msg
{
    _msg = msg;
    self.msgLabe.text = __String_Not_Nil(msg);
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    self.titleLabel.textColor = titleColor;
}

- (void)setMsgColor:(UIColor *)msgColor
{
    _msgColor = msgColor;
    self.msgLabe.textColor = msgColor;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    self.titleLabel.font = titleFont;
}

- (void)setMsgFont:(UIFont *)msgFont
{
    _msgFont = msgFont;
    self.msgLabe.font = msgFont;
}


#pragma mark - lazyLoad

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [UIColor colorFromHexCode:@"#333333"];
        _titleLabel.font = PASFont(14);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UILabel *)msgLabe
{
    if (!_msgLabe) {
        _msgLabe = [[UILabel alloc] initWithFrame:CGRectZero];
        _msgLabe.textColor = [UIColor colorFromHexCode:@"#999999"];
        _msgLabe.font = PASFont(14);
        _msgLabe.numberOfLines = 0;
        _msgLabe.textAlignment = NSTextAlignmentLeft;
    }
    return _msgLabe;
}


@end
