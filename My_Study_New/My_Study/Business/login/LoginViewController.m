//
//  LoginViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "LoginViewController.h"
#import "ZWUserAccountManager.h"
#import "Toast.h"

#define kItemHeight             60

#define kAccountString              @"100"
#define kPasswordString             @"100"


@interface LoginViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *loginContentView;

@property (nonatomic, strong) UITextField *accountTextFiled;

@property (nonatomic, strong) UIView *accountLineView;

@property (nonatomic, strong) UITextField *passwordTextField;

@property (nonatomic, strong) UIView *passwordLineView;

@property (nonatomic, strong) UIButton *loginBtn;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    
    [self.accountTextFiled becomeFirstResponder];
    
}

- (void)loadSubViews
{
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.loginContentView];
    
    [self.loginContentView addSubview:self.accountTextFiled];
    [self.loginContentView addSubview:self.passwordTextField];
    
    [self.loginContentView addSubview:self.accountLineView];
    [self.loginContentView addSubview:self.passwordLineView];

    [self.view addSubview:self.loginBtn];
    
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


/**
 *  登录按钮点击
 */
- (void)loginAction
{
    NSString *showMsg = @"";
    NSString *accountStr = self.accountTextFiled.text;
    NSString *passwordStr = self.passwordTextField.text;
    if (accountStr.length == 0) {
        showMsg = @"请输入账号!";
    } else if (passwordStr.length == 0) {
        showMsg = @"请输入密码!";
    } else if ([accountStr isEqualToString:kAccountString]
               && [passwordStr isEqualToString:kPasswordString]) {
        /** 账号&密码正确  */
        ZWUserInfoModel *infoModel = [ZWUserInfoModel new];
        infoModel.pid = [kAccountString longLongValue];
        infoModel.userWid = [kPasswordString longLongValue];;
        [ZWUserAccountManager sharedZWUserAccountManager].currentUserInfo = infoModel;
        BlockSafeRun(self.loginCompleted);
    } else {
        showMsg = @"账号或密码输入有误!!!";
    }
    
    if (ValidString(showMsg)) {
        [Toast show:showMsg];
    }
}


- (void)valueChange:(UITextField *)textField
{
    if (textField == self.accountTextFiled) {
        
    } else if (textField == self.passwordTextField) {
        
    }
}


#pragma mark - textFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    /** 校验输入  */
    if (textField == self.passwordTextField) {
        BOOL isNumber = [DataFormatterFunc isPureNumber:string];
        return isNumber;
    } else{
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.accountTextFiled) {
        self.accountLineView.backgroundColor = UIColorFromRGB(0x4F7AFD);
    } else if (textField == self.passwordTextField) {
        self.passwordLineView.backgroundColor = UIColorFromRGB(0x4F7AFD);
    }
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.accountTextFiled) {
        self.accountLineView.backgroundColor = UIColorFromRGB(0xCCCCCC);
    } else if (textField == self.passwordTextField) {
        self.passwordLineView.backgroundColor = UIColorFromRGB(0xCCCCCC);
    }
}


- (UILabel *)getLeftLabel:(NSString *)title
{
    UILabel *label = [UILabel labelWithFrame:CGRectMake(0, 0, 80, kItemHeight) text:[NSString stringWithFormat:@"%@: ", title] textColor:UIColorFromRGB(0x111111) font:PASFont(18) textAlignment:NSTextAlignmentLeft];
    return label;
}


#pragma mark - lazyLoad

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel labelWithFrame:CGRectZero text:@"登录" textColor:UIColorFromRGB(0x111111) font:PASFont(20)];
    }
    return _titleLabel;
}

- (UIView *)loginContentView
{
    if (!_loginContentView) {
        _loginContentView = [UIView viewForColor:UIColorFromRGB(0xFFFFFF) withFrame:CGRectZero];
    }
    return _loginContentView;
}

- (UITextField *)accountTextFiled
{
    if (!_accountTextFiled) {
        _accountTextFiled = [[UITextField alloc] initWithFrame:CGRectZero];
        _accountTextFiled.delegate = self;
        _accountTextFiled.leftView = [self getLeftLabel:@"账号"];
        _accountTextFiled.leftViewMode = UITextFieldViewModeAlways;
        _accountTextFiled.placeholder = @"请输入账号";
        _accountTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        _accountTextFiled.font = PASFont(18);
        [_accountTextFiled addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _accountTextFiled;
}

- (UITextField *)passwordTextField
{
    if (!_passwordTextField) {
        _passwordTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _passwordTextField.delegate = self;
        _passwordTextField.leftView = [self getLeftLabel:@"密码"];
        _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
        _passwordTextField.keyboardType = UIKeyboardTypeNumberPad;
        _passwordTextField.placeholder = @"请输入密码";
        _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _passwordTextField.font = PASFont(18);
        [_passwordTextField addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _passwordTextField;
}


- (UIButton *)loginBtn
{
    if (!_loginBtn) {
        @pas_weakify_self
        _loginBtn = [UIButton buttonWithFrame:CGRectZero title:@"登录" font:PASFont(22) titleColor:UIColorFromRGB(0xFFFFFF) block:^{
            @pas_strongify_self
            [self loginAction];
        }];
        _loginBtn.backgroundColor = UIColorFromRGB(0x4F7AFD);
        [_loginBtn setCornerRadius:8];
    }
    return _loginBtn;
}

- (UIView *)accountLineView
{
    if (!_accountLineView) {
        _accountLineView = [UIView viewForColor:UIColorFromRGB(0xCCCCCC) withFrame:CGRectZero];
    }
    return _accountLineView;
}

- (UIView *)passwordLineView
{
    if (!_passwordLineView) {
        _passwordLineView = [UIView viewForColor:UIColorFromRGB(0xCCCCCC) withFrame:CGRectZero];
    }
    return _passwordLineView;
}


@end
