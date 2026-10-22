//
//  LoginViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginManager.h"
#import "Toast.h"
#import "ZWUserAccountManager.h"
#import "OneKeyLoginBgView.h"
#import "OneKeyLogin.h"
#import "UIView+Util.h"

#import <DingxiangCaptchaSDKStatic/DXCaptchaView.h>
#import <DingxiangCaptchaSDKStatic/DXCaptchaDelegate.h>
#import <DXRiskStatic/DXRiskManager.h>
#import "GCDCommon.h"
#import "UIApplication/UIApplication+Ext.h"


#define kItemHeight 56

#define kAccountString @"100"
#define kPasswordString @"100"
#define kDXCaptchaViewTag       (20240418)


typedef void (^CompleteBlock)(id result);


@interface LoginViewController ()<
UITextFieldDelegate,
OneKeyLoginBgViewDelegate,
OneKeyLoginDelegate,
DXCaptchaDelegate>

@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *loginContentView;

@property (nonatomic, strong) UITextField *accountTextFiled;

@property (nonatomic, strong) UIView *accountRow;

@property (nonatomic, strong) UITextField *passwordTextField;

@property (nonatomic, strong) UIView *passwordRow;
@property (nonatomic, strong) UIScrollView *loginScrollView;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *cardTitleLabel;
@property (nonatomic, strong) UILabel *footerLabel;
@property (nonatomic, strong) UILabel *brandLabel;
@property (nonatomic, strong) UIView *brandMark;
@property (nonatomic, strong) UIButton *passwordVisibilityButton;

@property (nonatomic, strong) UIButton *loginBtn;
/** 顶象验证码视图 */
@property (nonatomic, strong) DXCaptchaView *captchaView;
/** 顶部授权控制器  */
@property (nonatomic, strong) UIViewController *authTopViewController;
/** 一键登录界面view  */
@property (nonatomic, strong) OneKeyLoginBgView* oneKeyLoginBgView;
/** 授权页面的截图， 为了跳转到下一个页面，不看到下面关闭授权效果  */
@property (nonatomic, strong) UIImageView *fakeAuthImageView;

@property (nonatomic, copy) CompleteBlock completeBlock;

@property (nonatomic, assign) BOOL isPresentPage;

@end

@implementation LoginViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeCaptchaView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RouterType type = self.routerParamObject.type;
    self.isPresentPage = type == RouterTypeNavigatePresent;

    [self loadSubViews];
    // 跟随应用主题更新；不自动弹出键盘，先完整展示登录页。
    __weak typeof(self) weakSelf = self;
    [self.view zh_themeUpdateCallback:^(id target) { [weakSelf applyLoginTheme]; }];
    [self applyLoginTheme];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginKeyboardChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginKeyboardChanged:) name:UIKeyboardWillHideNotification object:nil];
}

- (UILabel *)loginLabel:(NSString *)text size:(CGFloat)size weight:(UIFontWeight)weight {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:size weight:weight];
    label.numberOfLines = 0;
    return label;
}

- (UITextField *)loginField:(NSString *)placeholder secure:(BOOL)secure {
    UITextField *field = [[UITextField alloc] init];
    field.placeholder = placeholder;
    field.font = [UIFont systemFontOfSize:16];
    field.secureTextEntry = secure;
    field.delegate = self;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field.clearButtonMode = secure ? UITextFieldViewModeNever : UITextFieldViewModeWhileEditing;
    field.returnKeyType = secure ? UIReturnKeyGo : UIReturnKeyNext;
    field.textContentType = secure ? UITextContentTypePassword : UITextContentTypeUsername;
    if (secure) field.keyboardType = UIKeyboardTypeNumberPad;
    [field addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventEditingChanged];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.items = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(dismissLoginKeyboard)]];
    field.inputAccessoryView = toolbar;
    return field;
}

- (UIView *)loginRow:(UITextField *)field title:(NSString *)title {
    UIView *row = [[UIView alloc] init];
    row.layer.cornerRadius = 14;
    row.layer.borderWidth = 1;
    UILabel *label = [self loginLabel:title size:14 weight:UIFontWeightMedium];
    label.tag = 1001;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    field.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:label];
    [row addSubview:field];
    [NSLayoutConstraint activateConstraints:@[
        [row.heightAnchor constraintEqualToConstant:kItemHeight],
        [label.leadingAnchor constraintEqualToAnchor:row.leadingAnchor constant:16],
        [label.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
        [label.widthAnchor constraintEqualToConstant:40],
        [field.leadingAnchor constraintEqualToAnchor:label.trailingAnchor constant:12],
        [field.topAnchor constraintEqualToAnchor:row.topAnchor],
        [field.bottomAnchor constraintEqualToAnchor:row.bottomAnchor],
        [field.trailingAnchor constraintEqualToAnchor:row.trailingAnchor constant:field.secureTextEntry ? -60 : -12]
    ]];
    return row;
}

- (void)loadSubViews {
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.closeBtn setTitle:self.isPresentPage ? @"关闭" : @"返回" forState:UIControlStateNormal];
    self.closeBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    self.closeBtn.accessibilityLabel = @"退出登录页面";
    [self.closeBtn addTarget:self action:@selector(closeLoginPage) forControlEvents:UIControlEventTouchUpInside];
    self.closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.closeBtn];

    self.loginScrollView = [[UIScrollView alloc] init];
    self.loginScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.loginScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.loginScrollView.alwaysBounceVertical = YES;
    self.loginScrollView.showsVerticalScrollIndicator = NO;
    self.loginScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.view addSubview:self.loginScrollView];
    UIStackView *content = [[UIStackView alloc] init];
    content.axis = UILayoutConstraintAxisVertical;
    content.spacing = 0;
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [self.loginScrollView addSubview:content];
    [NSLayoutConstraint activateConstraints:@[
        [self.closeBtn.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:20],
        [self.closeBtn.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:4],
        [self.closeBtn.widthAnchor constraintEqualToConstant:48],
        [self.closeBtn.heightAnchor constraintEqualToConstant:44],
        [self.loginScrollView.topAnchor constraintEqualToAnchor:self.closeBtn.bottomAnchor],
        [self.loginScrollView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.loginScrollView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.loginScrollView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [content.topAnchor constraintEqualToAnchor:self.loginScrollView.contentLayoutGuide.topAnchor constant:28],
        [content.bottomAnchor constraintEqualToAnchor:self.loginScrollView.contentLayoutGuide.bottomAnchor constant:-28],
        [content.centerXAnchor constraintEqualToAnchor:self.loginScrollView.frameLayoutGuide.centerXAnchor],
        [content.widthAnchor constraintLessThanOrEqualToAnchor:self.loginScrollView.frameLayoutGuide.widthAnchor constant:-40],
        [content.widthAnchor constraintLessThanOrEqualToConstant:440]
    ]];
    NSLayoutConstraint *preferredWidth = [content.widthAnchor constraintEqualToAnchor:self.loginScrollView.frameLayoutGuide.widthAnchor constant:-40];
    preferredWidth.priority = UILayoutPriorityDefaultHigh;
    preferredWidth.active = YES;

    self.brandMark = [[UIView alloc] init];
    self.brandMark.layer.cornerRadius = 19;
    UILabel *mark = [self loginLabel:@"✦" size:30 weight:UIFontWeightMedium];
    mark.textColor = UIColor.whiteColor;
    mark.translatesAutoresizingMaskIntoConstraints = NO;
    [self.brandMark addSubview:mark];
    [NSLayoutConstraint activateConstraints:@[[self.brandMark.widthAnchor constraintEqualToConstant:64], [self.brandMark.heightAnchor constraintEqualToConstant:64], [mark.centerXAnchor constraintEqualToAnchor:self.brandMark.centerXAnchor], [mark.centerYAnchor constraintEqualToAnchor:self.brandMark.centerYAnchor]]];
    self.brandLabel = [self loginLabel:@"探索 · 记录 · 成长" size:12 weight:UIFontWeightMedium];
    UIStackView *brand = [[UIStackView alloc] initWithArrangedSubviews:@[self.brandMark, self.brandLabel]];
    brand.axis = UILayoutConstraintAxisHorizontal;
    brand.spacing = 14;
    brand.alignment = UIStackViewAlignmentCenter;
    [content addArrangedSubview:brand];
    [content setCustomSpacing:26 afterView:brand];
    self.titleLabel = [self loginLabel:@"欢迎回来" size:32 weight:UIFontWeightSemibold];
    [content addArrangedSubview:self.titleLabel];
    [content setCustomSpacing:10 afterView:self.titleLabel];
    self.subtitleLabel = [self loginLabel:@"登录账号，继续探索生活里的小美好。" size:14 weight:UIFontWeightRegular];
    [content addArrangedSubview:self.subtitleLabel];
    [content setCustomSpacing:32 afterView:self.subtitleLabel];

    self.loginContentView = [[UIView alloc] init];
    self.loginContentView.layer.cornerRadius = 24;
    self.loginContentView.layer.borderWidth = 1;
    [content addArrangedSubview:self.loginContentView];
    UIStackView *form = [[UIStackView alloc] init];
    form.translatesAutoresizingMaskIntoConstraints = NO;
    form.axis = UILayoutConstraintAxisVertical;
    form.spacing = 14;
    [self.loginContentView addSubview:form];
    [NSLayoutConstraint activateConstraints:@[[form.leadingAnchor constraintEqualToAnchor:self.loginContentView.leadingAnchor constant:20], [form.trailingAnchor constraintEqualToAnchor:self.loginContentView.trailingAnchor constant:-20], [form.topAnchor constraintEqualToAnchor:self.loginContentView.topAnchor constant:24], [form.bottomAnchor constraintEqualToAnchor:self.loginContentView.bottomAnchor constant:-24]]];
    self.cardTitleLabel = [self loginLabel:@"账号登录" size:18 weight:UIFontWeightSemibold];
    [form addArrangedSubview:self.cardTitleLabel];
    [form setCustomSpacing:22 afterView:self.cardTitleLabel];
    self.accountTextFiled = [self loginField:@"请输入账号" secure:NO];
    self.passwordTextField = [self loginField:@"请输入密码" secure:YES];
    self.accountRow = [self loginRow:self.accountTextFiled title:@"账号"];
    self.passwordRow = [self loginRow:self.passwordTextField title:@"密码"];
    [form addArrangedSubview:self.accountRow];
    [form addArrangedSubview:self.passwordRow];
    self.passwordVisibilityButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.passwordVisibilityButton setTitle:@"显示" forState:UIControlStateNormal];
    self.passwordVisibilityButton.accessibilityLabel = @"显示密码";
    self.passwordVisibilityButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    [self.passwordVisibilityButton addTarget:self action:@selector(togglePasswordVisibility) forControlEvents:UIControlEventTouchUpInside];
    self.passwordVisibilityButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.passwordRow addSubview:self.passwordVisibilityButton];
    [NSLayoutConstraint activateConstraints:@[[self.passwordVisibilityButton.trailingAnchor constraintEqualToAnchor:self.passwordRow.trailingAnchor constant:-4], [self.passwordVisibilityButton.centerYAnchor constraintEqualToAnchor:self.passwordRow.centerYAnchor], [self.passwordVisibilityButton.widthAnchor constraintEqualToConstant:52], [self.passwordVisibilityButton.heightAnchor constraintEqualToConstant:44]]];
    self.loginBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.loginBtn setTitle:@"登 录" forState:UIControlStateNormal];
    self.loginBtn.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    [self.loginBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.loginBtn.layer.cornerRadius = 14;
    [self.loginBtn.heightAnchor constraintEqualToConstant:54].active = YES;
    [self.loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [form setCustomSpacing:24 afterView:self.passwordRow];
    [form addArrangedSubview:self.loginBtn];
    [content setCustomSpacing:24 afterView:self.loginContentView];
    self.footerLabel = [self loginLabel:@"让每一次探索，都留下成长的印记。" size:12 weight:UIFontWeightRegular];
    self.footerLabel.textAlignment = NSTextAlignmentCenter;
    [content addArrangedSubview:self.footerLabel];
    [self valueChange:nil];
}

- (void)applyLoginTheme {
    // 使用应用自身的主题色判断明暗，兼容应用内手动切换主题。
    UIColor *base = ThemePickerColorKey(ZWColorKey_p1).color;
    CGFloat red = 1, green = 1, blue = 1, alpha = 1;
    [base getRed:&red green:&green blue:&blue alpha:&alpha];
    BOOL dark = red * 0.299 + green * 0.587 + blue * 0.114 < 0.5;
    UIColor *(^color)(NSUInteger) = ^UIColor *(NSUInteger hex) { return [UIColor colorWithRed:((hex >> 16) & 255) / 255.0 green:((hex >> 8) & 255) / 255.0 blue:(hex & 255) / 255.0 alpha:1]; };
    UIColor *accent = color(dark ? 0x85B9A8 : 0x315F57);
    UIColor *ink = color(dark ? 0xE2EDE7 : 0x294B46);
    UIColor *muted = color(dark ? 0xA0B3A9 : 0x82918E);
    self.view.backgroundColor = color(dark ? 0x17221E : 0xF4F7F5);
    self.loginContentView.backgroundColor = color(dark ? 0x21312A : 0xFFFFFF);
    self.loginContentView.layer.borderColor = color(dark ? 0x34483E : 0xE4ECE7).CGColor;
    self.brandMark.backgroundColor = color(0x315F57);
    self.brandLabel.textColor = accent;
    self.titleLabel.textColor = ink;
    self.cardTitleLabel.textColor = ink;
    self.subtitleLabel.textColor = muted;
    self.footerLabel.textColor = muted;
    self.closeBtn.tintColor = accent;
    self.passwordVisibilityButton.tintColor = accent;
    self.loginBtn.backgroundColor = color(dark ? 0x416F61 : 0x315F57);
    NSArray *fields = @[self.accountTextFiled, self.passwordTextField];
    NSArray *rows = @[self.accountRow, self.passwordRow];
    for (NSUInteger index = 0; index < fields.count; index++) {
        UITextField *field = fields[index];
        UIView *row = rows[index];
        field.textColor = ink;
        field.tintColor = accent;
        field.keyboardAppearance = dark ? UIKeyboardAppearanceDark : UIKeyboardAppearanceLight;
        field.attributedPlaceholder = [[NSAttributedString alloc] initWithString:field.placeholder attributes:@{NSForegroundColorAttributeName:muted}];
        row.backgroundColor = color(dark ? 0x19281F : 0xF5F8F6);
        row.layer.borderColor = (field.isFirstResponder ? accent : color(dark ? 0x34483E : 0xE4ECE7)).CGColor;
        ((UILabel *)[row viewWithTag:1001]).textColor = ink;
        field.inputAccessoryView.tintColor = accent;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startOneKeyAuth];
}

- (void)startOneKeyAuth{
    if (self.oneKeyLogin && [self canStartOneKeyAuth]){
        [OneKeyLogin sharedOneKeyLogin].viewController = self;
        [OneKeyLogin sharedOneKeyLogin].delegate = self;
        [[OneKeyLogin sharedOneKeyLogin] preGetPhonenumber];
        
//        self.loadingContainerView.hidden = NO;
//        BOOL isBinding = self.thirdId.length > 0;
//        [OneKeyLogin sharedOneKeyLogin].isBinding = isBinding;
        
        [[OneKeyLogin sharedOneKeyLogin] quickAuthLogin:@"本机号码一键登录"];
    }
}

- (BOOL)canStartOneKeyAuth{
    BOOL result = ![ZWUserAccountManager sharedZWUserAccountManager].loginPageWithAlert;
    return result;
}

/**
 *  登录按钮点击
 */
- (void)loginAction {
    [self.view endEditing:YES];
    NSString *showMsg     = @"";
    NSString *accountStr  = self.accountTextFiled.text;
    NSString *passwordStr = self.passwordTextField.text;
    if (accountStr.length == 0) {
        showMsg = @"请输入账号!";
    } else if (passwordStr.length == 0) {
        showMsg = @"请输入密码!";
    } else if ([accountStr isEqualToString:kAccountString] && [passwordStr isEqualToString:kPasswordString]) {
        @weakify(self)
        [self handleDX:^(id result) {
            @strongify(self)
            /** 账号&密码正确  */
            [self loginCheckSuccess];
        }];

    } else {
        showMsg = @"账号或密码输入有误!!!";
    }

    if (ValidString(showMsg)) {
        [Toast show:showMsg];
    }
}

- (void)handleDX:(CompleteBlock)complete {
    [self removeCaptchaView];

    self.completeBlock = complete;
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
     // 以下是私有化配置参数
    [config setObject:@"dxdxdxtest2017keyc3e83b6940835" forKey:@"appId"];
//    [config setObject:DEFAULT_APISERVER forKey:@"apiServer"];
//    [config setObject:DEFAULT_UAJS forKey:@"ua_js"];
//    [config setObject:DEFAULT_CAPTCHA_JS forKey:@"captchaJS"];
//    [config setObject:DEFAULT_ConID_JS forKey:@"constID_js"];
//    [config setObject:DEFAULT_ConIDServer forKey:@"constIDServer"];
//    [config setObject:@YES forKey:@"isSaaS"];
//    [config setObject:@YES forKey:@"inSDK"];
//    [config setObject:DEFAULT_SERVER_LESS_BG forKey:@"serverlessBgSrc"];
    

    CGRect frame = CGRectMake(self.view.center.x - 150, self.view.center.y - 100, 300, 200);
    DXCaptchaView *captchaView = [[DXCaptchaView alloc] initWithConfig:config delegate:self frame:frame];
    captchaView.tag = kDXCaptchaViewTag;
    self.captchaView = captchaView;
    [[UIApplication displayWindow] addSubview:captchaView];
}

- (void)removeCaptchaView {
    [self.captchaView removeFromSuperview];
    self.captchaView = nil;
    [self.class _handleRemoveExistPopView:kDXCaptchaViewTag];
}

+ (void)_handleRemoveExistPopView:(NSInteger)tag {
    performBlockOnMainQueue(NO, ^{
        NSMutableArray<UIWindow *> *windows = [NSMutableArray array];
        UIWindow *displayWindow = [UIApplication displayWindow];
        if (displayWindow) {
            [windows addObject:displayWindow];
        }

        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            if (window && ![windows containsObject:window]) {
                [windows addObject:window];
            }
        }

        for (UIWindow *window in windows) {
            UIView *subView = [window viewWithTag:tag];
            while (subView) {
                [subView removeFromSuperview];
                subView = [window viewWithTag:tag];
            }
        }
    });
}

#pragma mark - DXCaptchaDelegate
- (void)captchaView:(DXCaptchaView *)view
    didReceiveEvent:(DXCaptchaEventType)eventType
                arg:(NSDictionary *)dict {
    switch (eventType) {
        case DXCaptchaEventSuccess: {
            NSString *token = dict[@"token"];
            performBlockOnMainQueue(NO, ^{
                CompleteBlock completeBlock = self.completeBlock;
                self.completeBlock = nil;
                [self removeCaptchaView];
                BlockSafeRun(completeBlock, token);
                self.view.hidden = YES;
            });
            break;
        }
        case DXCaptchaEventFail:
            break;
        default:
            break;
    }
}



/**
 *   登录校验成功
 */
- (void)loginCheckSuccess {
    ZWUserInfoModel *infoModel                                        = [ZWUserInfoModel new];
    infoModel.pid                                                     = [kAccountString integerValue];
    infoModel.userWid                                                 = [kPasswordString integerValue];
    [ZWUserAccountManager sharedZWUserAccountManager].currentUserInfo = infoModel;

    /** 登录信息存储本地  */
    [ZWSharedUserAccountManager saveLoginStatusData];
    
    if (self.isPresentPage) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }

    BlockSafeRun(self.loginCompleted);
}

- (void)valueChange:(UITextField *)textField {
    self.loginBtn.alpha = self.accountTextFiled.text.length && self.passwordTextField.text.length ? 1.0 : 0.65;
}

#pragma mark - 输入交互
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.passwordTextField) return [DataFormatterFunc isPureNumber:string];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.accountTextFiled) [self.passwordTextField becomeFirstResponder];
    else [self loginAction];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self applyLoginTheme];
    CGRect rect = [textField convertRect:textField.bounds toView:self.loginScrollView];
    [self.loginScrollView scrollRectToVisible:CGRectInset(rect, 0, -24) animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField { [self applyLoginTheme]; }

- (void)togglePasswordVisibility {
    self.passwordTextField.secureTextEntry = !self.passwordTextField.secureTextEntry;
    [self.passwordVisibilityButton setTitle:self.passwordTextField.secureTextEntry ? @"显示" : @"隐藏" forState:UIControlStateNormal];
    self.passwordVisibilityButton.accessibilityLabel = self.passwordTextField.secureTextEntry ? @"显示密码" : @"隐藏密码";
}

- (void)dismissLoginKeyboard { [self.view endEditing:YES]; }

- (void)closeLoginPage {
    [self.view endEditing:YES];
    if (self.isPresentPage || self.navigationController.presentingViewController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)loginKeyboardChanged:(NSNotification *)notification {
    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboard = [self.view convertRect:frame fromView:nil];
    CGFloat overlap = [notification.name isEqualToString:UIKeyboardWillHideNotification] ? 0 : MAX(0, CGRectGetMaxY(self.loginScrollView.frame) - CGRectGetMinY(keyboard));
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, overlap, 0);
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        self.loginScrollView.contentInset = insets;
        self.loginScrollView.scrollIndicatorInsets = insets;
    } completion:^(BOOL finished) {
        UITextField *active = self.accountTextFiled.isFirstResponder ? self.accountTextFiled : (self.passwordTextField.isFirstResponder ? self.passwordTextField : nil);
        if (active) [self.loginScrollView scrollRectToVisible:CGRectInset([active convertRect:active.bounds toView:self.loginScrollView], 0, -24) animated:YES];
    }];
}


#pragma mark - 快捷登录
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion{
    if ([viewControllerToPresent isKindOfClass:[UINavigationController class]]){
        
        UIViewController *authPageVC = [(UINavigationController *)viewControllerToPresent topViewController];;
        if (authPageVC != nil){
            //https://shanyan.253.com/document/details?lid=374&cid=93&pc=28&pn=%25E9%2597%25AA%25E9%25AA%258CSDK
            //重要：如项目中使用闪验vcclass的字符串判断类名等非常规操作，如"ZUOAuthViewController"、"UAAuthViewController"、"PublicLoginViewController"、"CLCTCCCarouselViewController"、"CLCTCCCarouselNavigationController"、"UANavigationController"、"CLCTCCPublicLoginNavigationController"、"CLShanYanAuthPageIsaSwizzleNavigationController"，现已统一为：CLShanYanAuthPageNavigationController(授权页nav)、CLShanYanAuthPageViewController(授权页vc)、CLCTCCCarouselNavigationController(弹窗模式下协议页nav)、CLCTCCCarouselViewController(协议页vc)
            Class uaAuthViewControllerClass =  NSClassFromString(@"CLShanYanAuthPageViewController");
            if ([authPageVC isKindOfClass:uaAuthViewControllerClass]){
                self.authTopViewController = authPageVC;
//                authPageVC.fd_prefersNavigationBarHidden = YES;
                [self setAuthPageSubView:self.authTopViewController.view];
            }
        }
    }
    [super presentViewController:viewControllerToPresent animated:NO completion:completion];
//    AlertView *alertView = [AlertView currentAlertView];
//    [alertView moveToView:self.authTopViewController.view];
}


- (void)setAuthPageSubView:(UIView *)containerView{
//    containerView.backgroundColor = [UIColor redColor];
//    self.loadingContainerView.hidden = YES;
    self.oneKeyLoginBgView.frame = containerView.bounds;
    [containerView addSubview:self.oneKeyLoginBgView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.loadingContainerView.hidden = YES;
        [self removeFackAuthImageView];
    });
}

#pragma mark - OneKeyLoginBgViewDelegate

- (void)viewDidClickClose:(OneKeyLoginBgView *)view{
//    if ([self needShowBindRetainPop]){
//        [self showImgActionPopWindow];
//    } else {
//        if ([self isPresented]){
//            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOGIN_CANCEL object:nil];
//            [self addFakeAuthImageView];
//            [self dismissViewControllerAnimated:YES completion:nil];
//        } else{
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//        [[OneKeyLogin sharedOneKeyLogin] finishAuthControllerCompletion:nil];
//    }
}

- (void)viewWxButtonDidClickClicked:(OneKeyLoginBgView *)view{
//    [self addFakeAuthImageView];
//    [[OneKeyLogin sharedOneKeyLogin] finishAuthControllerCompletion:^{
//        [self wxLogin];
//    }];
}

- (void)viewPhoneButtonDidClickClicked:(OneKeyLoginBgView *)view{
    [self phoneLoginOrPhoneBind];
}

- (void)otherLoginButtonDidClickClicked:(OneKeyLoginBgView *)view{
    [self phoneLoginOrPhoneBind];
}


- (void)phoneLoginOrPhoneBind{
//    [self addFakeAuthImageView];
    
    [[OneKeyLogin sharedOneKeyLogin] finishAuthControllerCompletion:^{
        LoginViewController *vc = [[LoginViewController alloc] init];
//        vc.thirdId = self.thirdId;
//        vc.type = self.thirdId.length > 0 ? 1 : 0;
        vc.hideNavigationBar = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)addFakeAuthImageView{
    [self removeFackAuthImageView];
    UIImage *image = [self.authTopViewController.view renderImage];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = self.view.bounds;
    [self.view addSubview:imageView];
    self.fakeAuthImageView = imageView;
}

- (void)removeFackAuthImageView{
    if ([self.fakeAuthImageView isDescendantOfView:self.view]){
        [self.fakeAuthImageView removeFromSuperview];
    }
}


#pragma mark - OnekeyLoginDelegate
/** 预登录结果*/
- (void)oneKeyPreGetPhonenumberResult:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error){
            [self removeFackAuthImageView];
//            [self toggleLoginView:NO];
        }
    });
}
/** 拉起授权页结果 */
- (void)oneKeyAuthResult:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error){
            [self removeFackAuthImageView];
//            [self toggleLoginView:NO];
        } else {
            //授权页面成功后，打pv点
        }
    });
}

/** 登录结果 */
- (void)oneKeyLoginResult:(nullable NSDictionary *)data error:(nullable NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error == nil){
            [self requestOneKeyLogin:data];
        } else {
            [Toast show:error.localizedDescription];
        }
//        BOOL isBinding = self.thirdId.length > 0;
    });
}

/**
 * 发送一键登录请求
 * @param  dict 入参
 */
- (void)requestOneKeyLogin:(NSDictionary *)dict{
//    [self.loginViewModel oneKeyLogin:dict[@"token"] thirdId:self.thirdId];
}

/** 登录结果监听 */
- (void)oneKeyLoginActionListener:(NSInteger)type code:(NSInteger)code{
    if (type == 3){
        //点击一键登录
        if (code == 0){
            /** 隐私协议弹框  */
//            [PrivacyAlertUtil showAlert:YES
//                                   code:PrivacySceneCodeOnekey
//                             tailString:@"并授权销氪获得本机号码，未注册手机号登录时将自动注册"
//                                  owner:self.authTopViewController clickHandler:^{
//                [[OneKeyLogin sharedOneKeyLogin] performLogin];
//            }];
        } else {

        }
    } else if (type == 2){
        //协议勾选框
        if (code == 1){
            //选中
          
        }
    }
}



#pragma mark - lazyLoad

#pragma mark -  Lazy loading
- (OneKeyLoginBgView *)oneKeyLoginBgView{
    if (!_oneKeyLoginBgView){
        _oneKeyLoginBgView = [[OneKeyLoginBgView alloc] initWithFrame:CGRectZero];
        _oneKeyLoginBgView.delegate = self;
        _oneKeyLoginBgView.userInteractionEnabled = YES;
    }
    return _oneKeyLoginBgView;
}



#pragma mark - Properties
+ (NSDictionary *)ss_constantParams {
    return @{
//             @"pageName": [self pageName],
             @"animated": @(YES),
             @"hideNavigationBar": @(YES)
    };
}

@end
