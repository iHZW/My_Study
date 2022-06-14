//
//  MVVMView.m
//  My_Study
//
//  Created by HZW on 2021/9/6.
//  Copyright © 2021 HZW. All rights reserved.
//

#import "MVVMView.h"
#import <KVOController/KVOController.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImageDecoder.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <SDWebImage/SDWebImageDecoder.h>

@interface MVVMView ()

@property (nonatomic, strong) UILabel *nameLabe;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) MVVMViewModel *viewModel;

@end

@implementation MVVMView

- (instancetype)initWithViewModel:(MVVMViewModel *)viewModel
{
    if (self = [super init]) {
        
        self.viewModel = viewModel;
        
        @pas_weakify_self
        [RACObserve(self, name) subscribeNext:^(id  _Nullable x) {
            @pas_strongify_self
            self.nameLabe.text = x;
        }];
        
        [RACObserve(self, imageName) subscribeNext:^(id  _Nullable x) {
            @pas_strongify_self
            self.imageView.image = [UIImage decodedImageWithImage:[UIImage imageNamed:x]];
        }];
                
//        [self.KVOController observe:viewModel keyPath:@"mvvmModel.name" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
//            self.nameLabe.text = change[NSKeyValueChangeNewKey];
//        }];
//
//        [self.KVOController observe:viewModel keyPath:@"mvvmModel.imageName" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
//            NSString *imageName = change[NSKeyValueChangeNewKey];
//            self.imageView.image = [UIImage imageNamed:imageName];
//        }];
        
        
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubViews];
    }
    return self;
}


- (void)loadSubViews
{
    [self addSubview:self.imageView];
    [self addSubview:self.nameLabe];
    
    [self.nameLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.bottom.equalTo(self.nameLabe.mas_top);
    }];
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
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
        _nameLabe = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabe.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabe;
}


- (void)clickAction
{
    if ([self.delegate respondsToSelector:@selector(mvvmViewClickDelegate:)]) {
        [self.delegate mvvmViewClickDelegate:self];
    }
}

- (void)setViewModel:(MVVMViewModel *)viewModel
{
    _viewModel = viewModel;
    
    [self.KVOController observe:viewModel keyPath:@"mvvmModel.name" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        self.nameLabe.text = change[NSKeyValueChangeNewKey];
    }];
    
    [self.KVOController observe:viewModel keyPath:@"mvvmModel.imageName" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        NSString *imageName = change[NSKeyValueChangeNewKey];
        self.imageView.image = [UIImage decodedImageWithImage:[UIImage imageNamed:imageName]];//[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }];    
    
}

@end
