//
//  PASTextField.m
//  PASecuritiesApp
//
//  Created by Weirdln on 16/5/8.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "PASTextField.h"
#import "Masonry.h"
#import "UIViewCategory.h"

@interface PASTextField  ()

@property (nonatomic, strong) UILabel *rightTipLabel;

@end

@implementation PASTextField

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_rightTipLabel)
    {
        _rightTipLabel.frame = CGRectMake(self.leftOffset, 0, self.width - self.leftOffset - self.rightOffset, self.height);
    }
}

- (UILabel *)rightTipLabel
{
    if (!_rightTipLabel)
    {
        _rightTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _rightTipLabel.backgroundColor = [UIColor clearColor];
        _rightTipLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_rightTipLabel];
    }
    return _rightTipLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

// 控制text的位置
- (CGRect)textRectForBounds:(CGRect)bounds
{
    return [self newFrame:bounds];
}

// 控制placeHolder的位置
- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return [self newFrame:bounds];
}

// 控制editingRect
- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self newFrame:bounds];
}

//- (CGRect)clearButtonRectForBounds:(CGRect)bounds
//{
//    return [self newFrame:bounds];
//}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect leftViewRect = self.leftView.frame;
    
    return CGRectMake(bounds.origin.x + self.leftOffset, leftViewRect.origin.y, leftViewRect.size.width, leftViewRect.size.height);
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    CGRect rightViewRect = self.rightView.frame;
    return CGRectMake(bounds.size.width - rightViewRect.size.width - self.rightOffset, (bounds.size.height-rightViewRect.size.height)/2, rightViewRect.size.width, rightViewRect.size.height);
}

- (CGRect)newFrame:(CGRect)bounds
{
    CGRect leftViewRect = self.leftView.frame;
    CGRect rightViewRect = self.rightView.frame;
    return CGRectMake(bounds.origin.x + leftViewRect.size.width + self.leftOffset, bounds.origin.y, bounds.size.width - leftViewRect.size.width - rightViewRect.size.width - self.leftOffset - self.rightOffset, bounds.size.height);
}
@end
