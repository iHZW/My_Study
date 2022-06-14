//
//  TestMVPView.m
//  My_Study
//
//  Created by HZW on 2021/9/6.
//  Copyright © 2021 HZW. All rights reserved.
//

#import "TestMVPView.h"

@interface TestMVPView ()

@property (nonatomic, strong) UILabel *nameLabe;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation TestMVPView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self loadSubViews];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadSubViews];
    }
    return self;
}

- (void)loadSubViews
{
    [self addSubview:self.imageView];
    [self addSubview:self.nameLabe];
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 80, 80)];
//        _imageView.image = [UIImage imageNamed:@""];
        _imageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAction)];
        [_imageView addGestureRecognizer:tap];
    }
    return _imageView;
}


- (UILabel *)nameLabe
{
    if (!_nameLabe) {
        _nameLabe = [[UILabel alloc] initWithFrame:CGRectMake(100, 200, 60, 30)];
    }
    return _nameLabe;
}


- (void)setName:(NSString *)name iamgeName:(NSString *)imageName
{
    self.nameLabe.text = name;
    self.imageView.image = [UIImage imageNamed:imageName];
}



- (void)clickAction
{
    NSLog(@"%s", __func__);
    if ([self.delegate respondsToSelector:@selector(mvpViewClickDelegate:)]) {
        [self.delegate mvpViewClickDelegate:self];
    }
}

@end
