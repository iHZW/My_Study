//
//  ZWUserContainerViewModel.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/29.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWUserContainerViewModel.h"

@interface ZWUserContainerViewModel ( )
{
    ZWBaseView *_view;
}

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ZWUserContainerViewModel
@synthesize view = _view;

- (instancetype)init
{
    if (self = [super init]) {
        
        [self loadSubViews];
    }
    return self;
}


- (void)loadSubViews
{    
    [self.view addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.centerY.equalTo(self.view);
        make.height.mas_equalTo(60);
    }];
}



#pragma mark - lazyLoad
- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel labelLeftAlignWithFrame:CGRectMake(0, 0, kMainScreenWidth, 60) text:@"个人中心头部容器" textColor:UIColorFromRGB(0x111111) font:PASFont(20)];
    }
    return _titleLabel;
}

- (ZWBaseView *)view
{
    if (!_view) {
        _view = [[ZWBaseView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, [self heightView])];
        _view.userInteractionEnabled = YES;
        _view.backgroundColor = [UIColor greenColor];
    }
    return _view;
}


#pragma mark - PASBaseViewModelAdapter
- (CGFloat)heightView; //view高度
{
    return 100;
}

- (NSString *_Nonnull)reuseIdentifier; //cell复用标识符
{
    return @"ZWUserContainerViewIdentifier";
}

- (void)refreshView; //刷新view 内容
{
    NSLog(@"%@ = %s", NSStringFromClass(self.class), __func__);
}

- (void)themeChangeNotification; //主题色变更通知
{
    
}
@end
