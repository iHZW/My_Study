//
//  OneKeyLogin.m
//  My_Study
//
//  Created by Zhiwei Han on 2023/1/17.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "OneKeyLogin.h"
#import "UIColor+Ext.h"
#import "UIDevice+Tool.h"
#import "UIFont+Tool.h"
#import "UIView+SVG.h"
#import <CL_ShanYanSDK/CL_ShanYanSDK.h>

#define kAppName                        @"企业之家"

@interface OneKeyLogin () <CLShanYanSDKManagerDelegate>
/** 闪现appId  */
@property (nonatomic, copy) NSString *appId;
/** 成功拉起授权页  */
@property (nonatomic, assign) BOOL successFetchAuthPage;
/** 登录按钮  */
@property (nonatomic, strong) UIButton *loginButton;

@end

@implementation OneKeyLogin
DEFINE_SINGLETON_T_FOR_CLASS(OneKeyLogin)

- (void)config:(NSString *)appId {
    self.appId = appId;
    [CLShanYanSDKManager initWithAppId:appId complete:^(CLCompleteResult *_Nonnull completeResult){

    }];

    [CLShanYanSDKManager setCLShanYanSDKManagerDelegate:self];
}

- (void)clShanYanActionListener:(NSInteger)type
                           code:(NSInteger)code
                        message:(NSString *_Nullable)message {
    if ([self.delegate respondsToSelector:@selector(oneKeyLoginActionListener:code:)]) {
        [self.delegate oneKeyLoginActionListener:type code:code];
    }
}

- (void)clShanYanSDKManagerAuthPageCompleteInit:(UIViewController *_Nonnull)authPageVC
                                 currentTelecom:(NSString *_Nullable)telecom
                                         object:(NSObject *_Nullable)object
                                       userInfo:(NSDictionary *_Nullable)userInfo {
    UIButton *loginButton = userInfo[@"loginBtn"];
    self.loginButton      = loginButton;
}

- (void)performLogin {
    [CLShanYanSDKManager setCheckBoxValue:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.04 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    });
}

// 预取号
- (void)preGetPhonenumber {
    @weakify(self)
    [CLShanYanSDKManager preGetPhonenumber:^(CLCompleteResult *_Nonnull completeResult) {
        @strongify(self) if ([self.delegate respondsToSelector:@selector(oneKeyPreGetPhonenumberResult:)]) {
            [self.delegate oneKeyPreGetPhonenumberResult:completeResult.error];
        }
    }];
}

- (UIViewController *)baseViewController {
    return self.viewController;
}

- (void)quickAuthLogin:(NSString *)loginButtonText {
    self.loginButton               = nil;
    CLUIConfigure *baseUIConfigure = [self loginUIConfiguration];
    baseUIConfigure                = [self configUIStyle:baseUIConfigure];
    baseUIConfigure.clLoginBtnText = loginButtonText;
    baseUIConfigure.viewController = [self baseViewController];

    @weakify(self)
    [CLShanYanSDKManager quickAuthLoginWithConfigure:baseUIConfigure openLoginAuthListener:^(CLCompleteResult *_Nonnull completeResult) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            // 拉起授权页成功，失败
            self.successFetchAuthPage = completeResult.error == nil;
            if ([self.delegate respondsToSelector:@selector(oneKeyAuthResult:)]) {
                [self.delegate oneKeyAuthResult:completeResult.error];
            }
        });
    } oneKeyLoginListener:^(CLCompleteResult *_Nonnull completeResult) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [CLShanYanSDKManager hideLoading];
            if (completeResult.error) {
                // 一键登录失败
                NSLog(@"oneKeyLoginListener:%@", completeResult.error.description);
                // 提示：错误无需提示给用户，可以在用户无感知的状态下直接切换登录方式
                if (completeResult.code == 1011) {
                    // 用户取消登录（点返回）
                    // 处理建议：如无特殊需求可不做处理，仅作为交互状态回调，此时已经回到当前用户自己的页面
                    // 点击sdk自带的返回，无论是否设置手动销毁，授权页面都会强制关闭
                } else {
                    // 处理建议：其他错误代码表示闪验通道无法继续，可以统一走开发者自己的其他登录方式，也可以对不同的错误单独处理
                    // 关闭授权页，如果授权页还未拉起，此调用不会关闭当前用户vc，即不执行任何代码
                    //[self finishAuthControllerCompletion:nil];
                }
                if ([self.delegate respondsToSelector:@selector(oneKeyLoginResult:error:)]) {
                    [self.delegate oneKeyLoginResult:nil error:completeResult.error];
                }
            } else {
                // 一键登录获取Token成功
                if ([self.delegate respondsToSelector:@selector(oneKeyLoginResult:error:)]) {
                    [self.delegate oneKeyLoginResult:completeResult.data error:nil];
                }
                NSLog(@"oneKeyLoginListener");
                // SDK成功获取到Token
                /** token置换手机号
                 code
                 */
            }
        });
    }];
}

#pragma mark - UI

- (CLUIConfigure *)loginUIConfiguration {
    CLUIConfigure *baseUIConfigure = [[CLUIConfigure alloc] init];

    baseUIConfigure.clNavigationBarHidden = @(YES);

    baseUIConfigure.clAppPrivacyTextAlignment       = @(NSTextAlignmentLeft);
    baseUIConfigure.clAppPrivacyTextFont            = [UIFont fontWithName:[UIFont eh_regularFontName] size:12];
    baseUIConfigure.clAppPrivacyColor               = @[[UIColor colorFromHexCode:@"#999999"], [UIColor colorFromHexCode:@"4F7AFD"]];
    baseUIConfigure.clAppPrivacyLineSpacing         = @(2);
    baseUIConfigure.clAppPrivacyFirst               = @[[NSString stringWithFormat:@"《%@用户协议》", kAppName], [NSURL URLWithString:[[self class] userAgreementURLString]]];
    baseUIConfigure.clAppPrivacySecond              = @[[NSString stringWithFormat:@"《%@个人信息保护政策》", kAppName], [NSURL URLWithString:[[self class] privacyURLString]]];
    baseUIConfigure.clAppPrivacyPunctuationMarks    = @(YES);
    baseUIConfigure.clOperatorPrivacyAtLast         = @(YES);
    baseUIConfigure.clAppPrivacyNormalDesTextSecond = @"、";
    baseUIConfigure.clAppPrivacyNormalDesTextThird  = @"和";
    if (self.isBinding) {
        baseUIConfigure.clAppPrivacyNormalDesTextLast = [NSString stringWithFormat:@"并授权%@获得本机号码", kAppName];
    } else {
        baseUIConfigure.clAppPrivacyNormalDesTextLast = [NSString stringWithFormat:@"并授权%@获得本机号码，未注册手机号登录时将自动注册", kAppName];
    }

    baseUIConfigure.clCheckBoxHidden          = @(NO);
    baseUIConfigure.clCheckBoxValue           = @(NO);
    baseUIConfigure.clCheckBoxTipDisable      = @(YES);
    baseUIConfigure.clCheckBoxUncheckedImage  = [UIImage svg_imageNamed:@"icon_checkbox_default" scaleToFitInside:CGSizeMake(24, 24)];
    baseUIConfigure.clCheckBoxCheckedImage    = [UIImage svg_imageNamed:@"icon_checkbox_active" scaleToFitInside:CGSizeMake(24, 24)];
    baseUIConfigure.clCheckBoxImageEdgeInsets = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(-3, -4, 3, 4)];
    baseUIConfigure.manualDismiss             = @(YES);

    baseUIConfigure.clSloganTextColor = [UIColor colorFromHexCode:@"#999999"];
    baseUIConfigure.clSloganTextFont  = [UIFont fontWithName:[UIFont eh_regularFontName] size:12];

    baseUIConfigure.clPhoneNumberFont  = [UIFont fontWithName:[UIFont eh_midiumFontName] size:26];
    baseUIConfigure.clPhoneNumberColor = [UIColor colorFromHexCode:@"#333333"];
    return baseUIConfigure;
}

#pragma mark - 横竖屏及旋转方向设置
- (CLUIConfigure *)configUIStyle:(CLUIConfigure *)inputConfigure {
    // 登录和绑定两个页面间距不一样
    BOOL isBinding = self.isBinding;

    CGFloat screenScale                = 1;
    CGFloat screenWidth_Portrait       = 0;
    CGFloat screenHeight_Portrait      = 0;
    CGFloat screenWidth_Landscape      = 0;
    CGFloat screenHeight_Landscape     = 0;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        screenWidth_Portrait   = UIScreen.mainScreen.bounds.size.width;
        screenHeight_Portrait  = UIScreen.mainScreen.bounds.size.height;
        screenWidth_Landscape  = UIScreen.mainScreen.bounds.size.height;
        screenHeight_Landscape = UIScreen.mainScreen.bounds.size.width;
    } else {
        screenWidth_Portrait  = UIScreen.mainScreen.bounds.size.height;
        screenHeight_Portrait = UIScreen.mainScreen.bounds.size.width;
        screenWidth_Landscape = UIScreen.mainScreen.bounds.size.width;
    }
    CLUIConfigure *baseUIConfigure = inputConfigure;

    // layout 布局
    // 布局-竖屏
    CLOrientationLayOut *clOrientationLayOutPortrait = [CLOrientationLayOut new];

    // 窗口中心
    clOrientationLayOutPortrait.clAuthWindowOrientationCenter = [NSValue valueWithCGPoint:CGPointMake(screenWidth_Portrait * 0.5, screenHeight_Portrait * 0.5)];
    clOrientationLayOutPortrait.clAuthWindowOrientationWidth  = @(screenWidth_Portrait);
    clOrientationLayOutPortrait.clAuthWindowOrientationHeight = @(screenHeight_Portrait);

    //    CGFloat
    CGFloat distance = 0; // [rulerMake(@286, @286, @286, @286, @286, @286, @286).value floatValue];

    if (isBinding) {
        if ([[UIDevice currentDevice] isIPhoneXSeries]) {
            distance = 161;
        } else {
            distance = 106;
        }
    } else {
        if ([[UIDevice currentDevice] isIPhoneXSeries]) {
            distance = 156;
        } else {
            distance = 160;
        }
    }
    // https://stackoverflow.com/questions/46298427/safe-area-layout-guides-in-xib-files-ios-10
    // iOS 10 上 safeArea 会忽略掉 statusBar； 因此这边 在 < iOS 11 ,让导航栏高度 0
    CGFloat statusBarHeight = kSysStatusBarHeight;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 11) {
        statusBarHeight = 0;
    }

    clOrientationLayOutPortrait.clLayoutPhoneTop = @(distance + statusBarHeight + 40);
    //    clOrientationLayOutPortrait.clLayoutPhoneCenterY = @(-100*screenScale);
    clOrientationLayOutPortrait.clLayoutPhoneLeft   = @(32 * screenScale);
    clOrientationLayOutPortrait.clLayoutPhoneRight  = @(-32 * screenScale);
    clOrientationLayOutPortrait.clLayoutPhoneHeight = @(23 * screenScale);

    // 闪验slogan,(该服务由中国移动提供)
    clOrientationLayOutPortrait.clLayoutSloganLeft   = @(32 * screenScale);
    clOrientationLayOutPortrait.clLayoutSloganRight  = @(-32 * screenScale);
    clOrientationLayOutPortrait.clLayoutSloganHeight = @(16 * screenScale);
    clOrientationLayOutPortrait.clLayoutSloganTop    = @(clOrientationLayOutPortrait.clLayoutPhoneTop.floatValue + 37);

    //    clOrientationLayOutPortrait.clLayoutLoginBtnCenterY= @(clOrientationLayOutPortrait.clLayoutPhoneCenterY.floatValue + clOrientationLayOutPortrait.clLayoutPhoneHeight.floatValue*0.5*screenScale + 22 + 25);
    clOrientationLayOutPortrait.clLayoutLoginBtnTop    = @(clOrientationLayOutPortrait.clLayoutPhoneTop.floatValue + clOrientationLayOutPortrait.clLayoutPhoneHeight.floatValue + 45);
    clOrientationLayOutPortrait.clLayoutLoginBtnHeight = @(50 * screenScale);
    clOrientationLayOutPortrait.clLayoutLoginBtnLeft   = @(32 * screenScale);
    clOrientationLayOutPortrait.clLayoutLoginBtnRight  = @(-32 * screenScale);

    // 隐私协议
    clOrientationLayOutPortrait.clLayoutAppPrivacyLeft  = @((32 + 22) * screenScale);
    clOrientationLayOutPortrait.clLayoutAppPrivacyRight = @(-32 * screenScale);
    if (isBinding) {
        clOrientationLayOutPortrait.clLayoutAppPrivacyTop = @(clOrientationLayOutPortrait.clLayoutLoginBtnTop.floatValue + 50 * screenScale + 24 + 62);
    } else {
        clOrientationLayOutPortrait.clLayoutAppPrivacyTop = @(clOrientationLayOutPortrait.clLayoutLoginBtnTop.floatValue + 50 * screenScale + 24);
    }

    baseUIConfigure.clOrientationLayOutPortrait      = clOrientationLayOutPortrait;
    baseUIConfigure.clAuthTypeUseWindow              = @(true);
    baseUIConfigure.clAuthWindowModalTransitionStyle = @(UIModalTransitionStyleCrossDissolve);

    baseUIConfigure.clPhoneNumberTextAlignment = @(NSTextAlignmentCenter);

    baseUIConfigure.clLoginBtnBgColor      = [UIColor colorFromHexCode:@"4F7AFDFF"];
    baseUIConfigure.clLoginBtnTextFont     = [UIFont eh_midiumSmallTitleFont];
    baseUIConfigure.clLoginBtnTextColor    = [UIColor whiteColor];
    baseUIConfigure.clLoginBtnCornerRadius = @4;

    baseUIConfigure.clShanYanSloganHidden = @(YES);

    return baseUIConfigure;
}

- (void)finishAuthControllerCompletion:(dispatch_block_t)completeBlock {
    if (self.successFetchAuthPage) {
        [CLShanYanSDKManager finishAuthControllerCompletion:^{
            BlockSafeRun(completeBlock);
        }];
        self.successFetchAuthPage = NO;
    } else {
        BlockSafeRun(completeBlock);
    }
}

+ (NSString *)serverHost {
    return @"http://localhost";
}

+ (NSString *)userAgreementURLString {
    NSString *host = [self serverHost];
    long long t    = [[NSDate date] timeIntervalSince1970];
    NSString *url  = [NSString stringWithFormat:@"%@/system-setting/index.html#/system-setting/user-agreement?scene=1&t=%lld", host, t];
    return url;
}

+ (NSString *)privacyURLString {
    NSString *host = [self serverHost];
    long long t    = [[NSDate date] timeIntervalSince1970];
    NSString *url  = [NSString stringWithFormat:@"%@/system-setting/index.html#/system-setting/privacy-policy?scene=1&t=%lld", host, t];
    return url;
}

+ (NSString *)inAppUserAgreementURLString {
    NSString *url = @"/h5/system-setting/user-agreement";
    return url;
}

+ (NSString *)inAppPrivacyURLString {
    NSString *url = @"/h5/system-setting/privacy-policy";
    return url;
}

@end
