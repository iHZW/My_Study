#import "ZWSettingContainerViewModel.h"
#import "UIAlertUtil.h"
#import "UIApplication+Ext.h"
#import "PersonalHeader.h"

@interface ZWSettingContainerViewModel () { ZWBaseView *_view; }
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIButton *settingBtn;
@property (nonatomic, strong) UIButton *accountBtn;
@property (nonatomic, assign) BOOL isLogin;
@end

@implementation ZWSettingContainerViewModel
@synthesize view = _view;

- (instancetype)init {
    if (self = [super init]) {
        self.isLogin = ZWUserAccountManager.sharedZWUserAccountManager.isLogin;
        [self buildInterface];
        [self updateLoginStatus];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:NOTIFICATION_LOGIN_SUCCESS object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutSuccess) name:NOTIFICATION_LOGOUT_SUCCESS object:nil];
    }
    return self;
}

- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self]; }

- (UILabel *)labelWithText:(NSString *)text color:(UIColor *)color font:(UIFont *)font {
    UILabel *label = [[UILabel alloc] init]; label.text = text; label.textColor = color; label.font = font; return label;
}

- (void)buildInterface {
    UILabel *title = [self labelWithText:@"账户与设置" color:UIColorFromRGB(0x294B46) font:[UIFont systemFontOfSize:19 weight:UIFontWeightBold]];
    UILabel *hint = [self labelWithText:@"管理你的应用偏好与账户" color:UIColorFromRGB(0x8B9894) font:[UIFont systemFontOfSize:12]];
    [self.view addSubview:title]; [self.view addSubview:hint]; [self.view addSubview:self.cardView];
    [self.cardView addSubview:self.settingBtn]; [self.cardView addSubview:self.accountBtn];

    NSString *version = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"1.0";
    UILabel *versionLabel = [self labelWithText:[NSString stringWithFormat:@"My Study  ·  v%@", version] color:UIColorFromRGB(0xA6AFAC) font:[UIFont systemFontOfSize:11]];
    [self.view addSubview:versionLabel];

    [title mas_makeConstraints:^(MASConstraintMaker *make) { make.left.equalTo(self.view).offset(20); make.top.equalTo(self.view).offset(2); }];
    [hint mas_makeConstraints:^(MASConstraintMaker *make) { make.left.equalTo(title); make.top.equalTo(title.mas_bottom).offset(4); }];
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) { make.left.equalTo(self.view).offset(16); make.right.equalTo(self.view).offset(-16); make.top.equalTo(hint.mas_bottom).offset(14); make.height.mas_equalTo(116); }];
    [self.settingBtn mas_makeConstraints:^(MASConstraintMaker *make) { make.top.left.right.equalTo(self.cardView); make.height.mas_equalTo(58); }];
    [self.accountBtn mas_makeConstraints:^(MASConstraintMaker *make) { make.left.right.bottom.equalTo(self.cardView); make.height.mas_equalTo(58); }];
    [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) { make.centerX.equalTo(self.view); make.top.equalTo(self.cardView.mas_bottom).offset(18); }];

    UIView *line = [[UIView alloc] init]; line.backgroundColor = UIColorFromRGB(0xEDF1EF); [self.cardView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) { make.left.equalTo(self.cardView).offset(54); make.right.equalTo(self.cardView).offset(-14); make.centerY.equalTo(self.cardView); make.height.mas_equalTo(1); }];
}

- (UIButton *)menuButtonWithTitle:(NSString *)title icon:(NSString *)icon action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    [button setTitle:[NSString stringWithFormat:@"    %@    %@", icon, title] forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0x34524D) forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)openSetting { [ZWM.router executeURLNoCallBack:ZWRouterPageSettingViewController]; }

- (void)handleAccount {
    if (!self.isLogin) { [ZWM.router executeURLNoCallBack:ZWRouterPageLoginViewController]; return; }
    @pas_weakify_self
    [UIAlertUtil showAlertTitle:@"退出登录" message:@"确定要退出当前账号吗？" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] actionBlock:^(NSInteger index) {
        @pas_strongify_self
        if (index == 1) {
            [ZWUserAccountManager.sharedZWUserAccountManager cleanLoginStatusData];
            self.isLogin = NO;
            [self updateLoginStatus];
            [Toast show:@"已退出登录"];
        }
    } superVC:UIApplication.displayViewController];
}

- (void)loginSuccess { self.isLogin = YES; [self updateLoginStatus]; }
- (void)logoutSuccess { self.isLogin = NO; [self updateLoginStatus]; }
- (void)updateLoginStatus {
    NSString *title = self.isLogin ? @"退出当前账号" : @"登录账号";
    NSString *icon = self.isLogin ? @"↗" : @"→";
    [self.accountBtn setTitle:[NSString stringWithFormat:@"    %@    %@", icon, title] forState:UIControlStateNormal];
}

- (ZWBaseView *)view {
    if (!_view) { _view = [[ZWBaseView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, self.heightView)]; _view.backgroundColor = kPersonalDefaultBGColor; }
    return _view;
}
- (UIView *)cardView {
    if (!_cardView) { _cardView = [[UIView alloc] init]; _cardView.backgroundColor = UIColor.whiteColor; _cardView.layer.cornerRadius = 17; _cardView.layer.masksToBounds = YES; }
    return _cardView;
}
- (UIButton *)settingBtn {
    if (!_settingBtn) _settingBtn = [self menuButtonWithTitle:@"应用设置" icon:@"⚙" action:@selector(openSetting)]; return _settingBtn;
}
- (UIButton *)accountBtn {
    if (!_accountBtn) _accountBtn = [self menuButtonWithTitle:@"登录账号" icon:@"→" action:@selector(handleAccount)]; return _accountBtn;
}
- (CGFloat)heightView { return 236; }
- (NSString *)reuseIdentifier { return @"ZWSettingContainerViewIdentifier"; }
- (void)refreshView { [self updateLoginStatus]; }
- (void)themeChangeNotification {}
@end
