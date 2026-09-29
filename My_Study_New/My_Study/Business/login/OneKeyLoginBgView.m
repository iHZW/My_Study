//
//  OneKeyLoginBgView.m
//  My_Study
//
//  Created by Zhiwei Han on 2023/1/17.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "OneKeyLoginBgView.h"
#import <Masonry/Masonry.h>

@interface OneKeyLoginBgView ()

@property (nonatomic, strong) UIImageView *logoImageView;

@end

@implementation OneKeyLoginBgView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self loadSubViews];
    }
    return self;
}

- (void)loadSubViews {
    self.backgroundColor = UIColor.cyanColor;
    
    [self addSubview:self.logoImageView];
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.top.equalTo(self.mas_top).offset(100);
    }];
    
    
}




#pragma mark -  Lazy loading
- (UIImageView *)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _logoImageView.image = [UIImage imageNamed:@"icon_ball_001"];
    }
    return _logoImageView;
}





@end
