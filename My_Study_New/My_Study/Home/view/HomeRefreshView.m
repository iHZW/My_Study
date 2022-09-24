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
    UIButton * refreshBtn = [UIButton buttonWithFrame:CGRectMake(0, 0, 50, CGRectGetHeight(self.frame)) title:@"刷新" font:PASBFont(18) titleColor:UIColor.whiteColor block:nil];
    refreshBtn.layer.cornerRadius = 8;
    refreshBtn.backgroundColor = UIColor.blueColor;
    [refreshBtn addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:refreshBtn];

    self.refreshBtn = refreshBtn;
    
    
    self.iconBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    
    self.iconBtn.frame = CGRectMake(55, 0, 25, CGRectGetHeight(self.frame));
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
    [self.refreshBtn setTitle:TransToString(name) forState:UIControlStateNormal];
}


@end
