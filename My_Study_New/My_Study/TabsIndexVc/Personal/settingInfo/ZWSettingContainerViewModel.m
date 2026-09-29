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

@property (nonatomic, strong) UIButton *loginBtn;

@end

@implementation ZWSettingContainerViewModel
@synthesize view = _view;

- (instancetype)init
{
    if (self = [super init]) {
        self.view.backgroundColor = kPersonalDefaultBGColor;
        self.isLogin = [ZWUserAccountManager sharedZWUserAccountManager].isLogin;
        [self loadSubViews];
        [self updatLoginStatus];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_loginSuccess)
                                                     name:NOTIFICATION_LOGIN_SUCCESS
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_logoutSuccess)
                                                     name:NOTIFICATION_LOGOUT_SUCCESS
                                                   object:nil];
    }
    return self;
}


- (void)loadSubViews
{
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.settingBtn];
    [self.view addSubview:self.logoutBtn];
    [self.view addSubview:self.loginBtn];
    
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
    
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(15);
        make.right.offset(-15);
        make.top.equalTo(self.settingBtn.mas_bottom).offset(20);
        make.height.equalTo(self.settingBtn.mas_height);
    }];
    
    /** 设置按钮 图片和文字间距5  */
    [self.settingBtn setButtonImageTitleStyle:ButtonImageTitleStyleLeft padding:5];
    [self.logoutBtn setButtonImageTitleStyle:ButtonImageTitleStyleLeft padding:5];

}

- (void)_loginSuccess {
    self.isLogin = YES;
    [self dealWithLayout];
}

- (void)_logoutSuccess {
    self.isLogin = NO;
    [self dealWithLayout];
}


- (void)updatLoginStatus {
    self.loginBtn.hidden = self.isLogin ? YES : NO;
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
                /** 确定  */
                [Toast show:@"退出登录!!!"];
                [[ZWUserAccountManager sharedZWUserAccountManager] cleanLoginStatusData];
                self.isLogin = [[ZWUserAccountManager sharedZWUserAccountManager] isLogin];
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
        
        [self.logoutBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(settingWidth * 0.6);
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
    
    [self updatLoginStatus];

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
        _logoutBtn.layer.cornerRadius = kContainerCornerRadius;
//        [_logoutBtn setCornerRadius:kContainerCornerRadius];
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

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithFrame:CGRectZero title:@"登录" font:PASFont(22) titleColor:UIColorFromRGB(0x11111) block:^{
            [ZWM.router executeURLNoCallBack:ZWRouterPageLoginViewController];
        }];
        _loginBtn.hidden = YES;
        [_loginBtn setCornerRadius:8.0 borderWidth:1.0 borderColor:UIColorFromRGB(0x4F7AFD)];
    }
    return _loginBtn;
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
