//
//  ZWCropButtonView.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWButton.h"
#import "UIColor+Ext.h"

@interface ZWButton ()

@property (nonatomic ,strong) UIButton * button;

@end


@implementation ZWButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initViews];
    }
    return self;
}

- (void)initViews
{
    _button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _button.layer.cornerRadius = 5;
    _button.clipsToBounds = YES;
    _button.titleLabel.font = PASFont(16);
    [_button setTitleColor:[UIColor colorFromHexCode:@"#FFFFFF"] forState:UIControlStateNormal];
    [_button setBackgroundColor:[UIColor colorFromHexCode:@"#4F7AFD"]];
    [_button addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_button];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _button.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)setIsHighLight:(BOOL)isHighLight{
    _isHighLight = isHighLight;
    if (!isHighLight) {
        _button.alpha = 0.4;
    }else{
        _button.alpha = 1;
    }
}

- (void)updateText:(NSString *)text count:(NSInteger)count{
    if (count > 0) {
        [_button setTitle:[NSString stringWithFormat:@"%@(%ld)",text,count] forState:UIControlStateNormal];
    }else{
        [_button setTitle:text forState:UIControlStateNormal];
    }
}

- (CGSize)caculateWidth{
    CGSize size = [_button sizeThatFits:CGSizeMake(MAXFLOAT, self.frame.size.height)];
    return CGSizeMake(size.width + 32, size.height);
}

- (void)clickAction{
    if (_delegate && [_delegate respondsToSelector:@selector(zwButtonDidClick:)]) {
        [_delegate zwButtonDidClick:self.button];
    }
}


@end
