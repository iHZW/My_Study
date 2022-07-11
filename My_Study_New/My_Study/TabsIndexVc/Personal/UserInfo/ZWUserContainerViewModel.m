//
//  ZWUserContainerViewModel.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/29.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWUserContainerViewModel.h"
#import "PersonalHeader.h"

@interface ZWUserContainerViewModel ( )
{
    ZWBaseView *_view;
}

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UIView *headView;

@property (nonatomic, strong) UIView *userInfoView;

@property (nonatomic, strong) UILabel *titleLabel;


@end

@implementation ZWUserContainerViewModel
@synthesize view = _view;

- (instancetype)init
{
    if (self = [super init]) {
        self.containerView.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p2);
        [self loadSubViews];
    }
    return self;
}


- (void)loadSubViews
{
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.headView];
    [self.containerView addSubview:self.userInfoView];
    [self.userInfoView addSubview:self.titleLabel];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(kContainerEdgeInsets);
    }];
    
    [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.containerView);
        make.height.mas_equalTo(200);
    }];
    
    [self.userInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headView.mas_bottom).offset(5);
        make.left.right.bottom.equalTo(self.containerView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.centerY.equalTo(self.userInfoView);
        make.height.mas_equalTo(60);
    }];
}



#pragma mark - lazyLoad
- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel labelLeftAlignWithFrame:CGRectMake(0, 0, kMainScreenWidth, 60) text:@"个人中心头部容器" textColor:UIColorFromRGB(0x111111) font:PASFont(20)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleLabel setCornerRadius:kContainerCornerRadius];
        _titleLabel.zh_textColorPicker = ThemePickerColorKey(ZWColorKey_p4);
        _titleLabel.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p8);
    }
    return _titleLabel;
}

- (ZWBaseView *)view
{
    if (!_view) {
        _view = [[ZWBaseView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, [self heightView])];
        _view.userInteractionEnabled = YES;
    }
    return _view;
}

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [UIView viewForColor:kPersonalDefaultBGColor withFrame:CGRectZero];
        [_containerView setCornerRadius:kContainerCornerRadius];
    }
    return _containerView;
}

- (UIView *)headView
{
    if (!_headView) {
        _headView = [UIView viewForColor:kPersonalDefaultBGColor withFrame:CGRectZero];
        _headView.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p2);
    }
    return _headView;
}

- (UIView *)userInfoView
{
    if (!_userInfoView) {
        _userInfoView = [UIView viewForColor:UIColorFromRGB(0xFFFFFF) withFrame:CGRectZero];
        [_userInfoView setCornerRadius:kContainerCornerRadius];
        _userInfoView.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p8);

    }
    return _userInfoView;
}

#pragma mark - PASBaseViewModelAdapter
- (CGFloat)heightView; //view高度
{
    return 500;
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
