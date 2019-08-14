//
//  PASBorderTableViewCell.m
//  PASecuritiesApp
//
//  Created by Weirdln on 15/9/27.
//
//

#import "PASBorderTableViewCell.h"

@implementation PASBorderTableViewCell

- (void)initInternal
{
    PASBorderBackgroundView *backgroundView = [[PASBorderBackgroundView alloc] init];
    backgroundView.backgroundColor = [UIColor clearColor];
    self.backgroundView = backgroundView;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initInternal];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initInternal];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.backgroundView setNeedsDisplay];
}

#pragma mark -- setter / getter

- (void)setBorderOption:(PASBorderOption)borderOption
{
    if ([self.backgroundView isKindOfClass:[PASBorderBackgroundView class]])
    {
        ((PASBorderBackgroundView *)self.backgroundView).borderOption = borderOption;
        [self.backgroundView setNeedsDisplay];
    }
}

- (PASBorderOption)borderOption
{
    return ((PASBorderBackgroundView *)self.backgroundView).borderOption;
}

- (void)setBorderInset:(UIEdgeInsets)borderInset
{
    if ([self.backgroundView isKindOfClass:[PASBorderBackgroundView class]])
    {
        ((PASBorderBackgroundView *)self.backgroundView).borderInset = borderInset;
        ((PASBorderBackgroundView *)self.backgroundView).vertiBorderInset = borderInset;
    }
}

- (UIEdgeInsets)borderInset
{
    return ((PASBorderBackgroundView *)self.backgroundView).borderInset;
}

- (void)setVertiBorderInset:(UIEdgeInsets)vertiBorderInset
{
    if ([self.backgroundView isKindOfClass:[PASBorderBackgroundView class]])
    {
        ((PASBorderBackgroundView *)self.backgroundView).vertiBorderInset = vertiBorderInset;
    }
}

- (UIEdgeInsets)vertiBorderInset
{
    return ((PASBorderBackgroundView *)self.backgroundView).vertiBorderInset;
}

- (void)setLineBolder:(CGFloat)lineBolder
{
    if ([self.backgroundView isKindOfClass:[PASBorderBackgroundView class]])
    {
        ((PASBorderBackgroundView *)self.backgroundView).lineBolder = lineBolder;
    }
}

- (CGFloat)lineBolder
{
    return ((PASBorderBackgroundView *)self.backgroundView).lineBolder;
}

@end
