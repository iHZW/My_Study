//
//  ProgressCustomView.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ProgressCustomView.h"
#import "UIImageView+Animations.h"
#import "UIColor+Ext.h"

@interface ProgressCustomView ()

@property (nonatomic, strong) ProgressImageView *progressImageView;

@end


@implementation ProgressCustomView

+ (ProgressCustomView *)progressCustomView{
    
    ProgressCustomView *customView = [[self alloc] init];
    
    [customView.progressImageView rotating];
    [customView setLogoView];

    return customView;
}

- (void)dealloc{
    //import
    [self.progressImageView.layer removeAllAnimations];
}

- (CGSize)intrinsicContentSize{
    return CGSizeMake(60 + 17 * 2, 60);
}

- (void)setLogoView{
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(17, 0, 60, 60)];
    logoImageView.contentMode = UIViewContentModeCenter;
    [logoImageView setImage:[UIImage imageNamed:@"progress_logo"]];
    [self addSubview:logoImageView];
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:11];
    label.textColor = [UIColor colorFromHexCode:@"#333333"];
    label.text = @"加载中";
    [self addSubview:label];

    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

- (ProgressImageView *)progressImageView{
    if (_progressImageView) {
        return _progressImageView;
    }
    _progressImageView = [[ProgressImageView alloc] initWithFrame:CGRectMake(17, 0, 60, 60)];
    [_progressImageView setImage:[UIImage imageNamed:@"progress_hud"]];
    
    [self addSubview:_progressImageView];
    
    return  _progressImageView;
}


@end




#pragma mark - ProgressImageView

@interface ProgressImageView ()

@end

@implementation ProgressImageView


@end
