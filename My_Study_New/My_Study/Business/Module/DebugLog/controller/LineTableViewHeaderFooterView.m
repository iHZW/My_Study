//
//  LineTableViewHeaderFooterView.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/9/9.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "LineTableViewHeaderFooterView.h"
#import "TABAnimated.h"


@implementation LineTableViewHeaderFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        
        UIView *backView = UIView.new;
        backView.frame = self.bounds;
        backView.backgroundColor = UIColor.whiteColor;
        self.backView = backView;
        [self addSubview:backView];
        
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(kContentSideHorizSpace, 0, 3, 14);
        view.backgroundColor = UIColorFromRGB(0xE74E46);
        view.layer.cornerRadius = 1.5f;
        self.lineView = view;
        [self addSubview:view];
        
        UILabel *lab = [[UILabel alloc] init];
        lab.frame = CGRectMake(kContentSideHorizSpace*2, 10, 100, 50);
        lab.font = PASFont(18);
        lab.textColor = [UIColor blackColor];
        lab.text = @"头视图";
        self.titleLab = lab;
        [self addSubview:lab];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(kContentSideHorizSpace);
            make.centerY.equalTo(self.mas_centerY);
            make.height.mas_equalTo(15);
            make.width.mas_equalTo(3);
        }];
        
        [lab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view.mas_right).offset(kContentSideHorizSpace);
            make.size.mas_equalTo(CGSizeMake(100, 45));
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
    }
    return self;
}


@end
