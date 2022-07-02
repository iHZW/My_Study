//
//  PASTipView.m
//  TZYJ_IPhone
//
//  Created by Howard on 15/11/26.
//
//

#import "ZWTipView.h"
#import <QuartzCore/QuartzCore.h>


@interface ZWTipView ()

@property (nonatomic, strong) UIView *tipIconBGView;
//@property (nonatomic, strong) UIImageView *tipIconView;
//@property (nonatomic, strong) UILabel *tipInfoView;
@property (nonatomic, strong) UIControl *coverControl;

@end


@implementation ZWTipView

- (instancetype)initWithFrame:(CGRect)frame tipImage:(UIImage *)tipImage tipInfo:(NSString *)tipInfo
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        CGSize sz       = CGSizeMake(MAX(tipImage.size.width, 1.0), MAX(tipImage.size.height, 1.0));
        _tipIconView    = [[UIImageView alloc] initWithImage:tipImage];
        _showIconBorder = NO;
        CGFloat h       = CGRectGetHeight(frame) * .5;
        _tipIconHeight  = h;
        _tipIconBGRect  = CGRectMake(0, 0, CGRectGetWidth(frame), h);
        _tipInfoViewHeight = CGRectGetHeight(frame) * .4;
        _tipIconBGRect  = CGRectMake(0, 0, sz.width, sz.height);
        _tipIconBGView  = [[UIView alloc] initWithFrame:_tipIconBGRect];
        [_tipIconBGView setBackgroundColor:[UIColor clearColor]];
        [_tipIconBGView.layer setBorderColor:UIColorFromRGB(0x666666).CGColor];
        [_tipIconBGView.layer setBorderWidth:1.0];
        [_tipIconBGView.layer setCornerRadius:4.0];
        [self addSubview:_tipIconBGView];
        [_tipIconBGView setHidden:!_showIconBorder];
        
        [_tipIconView setFrame:CGRectMake(0, 0,  h * sz.width / sz.height, h)];
        _tipInfoView = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame) * .6, CGRectGetWidth(frame), CGRectGetHeight(frame) * .4)];
        [_tipInfoView setBackgroundColor:[UIColor clearColor]];
        [_tipInfoView setText:tipInfo];
        [_tipInfoView setTextColor:UIColorFromRGB(0x999999)];
        [_tipInfoView setTextAlignment:NSTextAlignmentCenter];
        [_tipInfoView setFont:[UIFont systemFontOfSize:15]];
        
        [self addSubview:_tipIconView];
        [self addSubview:_tipInfoView];
        
        CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetHeight(frame) * .4);
        [_tipIconView setCenter:center];
        [_tipIconBGView setCenter:center];
        
        self.coverControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        [_coverControl addTarget:self action:@selector(coverAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_coverControl];
    }
    
    return self;
}

- (void)setTipInfo:(NSString *)tipInfo
{
    if (tipInfo) {
        [_tipInfoView setText:tipInfo];
    }
}

- (void)layoutSubviews
{
    [_tipIconBGView setHidden:!_showIconBorder];
    CGRect rt = self.bounds;
    CGFloat yCenter = CGRectGetHeight(_tipIconBGView.frame) * 0.5;
    [_tipIconView setBounds:CGRectMake(0, 0, _tipIconHeight, _tipIconHeight)];
    [_tipIconView setCenter:CGPointMake(CGRectGetMidX(rt), yCenter)];
    [_tipIconBGView setBounds:_tipIconBGRect];
    [_tipIconBGView setCenter:_tipIconView.center];
    [_tipInfoView setBounds:CGRectMake(0, 0, CGRectGetWidth(rt), _tipInfoViewHeight)];
    [_tipInfoView setCenter:CGPointMake(CGRectGetMidX(rt), CGRectGetHeight(rt) - _tipInfoViewHeight * 0.5)];
    [_coverControl setBounds:rt];
    [_coverControl setCenter:CGPointMake(rt.size.width * .5, rt.size.height * .5)];
}

- (void)showTipView
{
    self.alpha = 0;
    [UIView animateWithDuration:1.5 animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
}

- (void)hiddenTipView
{
    self.alpha = 1.0;
    [UIView animateWithDuration:1.5 animations:^{
        self.alpha = .0;
    } completion:^(BOOL finished) {
    }];
}

- (void)showTipViewWithNoAnimation
{
    self.alpha = 1.0;
}

- (void)hiddenTipViewWithNoAnimation
{
    self.alpha = .0;
}

- (void)coverAction:(id)sender
{
    if (self.tipViewBlock)
    {
        self.tipViewBlock();
    }
}

- (void)setTipInfoViewString:(NSString *)tipInfo
{
    self.tipInfoView.text = tipInfo;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
