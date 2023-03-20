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

#define kItemHeight 60

#define kAccountString @"100"
#define kPasswordString @"100"


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

@property (nonatomic, strong) UIView *accountLineView;

@property (nonatomic, strong) UITextField *passwordTextField;

@property (nonatomic, strong) UIView *passwordLineView;

@property (nonatomic, strong) UIButton *loginBtn;
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


- (void)viewDidLoad {
    [super viewDidLoad];
    
    RouterType type = self.routerParamObject.type;
    self.isPresentPage = type == RouterTypeNavigatePresent;

    self.view.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p1);
    [self loadSubViews];
    
    self.closeBtn.hidden = !self.isPresentPage;

    [self.accountTextFiled becomeFirstResponder];
}

- (void)loadSubViews {
    [self.view addSubview:self.closeBtn];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.loginContentView];

    [self.loginContentView addSubview:self.accountTextFiled];
    [self.loginContentView addSubview:self.passwordTextField];

    [self.loginContentView addSubview:self.accountLineView];
    [self.loginContentView addSubview:self.passwordLineView];

    [self.view addSubview:self.loginBtn];
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(15);
        make.top.equalTo(self.view.mas_top).offset(kPORTRAIT_SAFE_AREA_TOP_SPACE);
        make.size.mas_equalTo(CGSizeMake(80, 44));
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(kSysStatusBarHeight + 20);
    }];

    [self.loginContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(60);
        make.right.equalTo(self.view.mas_right).offset(-60);
        make.top.equalTo(self.view.mas_top).offset(200);
    }];
    //    MASAttachKeys(self.loginContentView);

    [self.accountTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.loginContentView);
        make.height.mas_equalTo(kItemHeight);
    }];

    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.accountTextFiled);
        make.top.equalTo(self.accountTextFiled.mas_bottom).offset(20);
        make.bottom.equalTo(self.loginContentView);
    }];

    [self.accountLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.accountTextFiled);
        make.bottom.equalTo(self.accountTextFiled.mas_bottom).offset(-1);
        make.height.mas_equalTo(1);
    }];

    [self.passwordLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.passwordTextField);
        make.height.mas_equalTo(1);
    }];

    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.accountTextFiled);
        make.height.mas_equalTo(kItemHeight);
        make.top.equalTo(self.loginContentView.mas_bottom).offset(80);
    }];
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
    captchaView.tag = 1234;
    [[UIApplication sharedApplication].keyWindow addSubview:captchaView];
}



#pragma mark - DXCaptchaDelegate
- (void)captchaView:(DXCaptchaView *)view
    didReceiveEvent:(DXCaptchaEventType)eventType
                arg:(NSDictionary *)dict {
    switch (eventType) {
        case DXCaptchaEventSuccess: {
            NSString *token = dict[@"token"];
           
            UIView *tempView = [[UIApplication sharedApplication].keyWindow viewWithTag:1234];
            if (tempView) {
                [tempView removeFromSuperview];
            }
            BlockSafeRun(self.completeBlock, token);

//            performBlockOnMainQueue(NO, ^{
//                [[[UIApplication sharedApplication].keyWindow viewWithTag:1234] removeFromSuperview];
//            });
            
            
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
    if (textField == self.accountTextFiled) {
    } else if (textField == self.passwordTextField) {
    }
}

#pragma mark - textFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    /** 校验输入  */
    if (textField == self.passwordTextField) {
        BOOL isNumber = [DataFormatterFunc isPureNumber:string];
        return isNumber;
    } else {
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.accountTextFiled) {
        self.accountLineView.backgroundColor = UIColorFromRGB(0x4F7AFD);
    } else if (textField == self.passwordTextField) {
        self.passwordLineView.backgroundColor = UIColorFromRGB(0x4F7AFD);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.accountTextFiled) {
        self.accountLineView.backgroundColor          = UIColorFromRGB(0xCCCCCC);
        self.accountLineView.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p10);
    } else if (textField == self.passwordTextField) {
        self.passwordLineView.backgroundColor          = UIColorFromRGB(0xCCCCCC);
        self.passwordLineView.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p10);
    }
}

- (UILabel *)getLeftLabel:(NSString *)title {
    UILabel *label           = [UILabel labelWithFrame:CGRectMake(0, 0, 80, kItemHeight) text:[NSString stringWithFormat:@"%@: ", title] textColor:UIColorFromRGB(0x111111) font:PASFont(18) textAlignment:NSTextAlignmentLeft];
    label.zh_textColorPicker = ThemePickerColorKey(ZWColorKey_p4);
    return label;
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

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel labelWithFrame:CGRectZero text:@"登录" textColor:UIColorFromRGB(0x111111) font:PASFont(20)];
    }
    return _titleLabel;
}

- (UIView *)loginContentView {
    if (!_loginContentView) {
        _loginContentView                          = [UIView viewForColor:UIColorFromRGB(0xFFFFFF) withFrame:CGRectZero];
        _loginContentView.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p1);
    }
    return _loginContentView;
}

- (UITextField *)accountTextFiled {
    if (!_accountTextFiled) {
        _accountTextFiled                 = [[UITextField alloc] initWithFrame:CGRectZero];
        _accountTextFiled.delegate        = self;
        _accountTextFiled.leftView        = [self getLeftLabel:@"账号"];
        _accountTextFiled.leftViewMode    = UITextFieldViewModeAlways;
        _accountTextFiled.placeholder     = @"请输入账号";
        _accountTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        _accountTextFiled.font            = PASFont(18);
        @pas_weakify_self
            [_accountTextFiled zh_themeUpdateCallback:^(id _Nonnull target) {
                @pas_strongify_self
                    self.accountTextFiled.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.accountTextFiled.placeholder attributes:@{NSForegroundColorAttributeName: ThemePickerColorKey(ZWColorKey_p7).color}];
                self.accountTextFiled.zh_backgroundColorPicker  = ThemePickerColorKey(ZWColorKey_p1);
                self.accountTextFiled.textColor                 = ThemePickerColorKey(ZWColorKey_p4).color;
            }];
        [_accountTextFiled addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _accountTextFiled;
}

- (UITextField *)passwordTextField {
    if (!_passwordTextField) {
        _passwordTextField                 = [[UITextField alloc] initWithFrame:CGRectZero];
        _passwordTextField.delegate        = self;
        _passwordTextField.leftView        = [self getLeftLabel:@"密码"];
        _passwordTextField.leftViewMode    = UITextFieldViewModeAlways;
        _passwordTextField.keyboardType    = UIKeyboardTypeNumberPad;
        _passwordTextField.placeholder     = @"请输入密码";
        _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _passwordTextField.font            = PASFont(18);
        @pas_weakify_self
            [_accountTextFiled zh_themeUpdateCallback:^(id _Nonnull target) {
                @pas_strongify_self
                    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordTextField.placeholder attributes:@{NSForegroundColorAttributeName: ThemePickerColorKey(ZWColorKey_p7).color}];
                self.passwordTextField.zh_backgroundColorPicker  = ThemePickerColorKey(ZWColorKey_p1);
                self.passwordTextField.textColor                 = ThemePickerColorKey(ZWColorKey_p4).color;
            }];
        [_passwordTextField addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _passwordTextField;
}

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        @pas_weakify_self
            _loginBtn             = [UIButton buttonWithFrame:CGRectZero title:@"登录" font:PASFont(22) titleColor:UIColorFromRGB(0xFFFFFF) block:^{
                @pas_strongify_self
                    [self loginAction];
            }];
        _loginBtn.backgroundColor = UIColorFromRGB(0x4F7AFD);
        [_loginBtn setCornerRadius:8];
    }
    return _loginBtn;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        @pas_weakify_self
        _closeBtn = [UIButton buttonWithFrame:CGRectZero title:@"" font:PASFont(22) titleColor:UIColorFromRGB(0xFFFFFF) block:^{
            @pas_strongify_self
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
        [_closeBtn setImage:[UIImage imageNamed:@"top_icon_close"] forState:UIControlStateNormal];
        _closeBtn.hidden = YES;
    }
    return _closeBtn;
}

- (UIView *)accountLineView {
    if (!_accountLineView) {
        _accountLineView                          = [UIView viewForColor:UIColorFromRGB(0xCCCCCC) withFrame:CGRectZero];
        _accountLineView.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p10);
    }
    return _accountLineView;
}

- (UIView *)passwordLineView {
    if (!_passwordLineView) {
        _passwordLineView                          = [UIView viewForColor:UIColorFromRGB(0xCCCCCC) withFrame:CGRectZero];
        _passwordLineView.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p10);
    }
    return _passwordLineView;
}

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
