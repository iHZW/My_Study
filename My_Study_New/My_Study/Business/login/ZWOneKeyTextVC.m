//
//  ZWOneKeyTextVC.m
//  My_Study
//
//  Created by Zhiwei Han on 2023/2/4.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "ZWOneKeyTextVC.h"
#import "LoadingUtil.h"
#import "Toast.h"
#import "ZWOneKey.h"

@interface ZWOneKeyTextVC ()

@end

@implementation ZWOneKeyTextVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self openAuthAPIClick:nil];
}


/// 展示授权页
-(void)openAuthAPIClick:(UIButton *)sender{
    //建议做防止快速点击
    [sender setEnabled:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [sender setEnabled:YES];
    });
    [LoadingUtil show];
    
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();

    __weak typeof(self) weakSelf = self;
    
    //    CLUIConfigure * baseUIConfigure = [CLUIConfigure clDefaultUIConfigure];//fast test

//    CLUIConfigure * baseUIConfigure;
//    NSInteger type_random = arc4random()%3;
//    if (type_random == 0) {
//        baseUIConfigure = [ShanYanUIConfigureMaker shanYanUIConfigureMakerStyle0];
//    }else if (type_random == 1){
//        baseUIConfigure = [ShanYanUIConfigureMaker shanYanUIConfigureMakerStyle1];
//    }else{
//        baseUIConfigure = [ShanYanUIConfigureMaker shanYanUIConfigureMakerStyle2];
//    }
////    baseUIConfigure = [ShanYanUIConfigureMaker shanYanUIConfigureMakerStyle0];
//
//    baseUIConfigure.viewController = self;
    
    static  int a =0;
    
    int i = a%7;

    NSString *st = [@"configureMake" stringByAppendingFormat:@"%d",i];

    CLUIConfigure * baseUIConfigure = [self configureMake2];//[self performSelector:NSSelectorFromString(st)];

    a++;
    
    [CLShanYanSDKManager setCLShanYanSDKManagerDelegate:ZWOneKey.staticInstance];
    
    [CLShanYanSDKManager quickAuthLoginWithConfigure:baseUIConfigure openLoginAuthListener:^(CLCompleteResult * _Nonnull completeResult) {
        CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();

        //建议做防止快速点击
        dispatch_async(dispatch_get_main_queue(), ^{
            [LoadingUtil hide];
            [sender setEnabled:YES];
        });
        
        if (completeResult.error) {
//            CLConsoleLog(@"openLoginAuthListener:%@\ncost:%f",completeResult.yy_modelToJSONObject,end - start);
        }else{
//            CLConsoleLog(@"openLoginAuthListener:%@\ncost:%f",completeResult.yy_modelToJSONObject,end - start);
        }

    } oneKeyLoginListener:^(CLCompleteResult * _Nonnull completeResult) {
        
        CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();

        __strong typeof(self) strongSelf = weakSelf;
 
        if (completeResult.error) {
//            CLConsoleLog(@"oneKeyLoginListener:%@\ncost:%f",completeResult.yy_modelToJSONObject,end - start);
            
            
            //提示：错误无需提示给用户，可以在用户无感知的状态下直接切换登录方式
            if (completeResult.code == 1011){
                //用户取消登录（点返回）
                //处理建议：如无特殊需求可不做处理，仅作为交互状态回调，此时已经回到当前用户自己的页面
                //点击sdk自带的返回，无论是否设置手动销毁，授权页面都会强制关闭
            }  else{
                //处理建议：其他错误代码表示闪验通道无法继续，可以统一走开发者自己的其他登录方式，也可以对不同的错误单独处理
                //1003    一键登录获取token失败
                //其他     其他错误//
                
                //关闭授权页
//                    [CLShanYanSDKManager finishAuthControllerAnimated:YES Completion:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [CLShanYanSDKManager hideLoading];
                });
            }
        }else{
            
//            CLConsoleLog(@"oneKeyLoginListener:%@\ncost:%f",completeResult.yy_modelToJSONObject,end - start);

            //测试置换手机号
//            [ShanYanGetPhoneNumberDemoCode getPhonenumber:completeResult.data completion:^(NSString * _Nonnull phoneNumber, id  _Nullable responseObject, NSError * _Nonnull error) {
//
//                //关闭页面
//                [CLShanYanSDKManager finishAuthControllerCompletion:^{
//                }];
//
//                if (phoneNumber) {
////                    CLConsoleLog(@"免密登录成功,手机号：%@",phoneNumber);
////                    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"免密登录成功,手机号：%@",phoneNumber]];
//                    [Toast show:[NSString stringWithFormat:@"免密登录成功,手机号：%@",phoneNumber]];
//
//                }else{
//
//                    if (responseObject) {
////                        CLConsoleLog(@"免密登录解密失败:%@",responseObject);
//                        [Toast show:[NSString stringWithFormat:@"免密登录解密失败:%@",responseObject]];
////                        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"免密登录解密失败:%@",responseObject]];
//                    }else{
////                        CLConsoleLog(@"免密登录解密失败:%@",error.localizedDescription);
////                        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"免密登录解密失败:%@",error.localizedDescription]];
//                        [Toast show:[NSString stringWithFormat:@"免密登录解密失败:%@",error.localizedDescription]];
//
//                    }
//                }
//
//            }];
        }
    }];
}


-(CLUIConfigure *)configureMake2{
    
    CGFloat width  = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    CGFloat scale = width/375.0;//以iphone6 屏幕为基准
    //黑
    UIColor *color1 = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:1.0];
    //灰
    UIColor *color2 = [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1.0];
    //墨绿
    UIColor *color3 = [UIColor colorWithRed:54/255.0 green:134/255.0 blue:141/255.0 alpha:1.0];
    
    
    CLUIConfigure *configure = [[CLUIConfigure alloc] init];
    configure.viewController = self;
    configure.shouldAutorotate = @(NO);;
    //导航栏
    UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"top_icon_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(dismis)];
    configure.clNavigationLeftControl = closeButtonItem;
    configure.clNavigationBackgroundClear = @(YES);
    configure.clNavigationBottomLineHidden = @(YES);
    
    //隐藏logo
    configure.clLogoHiden = @(YES);
    
    //掩码
    configure.clPhoneNumberFont = [UIFont systemFontOfSize:22];
    configure.clPhoneNumberColor = color1;
    configure.clPhoneNumberTextAlignment = @(NSTextAlignmentLeft);
    
    //登录按钮
    configure.clLoginBtnText = @"立即登录";
    configure.clLoginBtnBgColor = color3;
    configure.clLoginBtnTextFont = [UIFont systemFontOfSize:16 weight:0.3];
    configure.clLoginBtnCornerRadius = @(5.0);
    configure.clLoginBtnTextColor = [UIColor whiteColor];
    
    //slog
    configure.clSloganTextFont = [UIFont systemFontOfSize:14 weight:0.2];
    configure.clSloganTextColor = color2;
    
    
    //协议
    configure.clCheckBoxHidden = @(YES);
    configure.clAppPrivacyNormalDesTextFirst = @"注册/登录即代表您年满18岁，已认真阅读并同意接受闪验";
    configure.clAppPrivacyFirst = @[@"《服务条款》",[NSURL URLWithString:@"https://shanyan253.com"]];
    configure.clAppPrivacyNormalDesTextSecond = @"、";
    configure.clAppPrivacySecond = @[@"《隐私政策》",[NSURL URLWithString:@"https://shanyan253.com"]];
    configure.clAppPrivacyNormalDesTextThird= @",以及同意";
    configure.clAppPrivacyPunctuationMarks = @(YES);
    configure.clPrivacyShowUnderline = @(YES);
    configure.clOperatorPrivacyAtLast = @(YES);
    configure.clAppPrivacyLineSpacing = @(3.0);
    configure.clAppPrivacyTextFont = [UIFont systemFontOfSize:16 weight:0.3];
    configure.clAppPrivacyTextAlignment = @(NSTextAlignmentLeft);
    configure.clAppPrivacyColor = @[color2,color3];
    
    
    CLOrientationLayOut *layout = [[CLOrientationLayOut alloc] init];
    configure.clOrientationLayOutPortrait = layout;
    
    
    CGFloat top = 180*scale + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + 44;//顶部视图的高度以及间距只和
    
    //掩码
    layout.clLayoutPhoneTop = @(top) ;
    layout.clLayoutPhoneLeft = @(30*scale);
    layout.clLayoutLogoHeight = @(30*scale);
    
    
    top  = layout.clLayoutPhoneTop.floatValue + layout.clLayoutLogoHeight.floatValue;
    
    //登录按钮
    layout.clLayoutLoginBtnTop = @(top + 30*scale);
    layout.clLayoutLoginBtnLeft = @(30*scale);
    layout.clLayoutLoginBtnRight = @(-30*scale);
    layout.clLayoutLoginBtnHeight = @(50*scale);
    
    
    top = layout.clLayoutLoginBtnTop.floatValue + layout.clLayoutLoginBtnHeight.floatValue;
    
    //slog
    layout.clLayoutSloganTop = @(top + 10*scale);
    layout.clLayoutSloganLeft = @(30*scale);
    layout.clLayoutLogoHeight = @(25*scale);
        
    top  = layout.clLayoutSloganTop.floatValue + layout.clLayoutLogoHeight.floatValue;
    
    CGFloat slogBottom = top;
    
    
    top += 110*scale + 0.15*width;
    
    
    //协议
    layout.clLayoutAppPrivacyTop = @(top + 20*scale);
    layout.clLayoutAppPrivacyLeft = @(30*scale);
    layout.clLayoutAppPrivacyRight = @(-30*scale);
    
    __weak typeof(self) weakSelf = self;
    
    configure.customAreaView = ^(UIView * _Nonnull customAreaView) {
        
        customAreaView.backgroundColor = [UIColor whiteColor];
        
        
        UILabel *tipLabel1 = [[UILabel alloc] init];
        tipLabel1.text = @"本机号码快捷登录";
        tipLabel1.font = [UIFont systemFontOfSize:30 weight:1.0];
        tipLabel1.textColor = color1;
        [customAreaView addSubview:tipLabel1];
        
        [tipLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(50*scale + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + 44);
            make.left.mas_equalTo(30*scale);
            make.height.mas_equalTo(40*scale);
        }];
        
        
        UILabel *tipLabel2 = [[UILabel alloc] init];
        tipLabel2.text = @"本机号码未注册将自动创建新账号";
        tipLabel2.font = [UIFont systemFontOfSize:16 weight:0.2];
        tipLabel2.textColor = color2;
        [customAreaView addSubview:tipLabel2];
        
        [tipLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
            
            
            make.top.equalTo(tipLabel1.mas_bottom).offset(5*scale);
            make.left.equalTo(tipLabel1);
            make.height.mas_equalTo(25*scale);
        }];
        
        UILabel *tipLabel3 = [[UILabel alloc] init];
        tipLabel3.text = @"本机号码";
        tipLabel3.font = [UIFont systemFontOfSize:16 weight:0.2];
        tipLabel3.textColor = color1;
        [customAreaView addSubview:tipLabel3];
        
        [tipLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(tipLabel2);
            make.top.equalTo(tipLabel2.mas_bottom).offset(30*scale);
            make.height.mas_equalTo(25*scale);
        }];
        
        //其他手机号登录
        UIButton *otherPhone = [UIButton buttonWithType:UIButtonTypeSystem];
        [otherPhone setTitle:@"使用其他手机号" forState:UIControlStateNormal];
        [otherPhone.titleLabel setFont:[UIFont systemFontOfSize:16 weight:0.3]];
        [otherPhone setTitleColor:color3 forState:UIControlStateNormal];
        [otherPhone addTarget:weakSelf action:@selector(dismis) forControlEvents:UIControlEventTouchUpInside];
        [customAreaView addSubview:otherPhone];
        
        [otherPhone mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo( slogBottom + 20*scale);
            make.left.mas_equalTo(30*scale);
            make.height.mas_equalTo(25*scale);
        }];
        
        //或者使用微信登录
        UILabel *weixinLabel = [[UILabel alloc] init];
        weixinLabel.text = @"或使用微信登录";
        weixinLabel.textColor = color2;
        weixinLabel.font = [UIFont systemFontOfSize:16 weight:0.3];
        [customAreaView addSubview:weixinLabel];
        
        [weixinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(otherPhone.mas_bottom).offset(20*scale);
            make.centerX.mas_equalTo(0);
            make.height.mas_equalTo(25*scale);
            
        }];
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage :[UIImage imageNamed:@"weixin"] forState:UIControlStateNormal];
        [customAreaView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.width.mas_equalTo(0.15*width);
            make.height.mas_equalTo(0.15*width);
            make.top.equalTo(weixinLabel.mas_bottom).offset(20*scale);
            make.centerX.mas_equalTo(0);
            
        }];
    
    };
    
    
    return configure;
}

- (void)dismis{
    [CLShanYanSDKManager finishAuthControllerCompletion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
