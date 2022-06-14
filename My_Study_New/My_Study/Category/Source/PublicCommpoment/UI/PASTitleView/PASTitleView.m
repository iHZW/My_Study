//
//  PASTitleView.m
//  PASecuritiesApp
//
//  Created by zhoujiexin on 17/2/23.
//  Copyright © 2017年 PAS. All rights reserved.
//

#import "PASTitleView.h"

@interface PASTitleView ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *codeLabel;

@end

@implementation PASTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _nameLabel = [UILabel lableWithText:nil textColor:UIColorFromRGB(0xffffff) font:PASFont(18) textAlignment:NSTextAlignmentCenter];
        [self addSubview:_nameLabel];
        
        _codeLabel = [UILabel lableWithText:nil textColor:UIColorFromRGB(0xffffff) font:PASFont(14) textAlignment:NSTextAlignmentCenter];
        [self addSubview:_codeLabel];
        
        [self resizeWithFrame:frame];
    }
    
    return self;
}

- (void)resizeWithFrame:(CGRect)frame
{
    CGFloat height = frame.size.height / 2;
    CGFloat width = frame.size.width;
    
    _nameLabel.frame = CGRectMake(0, 0, width, height);
    _codeLabel.frame = CGRectMake(0, height, width, height);
    
}

- (void)setTitleText:(NSString *)title code:(NSString *)code
{
    _nameLabel.text = title;
    _codeLabel.text = code;
}

@end
