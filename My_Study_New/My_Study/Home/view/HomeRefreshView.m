//
//  HomeRefreshView.m
//  My_Study
//
//  Created by hzw on 2022/9/24.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "HomeRefreshView.h"
#import "KVOController.h"

@interface HomeRefreshView ()

@property (nonatomic, strong) UIButton *refreshBtn;

@property (nonatomic, strong) UIButton *iconBtn;

@end


@implementation HomeRefreshView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self loadSubView];
    }
    return self;
}

- (void)loadSubView
{
    UIColor *primaryColor = UIColorFromRGB(0x315F57);
    UIColor *softColor = UIColorFromRGB(0xE8F3EF);
    UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    refreshBtn.frame = CGRectMake(0, 0, 76, 38);
    refreshBtn.layer.cornerRadius = 12;
    refreshBtn.backgroundColor = softColor;
    refreshBtn.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    refreshBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [refreshBtn setTitle:@"↻ 刷新" forState:UIControlStateNormal];
    [refreshBtn setTitleColor:primaryColor forState:UIControlStateNormal];
    refreshBtn.accessibilityLabel = @"刷新首页数据";
    [refreshBtn addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:refreshBtn];

    self.refreshBtn = refreshBtn;
    
    self.iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.iconBtn.frame = CGRectMake(84, 0, 36, 38);
    self.iconBtn.backgroundColor = softColor;
    self.iconBtn.layer.cornerRadius = 12;
    self.iconBtn.tintColor = primaryColor;
    self.iconBtn.accessibilityLabel = @"更新示例名称";
    if (@available(iOS 13.0, *)) {
        [self.iconBtn setImage:[UIImage systemImageNamed:@"plus"] forState:UIControlStateNormal];
    } else {
        [self.iconBtn setTitle:@"+" forState:UIControlStateNormal];
        [self.iconBtn setTitleColor:primaryColor forState:UIControlStateNormal];
        self.iconBtn.titleLabel.font = [UIFont systemFontOfSize:23 weight:UIFontWeightLight];
    }
    [self.iconBtn addTarget:self action:@selector(iconAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.iconBtn];
}


- (void)refreshAction
{
    BlockSafeRun(self.actinBlock);
}

- (void)iconAction
{
    self.viewModel.name = @"over";
}

#pragma mark - setter
- (void)setViewModel:(HomeViewModel *)viewModel
{
    _viewModel = viewModel;
    
    @pas_weakify_self
    [self.KVOController observe:self.viewModel keyPath:@"name" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @pas_strongify_self
        NSString *chaneValue = change[NSKeyValueChangeNewKey];
        self.name = chaneValue;
    }];
    
}

- (void)setName:(NSString *)name
{
    NSString *title = name.length > 0 ? [NSString stringWithFormat:@"↻ %@", name] : @"↻ 刷新";
    [self.refreshBtn setTitle:title forState:UIControlStateNormal];
}


@end
