//
//  TrimHeaderView.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/8.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "TrimHeaderView.h"

@interface TrimHeaderView ()

@property (nonatomic, strong) UIView *loadingView;

@property (nonatomic, strong) UILabel *loadingTipLabel;

@end

@implementation TrimHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorFromRGB(0x161A26);
        [self loadSubViews];
    }
    return self;
}


- (void)loadSubViews
{
    [self addSubview:self.loadingView];
}

- (UIView *)loadingView{
    if (!_loadingView){
        CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 172);
        _loadingView= [[UIView alloc] initWithFrame:frame];
        _loadingView.userInteractionEnabled = NO;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        NSMutableArray *images = [NSMutableArray array];
        for (NSInteger i = 1; i <= 50; i++){
            NSString *imageName = [NSString stringWithFormat:@"assistant_icon_loading_%03ld",(long)i];
            [images addObject:[UIImage imageNamed:imageName]];
        }
        imageView.image = images.firstObject;
        imageView.animationImages = images;
        [imageView startAnimating];
        [_loadingView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@100);
            make.width.equalTo(@300);
            make.centerX.equalTo(_loadingView);
            make.bottom.equalTo(_loadingView.mas_bottom);
        }];
        
        [_loadingView addSubview:self.loadingTipLabel];

        [self.loadingTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(_loadingView);
            make.bottom.equalTo(imageView.mas_top);
        }];
    }
    return _loadingView;
}

- (void)setLoadingTip:(NSString *)loadingTip
{
    _loadingTip = loadingTip;
    self.loadingTipLabel.text = TransToString(loadingTip);
}


- (UILabel *)loadingTipLabel
{
    if (!_loadingTipLabel) {
        _loadingTipLabel = [UILabel labelWithFrame:CGRectZero text:@"" textColor:UIColorFromRGB(0xFFFFFF) font:PASFont(14)];
    }
    return _loadingTipLabel;
}

@end
