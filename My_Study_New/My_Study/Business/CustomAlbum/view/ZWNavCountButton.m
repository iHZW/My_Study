//
//  ZWNavCountButton.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/12.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWNavCountButton.h"
#import "UIColor+Ext.h"

@interface ZWNavCountButton ()

@property (nonatomic ,strong) UIImageView * icon;

@property (nonatomic ,strong) UILabel * count;

@end

@implementation ZWNavCountButton

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initViews];
    }
    return self;
}

- (void)initViews{
    _icon = [[UIImageView alloc]initWithFrame:CGRectMake((self.frame.size.width - 20) / 2, (self.frame.size.height - 20) / 2, 20, 20)];
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    _icon.image = [UIImage imageNamed:@"Icon_camera_nav_unchoose"];
    _icon.clipsToBounds = YES;
    [self addSubview:_icon];
    
    _count = [[UILabel alloc]initWithFrame:CGRectMake((self.frame.size.width - 20) / 2, (self.frame.size.height - 20) / 2, 20, 20)];
    _count.backgroundColor = [UIColor colorFromHexCode:@"#4F7AFD"];
    _count.font = PASFont(14);
    _count.textAlignment = NSTextAlignmentCenter;
    _count.textColor = [UIColor colorFromHexCode:@"#FFFFFF"];
    _count.layer.cornerRadius = self.frame.size.height / 2;
    _count.clipsToBounds = YES;
    [self addSubview:_count];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _icon.frame = CGRectMake((self.frame.size.width - 20) / 2, (self.frame.size.height - 20) / 2, 20, 20);
    _count.frame = CGRectMake((self.frame.size.width - 20) / 2, (self.frame.size.height - 20) / 2, 20, 20);
}

- (void)updateTextCount:(NSInteger)selectCount{
    if (selectCount >= 1) {
        _icon.hidden = YES;
        _count.hidden = NO;
        _count.text = [NSString stringWithFormat:@"%ld",selectCount];
    }else{
        _icon.hidden = NO;
        _count.hidden = YES;
    }
    _icon.frame = CGRectMake((self.frame.size.width - 20) / 2, (self.frame.size.height - 20) / 2, 20, 20);
    _count.frame = CGRectMake((self.frame.size.width - 20) / 2, (self.frame.size.height - 20) / 2, 20, 20);
}

@end
