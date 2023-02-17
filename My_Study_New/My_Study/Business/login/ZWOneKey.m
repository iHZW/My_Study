//
//  ZWOneKey.m
//  My_Study
//
//  Created by Zhiwei Han on 2023/2/4.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "ZWOneKey.h"
#import <CL_ShanYanSDK/CL_ShanYanSDK.h>
//#import <Chameleon.h>
//#import <Lottie.h>
#import "UIColor+Tools.h"
#import "Toast.h"
#import "Masonry/Masonry.h"


#define randomDymcialColor   [UIColor randomColor]

@implementation ZWOneKey


static ZWOneKey * _zwOneKey;
+(instancetype)staticInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _zwOneKey = [[ZWOneKey alloc]init];
        [CLShanYanSDKManager initWithAppId:@"pPumQPFj" complete:^(CLCompleteResult * _Nonnull completeResult) {
        
        }];
        
        [CLShanYanSDKManager preGetPhonenumber:^(CLCompleteResult * _Nonnull completeResult) {
            
        }];
    });
    return _zwOneKey;
}

+(CLUIConfigure*)shanYanUIConfigureMakerStyle0{
    
    UIColor * light_foreground = [UIColor colorWithRed:0.451 green:0.486 blue:1.000 alpha:1];
    UIColor * dark_foreground = [UIColor colorWithRed:0.773 green:0.792 blue:1.000 alpha:1];

    UIColor * light_background = [UIColor colorWithRed:0.651 green:0.679 blue:0.809 alpha:1];
    UIColor * dark_background = [UIColor colorWithRed:0.146 green:0.140 blue:0.307 alpha:1];
    
    CLUIConfigure * baseUIConfigure = [[CLUIConfigure alloc]init];
    
    baseUIConfigure.manualDismiss = @(YES);
    
    baseUIConfigure.shouldAutorotate = @(YES);
    baseUIConfigure.supportedInterfaceOrientations = @(UIInterfaceOrientationMaskAll);
    
//    baseUIConfigure.clAuthWindowModalPresentationStyle = @(UIModalPresentationCustom);
//    baseUIConfigure.clAuthWindowModalTransitionStyle = @(UIModalTransitionStyleCrossDissolve);
//    baseUIConfigure.clAuthWindowDismissAnimate = @(NO);

    if (@available(iOS 12.0, *)) {
        baseUIConfigure.clAuthWindowOverrideUserInterfaceStyle = @(UIUserInterfaceStyleUnspecified);
    }
    
    //    baseUIConfigure.clBackgroundColor = UIColor.orangeColor;
    baseUIConfigure.clBackgroundImg = [UIImage imageNamed:@"eb9a0dae18491990a43fe02832d3cafa"];
//    baseUIConfigure.clNavigationBarHidden = @(YES);
    baseUIConfigure.clNavigationBackgroundClear = @(NO);
//    baseUIConfigure.clNavigationTintColor = [UIColor generateDynamicColor:light_foreground darkColor:dark_foreground];
    baseUIConfigure.clNavigationBarTintColor = randomDymcialColor;
    baseUIConfigure.clNavigationBottomLineHidden = @(NO);
    baseUIConfigure.clNavigationShadowImage = [UIImage imageNamed:@"line-2"];
    baseUIConfigure.clNavigationAttributesTitleText = [[NSAttributedString alloc]initWithString:@"闪验授权页" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName:randomDymcialColor}];
    
//    baseUIConfigure.clNavBackBtnAlimentRight = @(YES);
    
    UIBarButtonItem * leftControl = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"setting"] style:UIBarButtonItemStylePlain target:self action:@selector(leftControlClick:)];
    leftControl.tintColor = randomDymcialColor;
    UIBarButtonItem * rightControl = [[UIBarButtonItem alloc]initWithTitle:@"右测试" style:UIBarButtonItemStylePlain target:self action:@selector(rightControlClick:)];
    rightControl.tintColor = randomDymcialColor;
    baseUIConfigure.clNavigationLeftControl = leftControl;
    baseUIConfigure.clNavigationRightControl = rightControl;

    if (@available(iOS 13.0, *)) {
        baseUIConfigure.clPreferredStatusBarStyle = @(UIStatusBarStyleLightContent);
    } else {
        baseUIConfigure.clPreferredStatusBarStyle = @(UIStatusBarStyleDefault);
    }
    baseUIConfigure.clPrefersStatusBarHidden = @(NO);
//    baseUIConfigure.clNavigationBarStyle =  @(UIBarStyleDefault);
    
    baseUIConfigure.clLogoImage = [UIImage imageNamed:@"shanyanLogo1"];
//    baseUIConfigure.clLogoHiden = @(YES);
    baseUIConfigure.clLogoCornerRadius = @(10);
    
    baseUIConfigure.clPhoneNumberColor = randomDymcialColor;
    baseUIConfigure.clPhoneNumberFont = [UIFont boldSystemFontOfSize:30];
    baseUIConfigure.clPhoneNumberTextAlignment = @(NSTextAlignmentCenter);
    
//    baseUIConfigure.clAppPrivacyWebAttributesTitle = [[NSAttributedString alloc]initWithString:@"闪验运营商协议测试文字" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName:[UIColor generateDynamicColor:UIColor.flatLimeColor darkColor:UIColor.flatGreenColorDark]}];
    
    baseUIConfigure.clAppPrivacyColor = @[randomDymcialColor,randomDymcialColor];
    baseUIConfigure.clAppPrivacyTextFont = [UIFont boldSystemFontOfSize:14];
    baseUIConfigure.clAppPrivacyTextAlignment =  @(NSTextAlignmentLeft);
    baseUIConfigure.clAppPrivacyPunctuationMarks = @(YES);
    baseUIConfigure.clAppPrivacyLineSpacing = @(5);
//    baseUIConfigure.clAppPrivacyNeedSizeToFit = @(YES);
    //失效
    baseUIConfigure.clAppPrivacyTextContainerInset = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(20, 35, 0, 15)];
    baseUIConfigure.clAppPrivacyAbbreviatedName = @"🐶app";
        
    baseUIConfigure.clAppPrivacyNormalDesTextFirst = @"AA😈";
    baseUIConfigure.clAppPrivacyNormalDesTextSecond = @"BB😤";
    baseUIConfigure.clAppPrivacyNormalDesTextThird = @"CC😱";
    baseUIConfigure.clAppPrivacyNormalDesTextFourth = @"DD😡";
    baseUIConfigure.clAppPrivacyNormalDesTextLast = @"FF👽";

    baseUIConfigure.clOperatorPrivacyAtLast = @(YES);
    
//    baseUIConfigure.clAppPrivacyWebAttributesTitle = [[NSAttributedString alloc]initWithString:@"我的自定义标题" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName:randomDymcialColor}];
    baseUIConfigure.clAppPrivacyWebNormalAttributesTitle = [[NSAttributedString alloc]initWithString:@"我的自定义标题" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName:randomDymcialColor}];
    baseUIConfigure.clAppPrivacyWebTitleList = @[@"🍓🍞🍠🍆自定义协议XXX🍋🍉",@"🍍🍏🍑自定义协议YYY🍅🍟",@"🍕🍔🍳🍚自定义协议ZZZ🍘🍪🍧"];
    baseUIConfigure.clAppPrivacyWebAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName:randomDymcialColor};

    baseUIConfigure.clAppPrivacyWebBackBtnImage = [UIImage imageNamed:@"back-0"];
    
    baseUIConfigure.clAppPrivacyWebNavigationTintColor = randomDymcialColor;
    baseUIConfigure.clAppPrivacyWebNavigationBarTintColor = randomDymcialColor;
    baseUIConfigure.clAppPrivacyWebNavigationBackgroundImage = [UIImage imageNamed:@"label-2"];
    
//    baseUIConfigure.clAppPrivacyWebPreferredStatusBarStyle = @(UIStatusBarStyleLightContent);

    baseUIConfigure.clAppPrivacyFirst = @[@"用户协议1",[NSURL URLWithString:@"https://m.baidu.com"]];
    baseUIConfigure.clAppPrivacySecond = @[@"用户协议2",@"https://m.toutiao.com"];
    baseUIConfigure.clAppPrivacyThird = @[@"用户协议3",[[NSBundle mainBundle] pathForResource:@"ShanYanIndex" ofType:@"html"]];
    baseUIConfigure.clPrivacyShowUnderline = @(YES);
    
    baseUIConfigure.clLoginBtnBgColor = randomDymcialColor;
    baseUIConfigure.clLoginBtnBorderColor = randomDymcialColor;
    baseUIConfigure.clLoginBtnTextColor = randomDymcialColor;
    baseUIConfigure.clLoginBtnBorderWidth = @(2);
    baseUIConfigure.clLoginBtnCornerRadius = @(5);
    
    baseUIConfigure.clLoginBtnNormalBgImage = [UIImage imageNamed:@"bg-1"];
    baseUIConfigure.clLoginBtnHightLightBgImage = [UIImage imageNamed:@"bg-4"];
    baseUIConfigure.clLoginBtnDisabledBgImage = [UIImage imageNamed:@"bg-6"];

    baseUIConfigure.clSloganTextFont = [UIFont boldSystemFontOfSize:12];
    baseUIConfigure.clSloganTextColor = randomDymcialColor;
    baseUIConfigure.clSlogaTextAlignment = @(NSTextAlignmentCenter);
    
    baseUIConfigure.clShanYanSloganHidden = @(NO);
    baseUIConfigure.clShanYanSloganTextFont = [UIFont boldSystemFontOfSize:12];
    baseUIConfigure.clShanYanSloganTextColor = randomDymcialColor;
    baseUIConfigure.clShanYanSloganTextAlignment = @(NSTextAlignmentCenter);
    
    baseUIConfigure.clCheckBoxValue = @(NO);
    baseUIConfigure.clCheckBoxSize = [NSValue valueWithCGSize:CGSizeMake(40, 40)];
    baseUIConfigure.clCheckBoxCheckedImage = [UIImage imageNamed:@"checkbox-multiple-ma"];
    baseUIConfigure.clCheckBoxUncheckedImage = [UIImage imageNamed:@"checkbox-multiple-bl"];
//    baseUIConfigure.clCheckBoxVerticalAlignmentToAppPrivacyTop = @(YES);
    baseUIConfigure.clCheckBoxVerticalAlignmentToAppPrivacyCenterY = @(YES);
    baseUIConfigure.clCheckBoxImageEdgeInsets = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(5, 8, 11, 8)];
    baseUIConfigure.clCheckBoxTipMsg = @"请阅读并同意📃📋🔗📜🔓📝";
    baseUIConfigure.checkBoxTipView = ^(UIView * _Nonnull containerView) {
        
        [Toast show:@"📃📋🔗📜🔓📝请同意并勾选协议"];
//        [SVProgressHUD showInfoWithStatus:@"📃📋🔗📜🔓📝请同意并勾选协议"];
    };
//    baseUIConfigure.clCheckBoxTipDisable = @(NO);
    
    
    //自定义一键登录点击后的loading
    baseUIConfigure.clLoadingSize = [NSValue valueWithCGSize:CGSizeMake(200, 200)];
    baseUIConfigure.clLoadingTintColor = randomDymcialColor;
    baseUIConfigure.clLoadingBackgroundColor = randomDymcialColor;
    baseUIConfigure.clLoadingIndicatorStyle = @(UIActivityIndicatorViewStyleWhiteLarge);
    baseUIConfigure.clLoadingCornerRadius = @(100);
    baseUIConfigure.loadingView = ^(UIView * _Nonnull containerView) {
//        LOTAnimationView *animation = [LOTAnimationView animationNamed:@"LottieLogo2" inBundle:[NSBundle mainBundle]];
//        [containerView addSubview:animation];
//        animation.backgroundColor = randomDymcialColor;
//        animation.layer.cornerRadius = 20;
//        [animation mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.mas_equalTo(containerView);
//            make.size.mas_equalTo(CGSizeMake(100, 80));
//        }];
//        [animation playWithCompletion:^(BOOL animationFinished) {
//            [animation removeFromSuperview];
//        }];
    };
    
    //添加授权页自定义控件
    UIButton * custom0 = [[UIButton alloc]init];
    custom0.layer.cornerRadius = 10;
    custom0.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [custom0 setTitle:@"自定义按钮0" forState:(UIControlStateNormal)];
    [custom0 addTarget:self action:@selector(customButton0Click:) forControlEvents:UIControlEventTouchUpInside];
    [custom0 setTitleColor:randomDymcialColor forState:(UIControlStateNormal)];
    custom0.backgroundColor = randomDymcialColor;
    
    UIButton * custom1 = [[UIButton alloc]init];
    custom1.layer.cornerRadius = 10;
    custom1.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [custom1 setTitle:@"自定义按钮1" forState:(UIControlStateNormal)];
    [custom1 addTarget:self action:@selector(customButton1Click:) forControlEvents:UIControlEventTouchUpInside];
    [custom1 setTitleColor:randomDymcialColor forState:(UIControlStateNormal)];
    custom1.backgroundColor = randomDymcialColor;

    UIImageView * custom_img_0 = [[UIImageView alloc]init];
    UIImageView * custom_img_1 = [[UIImageView alloc]init];
    UIImageView * custom_img_2 = [[UIImageView alloc]init];
    custom_img_0.layer.cornerRadius = 10;
    custom_img_1.layer.cornerRadius = 10;
    custom_img_2.layer.cornerRadius = 10;
    custom_img_0.image = [UIImage imageNamed:@"电信"];
    custom_img_1.image = [UIImage imageNamed:@"移动"];
    custom_img_2.image = [UIImage imageNamed:@"联通"];
    
    
    CAEmitterLayer * fireEmitter = [[self class] generatefileAnimatorStyle0];
    
    baseUIConfigure.customAreaView = ^(UIView * _Nonnull customAreaView) {
       
        [customAreaView addSubview:custom0];
        [custom0 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(-50);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(50);
            make.centerY.mas_equalTo(60);
        }];
        
        [customAreaView addSubview:custom1];
        [custom1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(50);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(50);
            make.centerY.mas_equalTo(60);
        }];
        
        [customAreaView addSubview:custom_img_0];
        [customAreaView addSubview:custom_img_1];
        [customAreaView addSubview:custom_img_2];

        [custom_img_1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.width.height.mas_equalTo(50);
            make.top.mas_equalTo(custom1.mas_bottom).offset(20);
        }];
        [custom_img_0 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.centerY.mas_equalTo(custom_img_1);
            make.right.mas_equalTo(custom_img_1.mas_left).offset(-30);
        }];
        [custom_img_2 mas_makeConstraints:^(MASConstraintMaker *make) {
             make.width.height.centerY.mas_equalTo(custom_img_1);
             make.left.mas_equalTo(custom_img_1.mas_right).offset(30);
        }];
        
        fireEmitter.emitterPosition = CGPointMake(customAreaView.frame.size.width-20,customAreaView.frame.size.height-20);
        fireEmitter.emitterSize = CGSizeMake(customAreaView.frame.size.width*0.8, 20);
        [customAreaView.layer addSublayer:fireEmitter];
    };
    
    baseUIConfigure.customPrivacyAlertView = ^(UIViewController * _Nonnull authPageVC) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"么的感情的自定义隐私协议" message:@"未经您明确同意，我们不会削减您按照本隐私政策所应享有的权利。我们会在本页面上发布对本政策所做的任何变更。\
        对于重大变更，我们还会提供更为显著的通知（包括对于某些服务，我们会通过电子邮件发送通知，说明隐私政策的具体变更内容）。\
        本政策所指的重大变更包括但不限于：\
        \n1、我们的服务模式发生重大变化。如处理个人信息的目的、处理的个人信息类型、个人信息的使用方式；\
        \n2、我们在所有权结构、组织架构方面发生重大变化。如业务调整、破产并购引起的所有者变更；\
        \n3、个人信息共享、转让或公开披露的主要对象发生变化；\
        \n4、您参与个人信息处理方面的权利及其行使方式发生重大变化；\
        \n5、我们负责处理个人信息安全的责任部门、联络方式及投诉渠道发生变化时；\
        \n6、个人信息安全影响评估报告表明存在高风险时。我们还会将本政策的旧版本存档，供您查阅。" preferredStyle:(UIAlertControllerStyleAlert)];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"同意" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [CLShanYanSDKManager setCheckBoxValue:YES];
        }]];
        [authPageVC presentViewController:alert animated:YES completion:nil];
    };
    
    CGFloat screenWidth_Portrait;
    CGFloat screenHeight_Portrait;
    CGFloat screenWidth_Landscape;
    CGFloat screenHeight_Landscape;
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
        screenWidth_Portrait = UIScreen.mainScreen.bounds.size.width;
        screenHeight_Portrait = UIScreen.mainScreen.bounds.size.height;
        screenWidth_Landscape = UIScreen.mainScreen.bounds.size.height;
        screenHeight_Landscape = UIScreen.mainScreen.bounds.size.width;
    }else{
        screenWidth_Portrait = UIScreen.mainScreen.bounds.size.height;
        screenHeight_Portrait = UIScreen.mainScreen.bounds.size.width;
        screenWidth_Landscape = UIScreen.mainScreen.bounds.size.height;
        screenHeight_Landscape = UIScreen.mainScreen.bounds.size.width;
    }
    
    CLOrientationLayOut * layOutPortrait = [[CLOrientationLayOut alloc]init];
    layOutPortrait.clLayoutLogoCenterX = @(0);
    layOutPortrait.clLayoutLogoTop = @(150);
    layOutPortrait.clLayoutLogoWidth = @(120);
    layOutPortrait.clLayoutLogoHeight = @(80);
    
    layOutPortrait.clLayoutLoginBtnCenterX = @(0);
    layOutPortrait.clLayoutLoginBtnWidth = @(screenWidth_Portrait *0.6);
    layOutPortrait.clLayoutLoginBtnCenterY = @(0);
    layOutPortrait.clLayoutLoginBtnHeight = @(45);
    
    layOutPortrait.clLayoutPhoneCenterX = @(0);
    layOutPortrait.clLayoutPhoneCenterY = @(layOutPortrait.clLayoutLoginBtnCenterY.floatValue - 80);
    layOutPortrait.clLayoutPhoneWidth = @(screenWidth_Portrait);
    layOutPortrait.clLayoutPhoneHeight = @(40);
    
    layOutPortrait.clLayoutAppPrivacyLeft = @(50);
    layOutPortrait.clLayoutAppPrivacyRight = @(-30);
    layOutPortrait.clLayoutAppPrivacyBottom = @(-60);
    layOutPortrait.clLayoutAppPrivacyHeight = @(50);
    
    layOutPortrait.clLayoutShanYanSloganBottom = @(-20);
    layOutPortrait.clLayoutShanYanSloganLeft = @(0);
    layOutPortrait.clLayoutShanYanSloganRight = @(0);
    layOutPortrait.clLayoutShanYanSloganHeight = @(20);

    layOutPortrait.clLayoutSloganBottom = @(-40);
    layOutPortrait.clLayoutSloganLeft = @(0);
    layOutPortrait.clLayoutSloganRight = @(0);
    layOutPortrait.clLayoutSloganHeight = @(20);

    
    CLOrientationLayOut * layOutLandscape = [[CLOrientationLayOut alloc]init];
    layOutLandscape.clLayoutLogoCenterX = @(0);
    layOutLandscape.clLayoutLogoTop = @(60);
    layOutLandscape.clLayoutLogoWidth = @(120);
    layOutLandscape.clLayoutLogoHeight = @(80);

    layOutLandscape.clLayoutPhoneCenterX = @(0);
    layOutLandscape.clLayoutPhoneTop = @(layOutLandscape.clLayoutLogoTop.floatValue + layOutLandscape.clLayoutLogoHeight.floatValue);
    layOutLandscape.clLayoutPhoneWidth = @(screenWidth_Landscape);
    layOutLandscape.clLayoutPhoneHeight = @(40);
    
    layOutLandscape.clLayoutLoginBtnCenterX = @(0);
    layOutLandscape.clLayoutLoginBtnWidth = @(screenWidth_Landscape *0.25);
    layOutLandscape.clLayoutLoginBtnTop = @(layOutLandscape.clLayoutPhoneTop.floatValue + layOutLandscape.clLayoutPhoneHeight.floatValue + 20);
    layOutLandscape.clLayoutLoginBtnHeight = @(45);

    layOutLandscape.clLayoutAppPrivacyWidth = @(screenWidth_Landscape*0.6);
    layOutLandscape.clLayoutAppPrivacyCenterX = @(0);
    layOutLandscape.clLayoutAppPrivacyBottom = @(-60);
    layOutLandscape.clLayoutAppPrivacyHeight = @(50);
    
    layOutLandscape.clLayoutShanYanSloganBottom = @(-20);
    layOutLandscape.clLayoutShanYanSloganLeft = @(0);
    layOutLandscape.clLayoutShanYanSloganRight = @(0);
    layOutLandscape.clLayoutShanYanSloganHeight = @(20);

    layOutLandscape.clLayoutSloganBottom = @(-40);
    layOutLandscape.clLayoutSloganLeft = @(0);
    layOutLandscape.clLayoutSloganRight = @(0);
    layOutLandscape.clLayoutSloganHeight = @(20);

    baseUIConfigure.clOrientationLayOutPortrait = layOutPortrait;
    baseUIConfigure.clOrientationLayOutLandscape = layOutLandscape;
    
    

    return baseUIConfigure;
}




//弹窗
+(CLUIConfigure*)shanYanUIConfigureMakerStyle1{
    
    
    UIColor * light_foreground = [UIColor colorWithRed:0.451 green:0.486 blue:1.000 alpha:1];
    UIColor * dark_foreground = [UIColor colorWithRed:0.773 green:0.792 blue:1.000 alpha:1];

    UIColor * light_background = [UIColor colorWithRed:0.651 green:0.679 blue:0.809 alpha:1];
    UIColor * dark_background = [UIColor colorWithRed:0.146 green:0.140 blue:0.307 alpha:1];
    
    CLUIConfigure * baseUIConfigure = [[CLUIConfigure alloc]init];
    
    baseUIConfigure.manualDismiss = @(YES);
    
    baseUIConfigure.shouldAutorotate = @(NO);
    baseUIConfigure.supportedInterfaceOrientations =@(UIInterfaceOrientationMaskAll);;
    
    baseUIConfigure.clAuthTypeUseWindow = @(YES);

    if (@available(iOS 12.0, *)) {
        baseUIConfigure.clAuthWindowOverrideUserInterfaceStyle = @(UIUserInterfaceStyleUnspecified);
    }
    
    //    baseUIConfigure.clBackgroundColor = UIColor.orangeColor;
    baseUIConfigure.clBackgroundImg = [UIImage imageNamed:@"eb9a0dae18491990a43fe02832d3cafa"];
//    baseUIConfigure.clNavigationBarHidden = @(YES);
    baseUIConfigure.clNavigationBackgroundClear = @(NO);
//    baseUIConfigure.clNavigationTintColor = [UIColor generateDynamicColor:light_foreground darkColor:dark_foreground];
    baseUIConfigure.clNavigationBarTintColor = randomDymcialColor;
    baseUIConfigure.clNavigationBottomLineHidden = @(NO);
    baseUIConfigure.clNavigationShadowImage = [UIImage imageNamed:@"line-2"];
    baseUIConfigure.clNavigationAttributesTitleText = [[NSAttributedString alloc]initWithString:@"闪验授权页" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName:randomDymcialColor}];
    
    baseUIConfigure.clNavBackBtnAlimentRight = @(YES);
    
//    UIBarButtonItem * leftControl = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"setting"] style:UIBarButtonItemStylePlain target:self action:@selector(leftControlClick:)];
//    leftControl.tintColor = randomDymcialColor;
//    UIBarButtonItem * rightControl = [[UIBarButtonItem alloc]initWithTitle:@"右测试" style:UIBarButtonItemStylePlain target:self action:@selector(rightControlClick:)];
//    rightControl.tintColor = randomDymcialColor;
//    baseUIConfigure.clNavigationLeftControl = leftControl;
//    baseUIConfigure.clNavigationRightControl = rightControl;

    if (@available(iOS 13.0, *)) {
        baseUIConfigure.clPreferredStatusBarStyle = @(UIStatusBarStyleLightContent);
    } else {
        baseUIConfigure.clPreferredStatusBarStyle = @(UIStatusBarStyleDefault);
    }
    baseUIConfigure.clPrefersStatusBarHidden = @(NO);
//    baseUIConfigure.clNavigationBarStyle =  @(UIBarStyleDefault);
    
    baseUIConfigure.clLogoImage = [UIImage imageNamed:@"shanyanLogo1"];
//    baseUIConfigure.clLogoHiden = @(YES);
    baseUIConfigure.clLogoCornerRadius = @(10);
    
    baseUIConfigure.clPhoneNumberColor = randomDymcialColor;
    baseUIConfigure.clPhoneNumberFont = [UIFont boldSystemFontOfSize:20];
    baseUIConfigure.clPhoneNumberTextAlignment = @(NSTextAlignmentCenter);
    
//    baseUIConfigure.clAppPrivacyWebAttributesTitle = [[NSAttributedString alloc]initWithString:@"闪验运营商协议测试文字" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName:[UIColor generateDynamicColor:UIColor.flatLimeColor darkColor:UIColor.flatGreenColorDark]}];
    
    baseUIConfigure.clAppPrivacyColor = @[randomDymcialColor,randomDymcialColor];
    baseUIConfigure.clAppPrivacyTextFont = [UIFont boldSystemFontOfSize:12];
    baseUIConfigure.clAppPrivacyTextAlignment =  @(NSTextAlignmentLeft);
    baseUIConfigure.clAppPrivacyPunctuationMarks = @(YES);
//    baseUIConfigure.clAppPrivacyLineSpacing = @(5);
//    baseUIConfigure.clAppPrivacyNeedSizeToFit = @(YES);
    //失效
    baseUIConfigure.clAppPrivacyTextContainerInset = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(20, 35, 0, 15)];
    baseUIConfigure.clAppPrivacyAbbreviatedName = @"🐶app";
        
    baseUIConfigure.clAppPrivacyNormalDesTextFirst = @"AA😈";
    baseUIConfigure.clAppPrivacyNormalDesTextSecond = @"BB😤";
    baseUIConfigure.clAppPrivacyNormalDesTextThird = @"CC😱";
    baseUIConfigure.clAppPrivacyNormalDesTextFourth = @"DD😡";
    baseUIConfigure.clAppPrivacyNormalDesTextLast = @"FF👽";

    baseUIConfigure.clOperatorPrivacyAtLast = @(YES);
    
//    baseUIConfigure.clAppPrivacyWebAttributesTitle = [[NSAttributedString alloc]initWithString:@"我的自定义标题" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName:randomDymcialColor}];
    baseUIConfigure.clAppPrivacyWebNormalAttributesTitle = [[NSAttributedString alloc]initWithString:@"我的自定义标题" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName:randomDymcialColor}];
    baseUIConfigure.clAppPrivacyWebTitleList = @[@"🍓🍞🍠🍆自定义协议XXX🍋🍉",@"🍍🍏🍑自定义协议YYY🍅🍟",@"🍕🍔🍳🍚自定义协议ZZZ🍘🍪🍧"];
    baseUIConfigure.clAppPrivacyWebAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName:randomDymcialColor};

    baseUIConfigure.clAppPrivacyWebBackBtnImage = [UIImage imageNamed:@"back-0"];
    
    baseUIConfigure.clAppPrivacyWebNavigationTintColor = randomDymcialColor;
    baseUIConfigure.clAppPrivacyWebNavigationBarTintColor = randomDymcialColor;
    baseUIConfigure.clAppPrivacyWebNavigationBackgroundImage = [UIImage imageNamed:@"label-2"];
    
//    baseUIConfigure.clAppPrivacyWebPreferredStatusBarStyle = @(UIStatusBarStyleLightContent);

    baseUIConfigure.clAppPrivacyFirst = @[@"用户协议1",[NSURL URLWithString:@"https://m.baidu.com"]];
    baseUIConfigure.clAppPrivacySecond = @[@"用户协议2",@"https://m.toutiao.com"];
    baseUIConfigure.clAppPrivacyThird = @[@"用户协议3",[[NSBundle mainBundle] pathForResource:@"ShanYanIndex" ofType:@"html"]];
    baseUIConfigure.clPrivacyShowUnderline = @(YES);
    
    baseUIConfigure.clLoginBtnBgColor = randomDymcialColor;
    baseUIConfigure.clLoginBtnBorderColor = randomDymcialColor;
    baseUIConfigure.clLoginBtnTextColor = randomDymcialColor;
    baseUIConfigure.clLoginBtnBorderWidth = @(2);
    baseUIConfigure.clLoginBtnCornerRadius = @(5);
    
    baseUIConfigure.clLoginBtnNormalBgImage = [UIImage imageNamed:@"bg-1"];
    baseUIConfigure.clLoginBtnHightLightBgImage = [UIImage imageNamed:@"bg-4"];
    baseUIConfigure.clLoginBtnDisabledBgImage = [UIImage imageNamed:@"bg-6"];

    baseUIConfigure.clSloganTextFont = [UIFont boldSystemFontOfSize:12];
    baseUIConfigure.clSloganTextColor = randomDymcialColor;
    baseUIConfigure.clSlogaTextAlignment = @(NSTextAlignmentCenter);
    
    baseUIConfigure.clShanYanSloganHidden = @(NO);
    baseUIConfigure.clShanYanSloganTextFont = [UIFont boldSystemFontOfSize:12];
    baseUIConfigure.clShanYanSloganTextColor = randomDymcialColor;
    baseUIConfigure.clShanYanSloganTextAlignment = @(NSTextAlignmentCenter);
    
    baseUIConfigure.clCheckBoxValue = @(NO);
    baseUIConfigure.clCheckBoxSize = [NSValue valueWithCGSize:CGSizeMake(40, 40)];
    baseUIConfigure.clCheckBoxCheckedImage = [UIImage imageNamed:@"checkbox-multiple-ma"];
    baseUIConfigure.clCheckBoxUncheckedImage = [UIImage imageNamed:@"checkbox-multiple-bl"];
//    baseUIConfigure.clCheckBoxVerticalAlignmentToAppPrivacyTop = @(YES);
    baseUIConfigure.clCheckBoxVerticalAlignmentToAppPrivacyCenterY = @(YES);
    baseUIConfigure.clCheckBoxImageEdgeInsets = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(5, 8, 11, 8)];
    baseUIConfigure.clCheckBoxTipMsg = @"请阅读并同意📃📋🔗📜🔓📝";
    baseUIConfigure.checkBoxTipView = ^(UIView * _Nonnull containerView) {
        [Toast show:@"📃📋🔗📜🔓📝请同意并勾选协议"];
    };
//    baseUIConfigure.clCheckBoxTipDisable = @(NO);
    
    
    //自定义一键登录点击后的loading
//    baseUIConfigure.clLoadingSize = [NSValue valueWithCGSize:CGSizeMake(200, 200)];
//    baseUIConfigure.clLoadingTintColor = randomDymcialColor;
//    baseUIConfigure.clLoadingBackgroundColor = randomDymcialColor;
//    baseUIConfigure.clLoadingIndicatorStyle = @(UIActivityIndicatorViewStyleWhiteLarge);
//    baseUIConfigure.clLoadingCornerRadius = @(100);
    
    //添加授权页自定义控件
    UIButton * custom0 = [[UIButton alloc]init];
    custom0.layer.cornerRadius = 10;
    custom0.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [custom0 setTitle:@"自定义按钮0" forState:(UIControlStateNormal)];
    [custom0 addTarget:self action:@selector(customButton0Click:) forControlEvents:UIControlEventTouchUpInside];
    [custom0 setTitleColor:randomDymcialColor forState:(UIControlStateNormal)];
    custom0.backgroundColor = randomDymcialColor;
    
    UIButton * custom1 = [[UIButton alloc]init];
    custom1.layer.cornerRadius = 10;
    custom1.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [custom1 setTitle:@"自定义按钮1" forState:(UIControlStateNormal)];
    [custom1 addTarget:self action:@selector(customButton1Click:) forControlEvents:UIControlEventTouchUpInside];
    [custom1 setTitleColor:randomDymcialColor forState:(UIControlStateNormal)];
    custom1.backgroundColor = randomDymcialColor;

    UIImageView * custom_img_0 = [[UIImageView alloc]init];
    UIImageView * custom_img_1 = [[UIImageView alloc]init];
    UIImageView * custom_img_2 = [[UIImageView alloc]init];
    custom_img_0.layer.cornerRadius = 10;
    custom_img_1.layer.cornerRadius = 10;
    custom_img_2.layer.cornerRadius = 10;
    custom_img_0.image = [UIImage imageNamed:@"电信"];
    custom_img_1.image = [UIImage imageNamed:@"移动"];
    custom_img_2.image = [UIImage imageNamed:@"联通"];
    
    //粒子
    CAEmitterLayer * fireEmitter = [[self class] generatefileAnimatorStyle1];

    baseUIConfigure.customAreaView = ^(UIView * _Nonnull customAreaView) {
       
        [customAreaView addSubview:custom0];
        [custom0 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(-50);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(30);
            make.centerY.mas_equalTo(40);
        }];
        
        [customAreaView addSubview:custom1];
        [custom1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(50);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(30);
            make.centerY.mas_equalTo(40);
        }];
        
        [customAreaView addSubview:custom_img_0];
        [customAreaView addSubview:custom_img_1];
        [customAreaView addSubview:custom_img_2];

        [custom_img_1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.width.height.mas_equalTo(30);
            make.top.mas_equalTo(custom1.mas_bottom).offset(20);
        }];
        [custom_img_0 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.centerY.mas_equalTo(custom_img_1);
            make.right.mas_equalTo(custom_img_1.mas_left).offset(-30);
        }];
        [custom_img_2 mas_makeConstraints:^(MASConstraintMaker *make) {
             make.width.height.centerY.mas_equalTo(custom_img_1);
             make.left.mas_equalTo(custom_img_1.mas_right).offset(30);
        }];
        
        fireEmitter.emitterPosition = CGPointMake(customAreaView.frame.size.width*0.75-30,customAreaView.frame.size.height*0.5-30);
        fireEmitter.emitterSize = CGSizeMake(customAreaView.frame.size.width*0.8, 20);
        [customAreaView.layer addSublayer:fireEmitter];
    };
    
    
    CGFloat screenWidth_Portrait;
    CGFloat screenHeight_Portrait;
    CGFloat screenWidth_Landscape;
    CGFloat screenHeight_Landscape;
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
        screenWidth_Portrait = UIScreen.mainScreen.bounds.size.width;
        screenHeight_Portrait = UIScreen.mainScreen.bounds.size.height;
        screenWidth_Landscape = UIScreen.mainScreen.bounds.size.height;
        screenHeight_Landscape = UIScreen.mainScreen.bounds.size.width;
    }else{
        screenWidth_Portrait = UIScreen.mainScreen.bounds.size.height;
        screenHeight_Portrait = UIScreen.mainScreen.bounds.size.width;
        screenWidth_Landscape = UIScreen.mainScreen.bounds.size.height;
        screenHeight_Landscape = UIScreen.mainScreen.bounds.size.width;
    }
    

    CGRect frame = CGRectMake(0, 0, screenWidth_Portrait * 0.75, screenHeight_Portrait * 0.5);
    UIBezierPath * patch = [UIBezierPath bezierPathWithRoundedRect:frame byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerBottomRight) cornerRadii:CGSizeMake(100, 100)];
    CAShapeLayer * shap = [CAShapeLayer layer];
    shap.path = patch.CGPath;
    baseUIConfigure.clAuthWindowMaskLayer = shap;
    
    CLOrientationLayOut * layOutPortrait = [[CLOrientationLayOut alloc]init];
    
    layOutPortrait.clAuthWindowOrientationCenter = [NSValue valueWithCGPoint:CGPointMake(screenWidth_Portrait*0.5, screenHeight_Portrait*0.5)];
    layOutPortrait.clAuthWindowOrientationWidth = @(screenWidth_Portrait * 0.75);
    layOutPortrait.clAuthWindowOrientationHeight = @(screenHeight_Portrait * 0.5);
    
    layOutPortrait.clLayoutLogoCenterX = @(0);
    layOutPortrait.clLayoutLogoTop = @(60);
    layOutPortrait.clLayoutLogoWidth = @(100);
    layOutPortrait.clLayoutLogoHeight = @(50);
    
    layOutPortrait.clLayoutPhoneCenterX = @(0);
    layOutPortrait.clLayoutPhoneTop = @(layOutPortrait.clLayoutLogoTop.floatValue + layOutPortrait.clLayoutLogoHeight.floatValue + 10);
    layOutPortrait.clLayoutPhoneWidth = @(screenWidth_Portrait);
    layOutPortrait.clLayoutPhoneHeight = @(40);

    layOutPortrait.clLayoutLoginBtnCenterX = @(0);
    layOutPortrait.clLayoutLoginBtnWidth = @(150);
    layOutPortrait.clLayoutLoginBtnTop = @(layOutPortrait.clLayoutPhoneTop.floatValue + layOutPortrait.clLayoutPhoneHeight.floatValue + 20);
    layOutPortrait.clLayoutLoginBtnHeight = @(45);
    
    
    layOutPortrait.clLayoutAppPrivacyLeft = @(50);
    layOutPortrait.clLayoutAppPrivacyRight = @(-30);
    layOutPortrait.clLayoutAppPrivacyBottom = @(-60);
    layOutPortrait.clLayoutAppPrivacyHeight = @(50);
    
    layOutPortrait.clLayoutShanYanSloganBottom = @(-20);
    layOutPortrait.clLayoutShanYanSloganLeft = @(0);
    layOutPortrait.clLayoutShanYanSloganRight = @(0);
    layOutPortrait.clLayoutShanYanSloganHeight = @(20);

    layOutPortrait.clLayoutSloganBottom = @(-40);
    layOutPortrait.clLayoutSloganLeft = @(0);
    layOutPortrait.clLayoutSloganRight = @(0);
    layOutPortrait.clLayoutSloganHeight = @(20);

    baseUIConfigure.clOrientationLayOutPortrait = layOutPortrait;
    
    return baseUIConfigure;
}

//弹窗+背景蒙版
//实现思路：以弹窗模式弹出，窗口大小设为全屏，将窗口背景设为蒙版色，再自定义一个授权页窗口背景view充当授权窗口，将控件放在窗口背景view中
+(CLUIConfigure*)shanYanUIConfigureMakerStyle2{
    
    
    UIColor * light_foreground = [UIColor colorWithRed:0.451 green:0.486 blue:1.000 alpha:1];
    UIColor * dark_foreground = [UIColor colorWithRed:0.773 green:0.792 blue:1.000 alpha:1];

    UIColor * light_background = [UIColor colorWithRed:0.651 green:0.679 blue:0.809 alpha:1];
    UIColor * dark_background = [UIColor colorWithRed:0.146 green:0.140 blue:0.307 alpha:1];
    
    CLUIConfigure * baseUIConfigure = [[CLUIConfigure alloc]init];
    
    baseUIConfigure.manualDismiss = @(YES);
    
    baseUIConfigure.shouldAutorotate = @(NO);
    baseUIConfigure.supportedInterfaceOrientations =@(UIInterfaceOrientationMaskAll);;
    
//    baseUIConfigure.clAuthWindowModalPresentationStyle = @(UIModalPresentationCustom);
    baseUIConfigure.clAuthWindowModalTransitionStyle = @(UIModalTransitionStyleCrossDissolve);
//    baseUIConfigure.clAuthWindowPresentingAnimate = @(YES);

    baseUIConfigure.clAuthTypeUseWindow = @(YES);

    if (@available(iOS 12.0, *)) {
        baseUIConfigure.clAuthWindowOverrideUserInterfaceStyle = @(UIUserInterfaceStyleUnspecified);
    }
    
    //    baseUIConfigure.clBackgroundColor = UIColor.orangeColor;
//    baseUIConfigure.clBackgroundImg = [UIImage imageNamed:@"eb9a0dae18491990a43fe02832d3cafa"];
    baseUIConfigure.clNavigationBarHidden = @(YES);
//    baseUIConfigure.clNavigationBackgroundClear = @(NO);
//    baseUIConfigure.clNavigationTintColor = [UIColor generateDynamicColor:light_foreground darkColor:dark_foreground];
//    baseUIConfigure.clNavigationBarTintColor = randomDymcialColor;
//    baseUIConfigure.clNavigationBottomLineHidden = @(NO);
//    baseUIConfigure.clNavigationShadowImage = [UIImage imageNamed:@"line-2"];
//    baseUIConfigure.clNavigationAttributesTitleText = [[NSAttributedString alloc]initWithString:@"闪验授权页" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName:randomDymcialColor}];
//    baseUIConfigure.clNavBackBtnAlimentRight = @(YES);
    
//    UIBarButtonItem * leftControl = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"setting"] style:UIBarButtonItemStylePlain target:self action:@selector(leftControlClick:)];
//    leftControl.tintColor = randomDymcialColor;
//    UIBarButtonItem * rightControl = [[UIBarButtonItem alloc]initWithTitle:@"右测试" style:UIBarButtonItemStylePlain target:self action:@selector(rightControlClick:)];
//    rightControl.tintColor = randomDymcialColor;
//    baseUIConfigure.clNavigationLeftControl = leftControl;
//    baseUIConfigure.clNavigationRightControl = rightControl;

//    if (@available(iOS 13.0, *)) {
//        baseUIConfigure.clPreferredStatusBarStyle = @(UIStatusBarStyleLightContent);
//    } else {
//        baseUIConfigure.clPreferredStatusBarStyle = @(UIStatusBarStyleDefault);
//    }
    baseUIConfigure.clPrefersStatusBarHidden = @(YES);
//    baseUIConfigure.clNavigationBarStyle =  @(UIBarStyleDefault);
    
    baseUIConfigure.clLogoImage = [UIImage imageNamed:@"shanyanLogo1"];
//    baseUIConfigure.clLogoHiden = @(YES);
    baseUIConfigure.clLogoCornerRadius = @(10);
    
    baseUIConfigure.clPhoneNumberColor = randomDymcialColor;
    baseUIConfigure.clPhoneNumberFont = [UIFont boldSystemFontOfSize:20];
    baseUIConfigure.clPhoneNumberTextAlignment = @(NSTextAlignmentCenter);
    
//    baseUIConfigure.clAppPrivacyWebAttributesTitle = [[NSAttributedString alloc]initWithString:@"闪验运营商协议测试文字" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName:[UIColor generateDynamicColor:UIColor.flatLimeColor darkColor:UIColor.flatGreenColorDark]}];
    
    baseUIConfigure.clAppPrivacyColor = @[randomDymcialColor,randomDymcialColor];
    baseUIConfigure.clAppPrivacyTextFont = [UIFont boldSystemFontOfSize:12];
    baseUIConfigure.clAppPrivacyTextAlignment =  @(NSTextAlignmentLeft);
    baseUIConfigure.clAppPrivacyPunctuationMarks = @(YES);
//    baseUIConfigure.clAppPrivacyLineSpacing = @(5);
//    baseUIConfigure.clAppPrivacyNeedSizeToFit = @(YES);
    //失效
    baseUIConfigure.clAppPrivacyTextContainerInset = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(20, 35, 0, 15)];
    baseUIConfigure.clAppPrivacyAbbreviatedName = @"🐶app";
        
    baseUIConfigure.clAppPrivacyNormalDesTextFirst = @"AA😈";
    baseUIConfigure.clAppPrivacyNormalDesTextSecond = @"BB😤";
    baseUIConfigure.clAppPrivacyNormalDesTextThird = @"CC😱";
    baseUIConfigure.clAppPrivacyNormalDesTextFourth = @"DD😡";
    baseUIConfigure.clAppPrivacyNormalDesTextLast = @"FF👽";

    baseUIConfigure.clOperatorPrivacyAtLast = @(YES);
    
//    baseUIConfigure.clAppPrivacyWebAttributesTitle = [[NSAttributedString alloc]initWithString:@"我的自定义标题" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName:randomDymcialColor}];
    baseUIConfigure.clAppPrivacyWebNormalAttributesTitle = [[NSAttributedString alloc]initWithString:@"我的自定义标题" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName:randomDymcialColor}];
    baseUIConfigure.clAppPrivacyWebTitleList = @[@"🍓🍞🍠🍆自定义协议XXX🍋🍉",@"🍍🍏🍑自定义协议YYY🍅🍟",@"🍕🍔🍳🍚自定义协议ZZZ🍘🍪🍧"];
    baseUIConfigure.clAppPrivacyWebAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName:randomDymcialColor};

    baseUIConfigure.clAppPrivacyWebBackBtnImage = [UIImage imageNamed:@"back-0"];
    
    baseUIConfigure.clAppPrivacyWebNavigationTintColor = randomDymcialColor;
    baseUIConfigure.clAppPrivacyWebNavigationBarTintColor = randomDymcialColor;
    baseUIConfigure.clAppPrivacyWebNavigationBackgroundImage = [UIImage imageNamed:@"label-2"];
    
//    baseUIConfigure.clAppPrivacyWebPreferredStatusBarStyle = @(UIStatusBarStyleLightContent);

    baseUIConfigure.clAppPrivacyFirst = @[@"用户协议1",[NSURL URLWithString:@"https://m.baidu.com"]];
    baseUIConfigure.clAppPrivacySecond = @[@"用户协议2",@"https://m.toutiao.com"];
    baseUIConfigure.clAppPrivacyThird = @[@"用户协议3",[[NSBundle mainBundle] pathForResource:@"ShanYanIndex" ofType:@"html"]];
    baseUIConfigure.clPrivacyShowUnderline = @(YES);
    
    baseUIConfigure.clLoginBtnBgColor = randomDymcialColor;
    baseUIConfigure.clLoginBtnBorderColor = randomDymcialColor;
    baseUIConfigure.clLoginBtnTextColor = randomDymcialColor;
    baseUIConfigure.clLoginBtnBorderWidth = @(2);
    baseUIConfigure.clLoginBtnCornerRadius = @(5);
    
    baseUIConfigure.clLoginBtnNormalBgImage = [UIImage imageNamed:@"bg-1"];
    baseUIConfigure.clLoginBtnHightLightBgImage = [UIImage imageNamed:@"bg-4"];
    baseUIConfigure.clLoginBtnDisabledBgImage = [UIImage imageNamed:@"bg-6"];

    baseUIConfigure.clSloganTextFont = [UIFont boldSystemFontOfSize:12];
    baseUIConfigure.clSloganTextColor = randomDymcialColor;
    baseUIConfigure.clSlogaTextAlignment = @(NSTextAlignmentCenter);
    
    baseUIConfigure.clShanYanSloganHidden = @(NO);
    baseUIConfigure.clShanYanSloganTextFont = [UIFont boldSystemFontOfSize:12];
    baseUIConfigure.clShanYanSloganTextColor = randomDymcialColor;
    baseUIConfigure.clShanYanSloganTextAlignment = @(NSTextAlignmentCenter);
    
    baseUIConfigure.clCheckBoxValue = @(NO);
    baseUIConfigure.clCheckBoxSize = [NSValue valueWithCGSize:CGSizeMake(40, 40)];
    baseUIConfigure.clCheckBoxCheckedImage = [UIImage imageNamed:@"checkbox-multiple-ma"];
    baseUIConfigure.clCheckBoxUncheckedImage = [UIImage imageNamed:@"checkbox-multiple-bl"];
//    baseUIConfigure.clCheckBoxVerticalAlignmentToAppPrivacyTop = @(YES);
    baseUIConfigure.clCheckBoxVerticalAlignmentToAppPrivacyCenterY = @(YES);
    baseUIConfigure.clCheckBoxImageEdgeInsets = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(5, 8, 11, 8)];
    baseUIConfigure.clCheckBoxTipMsg = @"请阅读并同意📃📋🔗📜🔓📝";
    baseUIConfigure.checkBoxTipView = ^(UIView * _Nonnull containerView) {
        [Toast show:@"📃📋🔗📜🔓📝请同意并勾选协议"];
    };
//    baseUIConfigure.clCheckBoxTipDisable = @(NO);
    
    
    //自定义一键登录点击后的loading
    baseUIConfigure.clLoadingSize = [NSValue valueWithCGSize:CGSizeMake(200, 200)];
    baseUIConfigure.clLoadingTintColor = randomDymcialColor;
    baseUIConfigure.clLoadingBackgroundColor = randomDymcialColor;
    baseUIConfigure.clLoadingIndicatorStyle = @(UIActivityIndicatorViewStyleWhiteLarge);
    baseUIConfigure.clLoadingCornerRadius = @(100);
    baseUIConfigure.loadingView = ^(UIView * _Nonnull containerView) {
//        LOTAnimationView *animation = [LOTAnimationView animationNamed:@"LottieLogo2" inBundle:[NSBundle mainBundle]];
//        [containerView addSubview:animation];
//        animation.backgroundColor = randomDymcialColor;
//        animation.layer.cornerRadius = 20;
//        [animation mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.mas_equalTo(containerView);
//            make.size.mas_equalTo(CGSizeMake(100, 80));
//        }];
//        [animation playWithCompletion:^(BOOL animationFinished) {
//            [animation removeFromSuperview];
//        }];
    };
    
    CGFloat screenWidth_Portrait;
    CGFloat screenHeight_Portrait;
    CGFloat screenWidth_Landscape;
    CGFloat screenHeight_Landscape;
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
        screenWidth_Portrait = UIScreen.mainScreen.bounds.size.width;
        screenHeight_Portrait = UIScreen.mainScreen.bounds.size.height;
        screenWidth_Landscape = UIScreen.mainScreen.bounds.size.height;
        screenHeight_Landscape = UIScreen.mainScreen.bounds.size.width;
    }else{
        screenWidth_Portrait = UIScreen.mainScreen.bounds.size.height;
        screenHeight_Portrait = UIScreen.mainScreen.bounds.size.width;
        screenWidth_Landscape = UIScreen.mainScreen.bounds.size.height;
        screenHeight_Landscape = UIScreen.mainScreen.bounds.size.width;
    }
    
    //添加授权页自定义控件
    UIButton * custom0 = [[UIButton alloc]init];
    custom0.layer.cornerRadius = 10;
    custom0.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [custom0 setTitle:@"自定义按钮0" forState:(UIControlStateNormal)];
    [custom0 addTarget:self action:@selector(customButton0Click:) forControlEvents:UIControlEventTouchUpInside];
    [custom0 setTitleColor:randomDymcialColor forState:(UIControlStateNormal)];
    custom0.backgroundColor = randomDymcialColor;
    
    UIButton * custom1 = [[UIButton alloc]init];
    custom1.layer.cornerRadius = 10;
    custom1.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [custom1 setTitle:@"自定义按钮1" forState:(UIControlStateNormal)];
    [custom1 addTarget:self action:@selector(customButton1Click:) forControlEvents:UIControlEventTouchUpInside];
    [custom1 setTitleColor:randomDymcialColor forState:(UIControlStateNormal)];
    custom1.backgroundColor = randomDymcialColor;

    UIImageView * custom_img_0 = [[UIImageView alloc]init];
    UIImageView * custom_img_1 = [[UIImageView alloc]init];
    UIImageView * custom_img_2 = [[UIImageView alloc]init];
    custom_img_0.layer.cornerRadius = 10;
    custom_img_1.layer.cornerRadius = 10;
    custom_img_2.layer.cornerRadius = 10;
    custom_img_0.image = [UIImage imageNamed:@"电信"];
    custom_img_1.image = [UIImage imageNamed:@"移动"];
    custom_img_2.image = [UIImage imageNamed:@"联通"];
    
    
    baseUIConfigure.customAreaView = ^(UIView * _Nonnull customAreaView) {
       
        customAreaView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.2];
        
        //白色圆角背景
        UIImageView * whiteBGView = [[UIImageView alloc]init];
        whiteBGView.userInteractionEnabled = YES;
        whiteBGView.image = [UIImage imageNamed:@"eb9a0dae18491990a43fe02832d3cafa"];
        
        whiteBGView.layer.shadowColor = UIColor.grayColor.CGColor;
        whiteBGView.layer.shadowOpacity = 9;
        whiteBGView.layer.shadowRadius = 30;
        whiteBGView.layer.shadowOffset = CGSizeMake(5, 5);
//        whiteBGView.layer.masksToBounds = YES;
        [customAreaView addSubview:whiteBGView];
        [whiteBGView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.mas_equalTo(0);
            make.height.mas_equalTo(screenHeight_Portrait*0.5);
            make.width.mas_equalTo(screenWidth_Portrait*0.75);
        }];
        
        UIButton * close = [[UIButton alloc]init];
        [close addTarget:self action:@selector(customButton1Click:) forControlEvents:(UIControlEventTouchUpInside)];
        close.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [close setImage:[UIImage imageNamed:@"close"] forState:(UIControlStateNormal)];
        close.layer.cornerRadius = 20;
        close.layer.masksToBounds = YES;
        [customAreaView addSubview:close];
        [close mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(whiteBGView.mas_right);
            make.bottom.mas_equalTo(whiteBGView.mas_top);
            make.width.height.mas_equalTo(50);
        }];
    
        [whiteBGView addSubview:custom0];
        [custom0 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(-50);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(30);
            make.centerY.mas_equalTo(40);
        }];
        
        [whiteBGView addSubview:custom1];
        [custom1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(50);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(30);
            make.centerY.mas_equalTo(40);
        }];
        
        [whiteBGView addSubview:custom_img_0];
        [customAreaView addSubview:custom_img_1];
        [customAreaView addSubview:custom_img_2];

        [custom_img_1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.width.height.mas_equalTo(30);
            make.top.mas_equalTo(custom1.mas_bottom).offset(20);
        }];
        [custom_img_0 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.centerY.mas_equalTo(custom_img_1);
            make.right.mas_equalTo(custom_img_1.mas_left).offset(-30);
        }];
        [custom_img_2 mas_makeConstraints:^(MASConstraintMaker *make) {
             make.width.height.centerY.mas_equalTo(custom_img_1);
             make.left.mas_equalTo(custom_img_1.mas_right).offset(30);
        }];
    };
        
    CLOrientationLayOut * layOutPortrait = [[CLOrientationLayOut alloc]init];
    
    layOutPortrait.clAuthWindowOrientationCenter = [NSValue valueWithCGPoint:CGPointMake(screenWidth_Portrait*0.5, screenHeight_Portrait*0.5)];
    layOutPortrait.clAuthWindowOrientationWidth = @(screenWidth_Portrait);
    layOutPortrait.clAuthWindowOrientationHeight = @(screenHeight_Portrait);
    
    layOutPortrait.clLayoutLogoCenterX = @(0);
    layOutPortrait.clLayoutLogoTop = @(screenHeight_Portrait*0.25 + 60);
    layOutPortrait.clLayoutLogoWidth = @(100);
    layOutPortrait.clLayoutLogoHeight = @(50);
    
    layOutPortrait.clLayoutPhoneCenterX = @(0);
    layOutPortrait.clLayoutPhoneTop = @(layOutPortrait.clLayoutLogoTop.floatValue + layOutPortrait.clLayoutLogoHeight.floatValue + 10);
    layOutPortrait.clLayoutPhoneWidth = @(screenWidth_Portrait);
    layOutPortrait.clLayoutPhoneHeight = @(40);

    layOutPortrait.clLayoutLoginBtnCenterX = @(0);
    layOutPortrait.clLayoutLoginBtnWidth = @(150);
    layOutPortrait.clLayoutLoginBtnTop = @(layOutPortrait.clLayoutPhoneTop.floatValue + layOutPortrait.clLayoutPhoneHeight.floatValue + 20);
    layOutPortrait.clLayoutLoginBtnHeight = @(45);
    
    
    layOutPortrait.clLayoutShanYanSloganBottom = @(-screenHeight_Portrait*0.25 -20);
    layOutPortrait.clLayoutShanYanSloganLeft = @(0);
    layOutPortrait.clLayoutShanYanSloganRight = @(0);
    layOutPortrait.clLayoutShanYanSloganHeight = @(20);

    layOutPortrait.clLayoutSloganBottom = @(layOutPortrait.clLayoutShanYanSloganBottom.floatValue - layOutPortrait.clLayoutShanYanSloganHeight.floatValue);
    layOutPortrait.clLayoutSloganLeft = @(0);
    layOutPortrait.clLayoutSloganRight = @(0);
    layOutPortrait.clLayoutSloganHeight = @(20);
    
    layOutPortrait.clLayoutAppPrivacyLeft = @(screenWidth_Portrait*0.125 + 50);
    layOutPortrait.clLayoutAppPrivacyRight = @(-screenWidth_Portrait*0.125 -30);
    layOutPortrait.clLayoutAppPrivacyBottom = @(layOutPortrait.clLayoutSloganBottom.floatValue - layOutPortrait.clLayoutSloganHeight.floatValue);
    layOutPortrait.clLayoutAppPrivacyHeight = @(50);


    baseUIConfigure.clOrientationLayOutPortrait = layOutPortrait;
    
    return baseUIConfigure;
}


+(void)customButton0Click:(UIButton*)sender{
    [Toast show:[NSString stringWithFormat:@"%s",__func__]];
}
+(void)customButton1Click:(UIButton*)sender{
    [Toast show:[NSString stringWithFormat:@"%s",__func__]];
    [CLShanYanSDKManager finishAuthControllerAnimated:YES Completion:^{
        [Toast show:[NSString stringWithFormat:@"%s",__func__]];
    }];
}



+(void)leftControlClick:(UIBarButtonItem *)sender{
    [CLShanYanSDKManager finishAuthControllerAnimated:YES Completion:^{
        NSLog(@"%s",__func__);
    }];
}
+(void)rightControlClick:(UIBarButtonItem *)sender{
//    [SVProgressHUD showInfoWithStatus:@"点击了右按钮"];
}




#pragma mark - CLShanYanSDKManagerDelegate
/**
 * 统一事件监听方法
 * type：事件类型（1，2，3）
 * 1：隐私协议点击
 * - 同-clShanYanSDKManagerWebPrivacyClicked:privacyIndex:currentTelecom
 * code：0,1,2,3（协议页序号），message：协议名_当前运营商类型
 * 2：协议勾选框点击
 * code：0,1（0为未选中，1为选中）
 * 3："一键登录"按钮点击
 * code：0,1（0为协议勾选框未选中，1为选中）
*/
-(void)clShanYanActionListener:(NSInteger)type code:(NSInteger)code  message:(NSString *_Nullable)message{
    NSLog(@"%s\ntype:%d,code:%d,message:%@",__func__,type,code,message);
}


/**
 * 授权页面已经显示的回调
 * ViewDidAppear
 * @param telecom     当前运营商类型
 */
-(void)clShanYanSDKManagerAuthPageAfterViewDidLoad:(UIView *_Nonnull)authPageView currentTelecom:(NSString *_Nullable)telecom {
    NSLog(@"%s\nauthPageView:%@,telecom:%@",__func__,authPageView,telecom);
}

/**
* 授权页vc alloc init
* init，注：此时authPageVC.navigationController为nil
* @param telecom     当前运营商类型
*/
-(void)clShanYanSDKManagerAuthPageCompleteInit:(UIViewController *_Nonnull)authPageVC currentTelecom:(NSString *_Nullable)telecom object:(NSObject*_Nullable)object userInfo:(NSDictionary*_Nullable)userInfo{
    NSLog(@"%s\ncurrentTelecom:%@,object:%@,userInfo:%@",__func__,telecom,object.description,userInfo);

    NSObject * phoneInfo = object;
    
    UIViewController * shanYanAuthPageVC = authPageVC;
    
    UIView * shanYanAuthPageView = authPageVC.view;
    UIImageView * backgroundImageView = userInfo[@"backgroundImageView"];

    UILabel * shanYanSloganLabel = userInfo[@"shanYanSloganLabel"];
    UILabel * sloganLabel = userInfo[@"sloganLabel"];
    UILabel * privacyLabel = userInfo[@"privacyLabel"];
    UIButton * checkBox = userInfo[@"checkBox"];
    UIButton * loginBtn = userInfo[@"loginBtn"];
    UILabel * phoneLB = userInfo[@"phoneLB"];
    UIImageView * logoImageView = userInfo[@"logoImageView"];

}

/**
 * 授权页面将要显示的回调 ViewDidLoad即将全部执行完毕的最后时机
 * ViewDidLoad  did complete
 * @param telecom     当前运营商类型
 */
-(void)clShanYanSDKManagerAuthPageCompleteViewDidLoad:(UIViewController *_Nonnull)authPageVC currentTelecom:(NSString *_Nullable)telecom object:(NSObject*_Nullable)object userInfo:(NSDictionary*_Nullable)userInfo{
    NSLog(@"%s\ncurrentTelecom:%@,object:%@,userInfo:%@",__func__,telecom,object.description,userInfo);

    NSObject * phoneInfo = object;
    
    UIViewController * shanYanAuthPageVC = authPageVC;
    UINavigationController * shanYanAuthPageNav = authPageVC.navigationController;
  
}


/**
 * 授权页vc 将要被present
 * 将要调用[uiconfigure.viewcontroller  present:authPageVC animation:completion:]
 * @param telecom     当前运营商类型
 */
-(void)clShanYanSDKManagerAuthPageWillPresent:(UIViewController *_Nonnull)authPageVC currentTelecom:(NSString *_Nullable)telecom object:(NSObject*_Nullable)object userInfo:(NSDictionary*_Nullable)userInfo{
    NSObject * phoneInfo = object;
    
    UIViewController * shanYanAuthPageVC = authPageVC;
    UINavigationController * shanYanAuthPageNav = authPageVC.navigationController;
}

/**
 * 授权页面将要显示的回调
 * ViewWillAppear
 * @param telecom     当前运营商类型
 */
-(void)clShanYanSDKManagerAuthPageCompleteViewWillAppear:(UIViewController *_Nonnull)authPageVC currentTelecom:(NSString *_Nullable)telecom object:(NSObject*_Nullable)object userInfo:(NSDictionary*_Nullable)userInfo{
    NSLog(@"%s\ncurrentTelecom:%@,object:%@,userInfo:%@",__func__,telecom,object.description,userInfo);
}




//生成粒子
+(CAEmitterLayer *)generatefileAnimatorStyle0{
    //粒子
    CAEmitterLayer * fireEmitter=[[CAEmitterLayer alloc]init];
    fireEmitter.renderMode = kCAEmitterLayerAdditive;
    //火焰
    CAEmitterCell * fire = [CAEmitterCell emitterCell];
    fire.birthRate=800;
    fire.lifetime=2.0;
    fire.lifetimeRange=1.5;
    fire.color=[[UIColor colorWithRed:0.8 green:0.4 blue:0.2 alpha:0.1]CGColor];
    fire.contents=(id)[[UIImage imageNamed:@"Snow_small"] CGImage];
    [fire setName:@"fire"];
    fire.velocity=160;
    fire.velocityRange=80;
    fire.emissionLongitude=-(M_PI*3/4);
    fire.emissionRange=M_PI_2;
    fire.scaleSpeed=0.3;
    fire.spin=0.2;
    //烟雾
    CAEmitterCell * smoke = [CAEmitterCell emitterCell];
    smoke.birthRate=400;
    smoke.lifetime=3.0;
    smoke.lifetimeRange=1.5;
    smoke.color=[[UIColor colorWithRed:1 green:1 blue:1 alpha:0.05]CGColor];
    smoke.contents=(id)[[UIImage imageNamed:@"Snow_small"] CGImage];
    [fire setName:@"smoke"];
    smoke.velocity=250;
    smoke.velocityRange=100;
    smoke.emissionLongitude=0;
    smoke.emissionRange=M_PI_2;
    fireEmitter.emitterCells=[NSArray arrayWithObjects:smoke,fire,nil];
    return fireEmitter;
}

+(CAEmitterLayer *)generatefileAnimatorStyle1{
    CAEmitterLayer * fireEmitter=[[CAEmitterLayer alloc]init];
    fireEmitter.renderMode = kCAEmitterLayerAdditive;
    //火焰
    CAEmitterCell * fire = [CAEmitterCell emitterCell];
    fire.birthRate=200;
    fire.lifetime=2.0;
    fire.lifetimeRange=1.5;
    fire.color=[[UIColor colorWithRed:0.4 green:0.6 blue:0.7 alpha:0.1]CGColor];
    fire.contents=(id)[[UIImage imageNamed:@"Snow_small"]CGImage];
    [fire setName:@"fire"];
    fire.velocity=160;
    fire.velocityRange=80;
    fire.emissionLongitude=-(M_PI*3/4);
    fire.emissionRange=M_PI_2;
    fire.scaleSpeed=0.3;
    fire.spin=0.2;
    //烟雾
    CAEmitterCell * smoke = [CAEmitterCell emitterCell];
    smoke.birthRate=50;
    smoke.lifetime=3.0;
    smoke.lifetimeRange=1.5;
    smoke.color=[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.05]CGColor];
    smoke.contents=(id)[[UIImage imageNamed:@"Snow_small"]CGImage];
    [fire setName:@"smoke"];
    smoke.velocity=250;
    smoke.velocityRange=100;
    smoke.emissionLongitude=0;
    smoke.emissionRange=M_PI_2;
    fireEmitter.emitterCells=[NSArray arrayWithObjects:smoke,fire,nil];
    return fireEmitter;
}


@end
