//
//  ZWColorPickInfoView.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/13.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWColorPickInfoView.h"
#import "UIColor+Ext.h"
#import "NSString+Verify.h"

@interface ZWColorPickInfoView ()<UITextFieldDelegate>

@property (nonatomic, strong) UIView *colorBgView;

@property (nonatomic, strong) UIView *colorView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UITextField *textField;

@end

@implementation ZWColorPickInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self loadSubViews];
    }
    return self;
}


- (void)loadSubViews
{
    [self addSubview:self.colorBgView];
    [self.colorBgView addSubview:self.colorView];
    [self.colorBgView addSubview:self.titleLabel];
    [self.colorBgView addSubview:self.textField];
    [self.colorBgView addSubview:self.closeBtn];
    
    [self.colorBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 10, 0, 10));
    }];
    
    [self.colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.colorBgView.mas_left).offset(10);
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerY.equalTo(self.colorBgView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.colorBgView);
        make.width.mas_equalTo(100);
        make.left.equalTo(self.colorView.mas_right).offset(10);
    }];
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(self.colorBgView);
        make.width.equalTo(@(50));
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.colorBgView);
        make.left.equalTo(self.titleLabel.mas_right).offset(10);
        make.right.equalTo(self.closeBtn.mas_left).offset(-10);
    }];
}

- (void)setCurrentColor:(NSString *)hexColor
{
    self.colorView.backgroundColor = [UIColor colorFromHexCode:hexColor];
    self.titleLabel.text = [NSString stringWithFormat:@"#%@", hexColor];
    self.titleLabel.textColor = [UIColor colorFromHexCode:hexColor];
}


- (void)dealWithCloseAction
{
    if ([self.delegate respondsToSelector:@selector(closeBtnAction:view:)]) {
        [self.delegate closeBtnAction:self.closeBtn view:self];
    }
}


#pragma mark - lazyLoad
- (void)textFieldChange:(UITextField *)textField
{
    NSInteger length = textField.text.length;
    if (length == 3
        || length == 4
        || length == 6
        || length == 8)
    {
        [self setCurrentColor:textField.text];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *rawText = [result stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([rawText containsString:@"#"]) {
        rawText = [result stringByReplacingOccurrencesOfString:@"#" withString:@""];
    }
    BOOL isCan = YES;
    /** 判断输入的是十六进制颜色值  */
    BOOL isAble = [DataFormatterFunc isColorNum:rawText];

    if (rawText.length > 8 || !isAble) {
        isCan = NO;
    }
    return isCan;
}


#pragma mark - lazyLoad
- (UIView *)colorBgView
{
    if (!_colorBgView) {
        _colorBgView = [UIView viewForColor:UIColorFromRGB(0xFFFFFF) withFrame:CGRectZero];
        [_colorBgView setCornerRadius:8 borderWidth:.5 borderColor:UIColorFromRGB(0xCCCCCC)];
    }
    return _colorBgView;
}

- (UIView *)colorView
{
    if (!_colorView) {
        _colorView = [UIView viewForColor:UIColorFromRGB(0xFFFFFF) withFrame:CGRectZero];
        [_colorView setCornerRadius:2 borderWidth:.5 borderColor:UIColorFromRGB(0xEDEDED)];
    }
    return _colorView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel labelWithFrame:CGRectZero text:@"" textColor:UIColorFromRGB(0x999999)];
    }
    return _titleLabel;
}

- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        @pas_weakify_self
        _closeBtn = [UIButton buttonWithFrame:CGRectZero title:@"" font:PASFont(16) titleColor:UIColorFromRGB(0x111111) block:^{
            @pas_strongify_self
            [self dealWithCloseAction];
        }];
        [_closeBtn setImage:[UIImage imageNamed:@"Icon_close"] forState:UIControlStateNormal];
    }
    return _closeBtn;
}


- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectZero];
        _textField.placeholder = @"请输入色值";
        _textField.delegate = self;
        _textField.leftView = [UILabel labelWithFrame:CGRectMake(0, 0, 10, CGRectGetHeight(self.bounds)) text:@"#" textColor:UIColorFromRGB(0x111111)];
        [_textField addTarget:self action:@selector(textFieldChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textField;
}


@end
