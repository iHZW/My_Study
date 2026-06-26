//
//  ZWCustomeView.m
//  My_Study
//
//  Created by hzw on 2025/1/23.
//  Copyright © 2025 HZW. All rights reserved.
//

#import "CustomSwipingView.h"
#import "ZWCustomData.h"
#import "ZWCustomeView.h"

@interface ZWCustomeView () <SwiperViewUpdatable>

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *subtitleLabel;
@property(nonatomic, strong) UIImageView *imageView;

@end

@implementation ZWCustomeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, frame.size.width - 20, 30)];
        self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, frame.size.width - 20, 20)];
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 80, frame.size.width - 20, frame.size.height - 90)];

        [self addSubview:self.titleLabel];
        [self addSubview:self.subtitleLabel];
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)updateWithData:(id)data {
    if ([data isKindOfClass:[ZWCustomData class]]) {
        ZWCustomData *customData = (ZWCustomData *)data;
        self.titleLabel.text = customData.title;
        self.subtitleLabel.text = customData.subtitle;
        self.imageView.image = customData.image;
    }
}

@end
