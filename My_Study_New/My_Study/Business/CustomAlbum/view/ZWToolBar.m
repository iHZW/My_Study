//
//  ZWToolBar.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/12.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWToolBar.h"
#import "ZWButton.h"
#import "UIColor+Ext.h"

@interface ZWToolBar () <ZWButtonDelegate>

@property (nonatomic ,strong) UIView * originalView;

@property (nonatomic ,strong) UIButton * preButton;

@property (nonatomic ,strong) ZWButton * completeButton;

@property (nonatomic ,strong) NSString * comfirmText;

@property (nonatomic ,strong) UIImageView * icon;

@property (nonatomic ,strong) UILabel * originalLabel;

@end

@implementation ZWToolBar

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self initViews];
        self.comfirmText = @"完成";
    }
    return self;
}

- (void)initViews{
    _completeButton = [[ZWButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 16 - 50, 8.5, 84, 35)];
    _completeButton.delegate = self;
    [self addSubview:_completeButton];
    
    _originalView = [[UIView alloc]initWithFrame:CGRectMake(12, 13, 52, 24)];
    _originalView.userInteractionEnabled = YES;
    _icon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    if (self.isOriginal == NO) {
        _icon.image = [UIImage imageNamed:@"Icon-camera-normal"];
    }else{
        _icon.image = [UIImage imageNamed:@"Icon-camera-select"];
    }
    [_originalView addSubview:_icon];
    
    _originalLabel = [[UILabel alloc]initWithFrame:CGRectMake(24 + 4, 0, 30, 24)];
    _originalLabel.text = @"原图";
    _originalLabel.font = PASFont(15);
    _originalLabel.textColor = [UIColor colorFromHexCode:@"#333333"];
    [_originalView addSubview:_originalLabel];
    [self addSubview:_originalView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]init];
    [tap addTarget:self action:@selector(clickOrignial)];
    [_originalView addGestureRecognizer:tap];
    
    _preButton = [[UIButton alloc]initWithFrame:CGRectMake((self.frame.size.width - 40) / 2, 11.5, 40, 21)];
    [_preButton addTarget:self action:@selector(clickPreButton) forControlEvents:UIControlEventTouchUpInside];
    [_preButton setTitle:@"预览" forState:UIControlStateNormal];
    _preButton.titleLabel.font = PASFont(15);
    [_preButton setTitleColor:[UIColor colorFromHexCode:@"#333333"] forState:UIControlStateNormal];
    [self addSubview:_preButton];
}

- (void)setIsHightLight:(BOOL)isHightLight{
    _isHightLight = isHightLight;
    _completeButton.isHighLight = _isHightLight;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGSize labelSize = [_originalLabel sizeThatFits:CGSizeMake(MAXFLOAT, 24)];
    _originalLabel.frame = CGRectMake(24 + 4, 0, labelSize.width, 24);
    _icon.frame = CGRectMake(0, 0, 24, 24);
    _originalView.frame = CGRectMake(10, (self.frame.size.height - 24) / 2, 24 + 4 + labelSize.width, 24);
    _completeButton.frame = CGRectMake(self.frame.size.width - 16 - [_completeButton caculateWidth].width, (self.frame.size.height - 35) / 2, [_completeButton caculateWidth].width, 35);
    _preButton.frame = CGRectMake((self.frame.size.width - 40) / 2, (self.frame.size.height - 24) / 2, 40, 24);
}

- (void)updateCount:(NSInteger)count{
    if (count <= 0) {
        self.isHightLight = NO;
    }else{
        self.isHightLight = YES;
    }
    
    if (!self.isPre) {
        if (count <= 0) {
            self.preButton.hidden = YES;
        }else{
            self.preButton.hidden = NO;
        }
    }
    [_completeButton updateText:self.comfirmText count:count];
    [self layoutSubviews];
}

- (void)setIsOriginal:(BOOL)isOriginal{
    _isOriginal = isOriginal;
    if (isOriginal == YES) {
        _icon.image = [UIImage imageNamed:@"btn_radio_check_selected"];
    }else{
        _icon.image = [UIImage imageNamed:@"btn_radio_check_normal"];
    }
}

- (void)setIsPre:(BOOL)isPre{
    _isPre = isPre;
    if (isPre == NO) {
        _preButton.hidden = NO;
    }else{
        _preButton.hidden = YES;
    }
}

- (void)clickOrignial{
    if (self.isOriginal == YES) {
        self.isOriginal = NO;
    }else{
        self.isOriginal = YES;
    }
}

- (void)clickPreButton{
    if (_delegate && [_delegate respondsToSelector:@selector(toolBarDidClick:index:)]) {
        [_delegate toolBarDidClick:self index:0];
    }
}

#pragma delegate

- (void)zwButtonDidClick:(UIView *)button{
    if (_delegate && [_delegate respondsToSelector:@selector(toolBarDidClick:index:)] && self.isHightLight == YES) {
        [_delegate toolBarDidClick:self index:1];
    }
}

@end
