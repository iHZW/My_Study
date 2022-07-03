//
//  ZWUserContainerViewModel.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/29.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWSettingContainerViewModel.h"
#import "UIAlertUtil.h"
#import "UIApplication+Ext.h"
#import "PersonalHeader.h"
#import "zhThemeOperator.h"
#import "UIButton+Custom.h"

@interface ZWSettingContainerViewModel ( )
{
    ZWBaseView *_view;
}
/** 设置  */
@property (nonatomic, strong) UIButton *settingBtn;
/** 退出登录  */
@property (nonatomic, strong) UIButton *logoutBtn;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, assign) BOOL isLogin;

@end

@implementation ZWSettingContainerViewModel
@synthesize view = _view;

- (instancetype)init
{
    if (self = [super init]) {
        self.view.backgroundColor = kPersonalDefaultBGColor;
        self.isLogin = YES;
        [self loadSubViews];
    }
    return self;
}


- (void)loadSubViews
{
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.settingBtn];
    [self.view addSubview:self.logoutBtn];
    
    CGFloat settingWidth = (CGRectGetWidth(self.view.frame) - kContentSideHorizSpace * 3);
    [self.settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(kContentSideHorizSpace);
        make.top.equalTo(self.view.mas_top).offset(kContentSideVertiSpace);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(settingWidth * 0.4);
    }];
    
    [self.logoutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self.settingBtn);
        make.left.equalTo(self.settingBtn.mas_right).offset(kContentSideHorizSpace);
        make.width.mas_equalTo(settingWidth * 0.6);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.settingBtn.mas_bottom);
//        make.top.left.right.bottom.equalTo(self.view);
        make.edges.mas_equalTo(kContainerEdgeInsets);
    }];
    
    /** 设置按钮 图片和文字间距5  */
    [self.settingBtn setButtonImageTitleStyle:ButtonImageTitleStyleLeft padding:5];
    [self.logoutBtn setButtonImageTitleStyle:ButtonImageTitleStyleLeft padding:5];

}

/**
 *  处理退出登录点击
 */
- (void)dealWithlogoutAction
{
    @pas_weakify_self
    [UIAlertUtil showAlertTitle:@"温馨提示" message:@"确定注销登录吗?" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] actionBlock:^(NSInteger index) {
        @pas_strongify_self
        switch (index) {
            case 1:
            {
                self.isLogin = NO;
                /** 确定  */
                [Toast show:@"退出登录!!!"];
                [self dealWithLayout];
            }
                break;
                
            default:
                break;
        }
    } superVC:[UIApplication displayViewController]];
}


- (void)dealWithLayout
{
    CGFloat settingWidth = (CGRectGetWidth(self.view.frame) - kContentSideHorizSpace * 3);
    if (self.isLogin) {
        self.logoutBtn.hidden = NO;
        [self.settingBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(settingWidth * 0.4);
        }];
    } else {
        self.logoutBtn.hidden = YES;

        [self.settingBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(settingWidth + kContentSideHorizSpace);
        }];
        
        [self.logoutBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
    }

}


#pragma mark - lazyLoad
- (ZWBaseView *)view
{
    if (!_view) {
        _view = [[ZWBaseView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, [self heightView])];
        _view.userInteractionEnabled = YES;
        _view.backgroundColor = [UIColor yellowColor];
    }
    return _view;
}

- (UIButton *)settingBtn
{
    if (!_settingBtn) {
        _settingBtn = [UIButton buttonWithFrame:CGRectZero title:@"设置" font:PASFont(22) titleColor:UIColorFromRGB(0x111111) block:^{
            [ZWM.router executeURLNoCallBack:ZWRouterPageSettingViewController];
        }];
        [_settingBtn setCornerRadius:kContainerCornerRadius];
        [_settingBtn setImage:[UIImage imageNamed:@"icon_new_setting"] forState:UIControlStateNormal];
        @pas_weakify_self
        [_settingBtn zh_themeUpdateCallback:^(id  _Nonnull target) {
            @pas_strongify_self
            [self.settingBtn setTitleColor:ThemePickerColorKey(ZWColorKey_p4).color forState:UIControlStateNormal];
            self.settingBtn.backgroundColor = ThemePickerColorKey(ZWColorKey_p8).color;
        }];
    }
    return _settingBtn;
}

- (UIButton *)logoutBtn
{
    if (!_logoutBtn) {
        @pas_weakify_self
        _logoutBtn = [UIButton buttonWithFrame:CGRectZero title:@"退出登录" font:PASFont(22) titleColor:UIColorFromRGB(0x111111) block:^{
            @pas_strongify_self
            [self dealWithlogoutAction];
        }];
        [_logoutBtn setCornerRadius:kContainerCornerRadius];
        [_logoutBtn setImage:[UIImage imageNamed:@"icon_logout"] forState:UIControlStateNormal];
        [_logoutBtn setButtonImageTitleStyle:ButtonImageTitleStyleLeft padding:0];
        [_logoutBtn zh_themeUpdateCallback:^(id  _Nonnull target) {
            @pas_strongify_self
            [self.logoutBtn setTitleColor:ThemePickerColorKey(ZWColorKey_p4).color forState:UIControlStateNormal];
            self.logoutBtn.backgroundColor = ThemePickerColorKey(ZWColorKey_p8).color;
        }];
    }
    return _logoutBtn;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [UIImageView imageViewForImage:[UIImage imageNamed:@"setting_bg_image"] withFrame:CGRectZero];
        [_imageView setCornerRadius:kContainerCornerRadius];
    }
    return _imageView;
}


#pragma mark - PASBaseViewModelAdapter
- (CGFloat)heightView; //view高度
{
    return 500;
}

- (NSString *_Nonnull)reuseIdentifier; //cell复用标识符
{
    return @"ZWSettingContainerViewIdentifier";
}

- (void)refreshView; //刷新view 内容
{
    NSLog(@"%@ = %s", NSStringFromClass(self.class), __func__);
}

- (void)themeChangeNotification; //主题色变更通知
{
    
}
@end
