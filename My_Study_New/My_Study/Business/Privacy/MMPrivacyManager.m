//
//  MMPrivacyManager.m
//  My_Study
//
//  Created by hzw on 2023/2/17.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "MMPrivacyManager.h"
#import "AlertView.h"
#import "StoreUtil.h"
#import "UIFont+Tool.h"
#import "UIColor+Ext.h"
#import "ZWSDK.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "MMPrivacyLinksView.h"

@interface MMPrivacyManager ()

@property (nonatomic, weak) AlertView *alertView;

@end

@implementation MMPrivacyManager

+ (instancetype)sharedInstance {
    static MMPrivacyManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });

    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (void)showPrivacyAlert:(UIView *)inView clickResult:(PrivacyButtonClick)clickResult {
    [self showPrivacyAlert:inView
                     title:@"用户协议与隐私协议提示"
                   message:@"尊敬的企业之家用户，为了更好地保障您的合法权益，我们非常重视您的隐私保护和个人信息保护，特别提醒仔细阅读企业之家服务协议与隐私协议。<br/>我们会严格按照法律规定存储和使用您的个人信息，未经您同意，我们不会提供给任何第三方使用<br/>第三方产品或服务如何获得您的个人信息<br/>您同意并理解，为了更好地提供服务，我们的产品可能会集成或接入第三方服务，如SDK、API或H5等。这些第三方服务商独立运营，单独获得您的授权同意，直接收集您的个人信息，并独立承担相关的责任和义务。<br/>当您所使用微信账号登录企业之家时，微信SDK会收集微信账号的唯一ID、名称、头像。当您通过企业之家进行支付结算时，微信SDK、支付宝SDK收集您设备信息、系统版本、订单信息、交易状态。其余SDK包括：腾讯bugly SDK监控APP崩溃；创蓝闪验SDK实现App一键登录；TrackingIO（热云SDK）设备状态信息包括iOS广告标识符（IDFA和IDFV）、安卓广告主标识符（Android ID）、网卡地址（MAC）、IP地址、国际移动设备识别码（IMEI）、移动设备识别码（MEID）、匿名设备标识码（OAID）、设备型号、终端制造厂商、终端设备操作系统版本IP地址；高德地图SDK集您的位置信息，访问网络用于获取地图服务；个推SDK、华为push SDK、小米push SDK帮助用户接收推送消息；友盟SDK用于数据统计及分析、神策SDK检测App业务功能，界面点击情况。"
               clickResult:clickResult];
}

- (void)showPrivacyUpgradeAlert:(UIView *)inView clickResult:(PrivacyButtonClick)clickResult {
    [self showPrivacyAlert:inView
                     title:@"协议更新提示"
                   message:@"为了让您在安全、放心的环境下使用企业之家，建议仔细阅读企业之家服务协议与隐私协议的更新"
               clickResult:clickResult];
}

- (void)showPrivacyAlert:(UIView *)inView
                   title:(NSString *)title
                 message:(NSString *)message
             clickResult:(PrivacyButtonClick)clickResult {
    AlertView *alertView            = [[AlertView alloc] init];
    alertView.disableBgTap          = YES;
    alertView.title                 = title;
    alertView.message               = message;
    alertView.messageFont           = [UIFont fontWithName:[UIFont eh_midiumFontName] size:15];
    alertView.customBottomViewBlock = ^UIView *_Nonnull {
        return [self makeFooterView:^(NSInteger index) {
            if (index == 0) {
                [Toast show:@"退出应用"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    exit(0);
                });
            } else if (index == 1) {
                /** 发送请求  */
                @weakify(self)
//                BaseRequest *request = [BaseRequest defaultRequest];
//                [WM.http post:API_PRIVACY_AGREE requestModel:request complete:^(ResultObject *_Nonnull result) {
//                    @strongify(self) if (result.isSuccess) {
//                        [self.alertView hidden];
//                    }
//                }];
            }
            BlockSafeRun(clickResult, index);
        }];
    };

    [alertView showInView:inView];
    self.alertView = alertView;
}

- (UIView *)makeFooterView:(PrivacyButtonClick)clickResult {
    CGFloat totalWidth  = kMainScreenWidth - 48 * 2;
    CGFloat totalHeight = 115;
    UIView *footerView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, totalWidth, totalHeight)];

    CGFloat buttonHeight  = 40;
    CGFloat buttonOriginY = totalHeight - 23 - buttonHeight;

    CGRect frame                = CGRectMake(0, buttonOriginY - 24 - 13 - 10, totalWidth, 44);
    MMPrivacyLinksView *linksView = [[MMPrivacyLinksView alloc] initWithFrame:frame];
    [footerView addSubview:linksView];

    CGFloat horizonMargin  = 28; // 按钮距离父边界的水平距离
    CGFloat horizonPadding = 22; // 按钮之间的距离

    CGFloat buttonWidth = (totalWidth - 2 * horizonMargin - horizonPadding) / 2.0;

    frame                         = CGRectMake(horizonMargin, buttonOriginY, buttonWidth, buttonHeight);
    UIButton *declineButton       = [[UIButton alloc] initWithFrame:frame];
    declineButton.backgroundColor = [UIColor colorFromHexCode:@"#F1F4FF"];
    declineButton.titleLabel.font = [UIFont fontWithName:[UIFont eh_regularFontName] size:16];
    [declineButton setTitleColor:[UIColor colorFromHexCode:@"#AAAAAA"] forState:UIControlStateNormal];
    [declineButton setTitle:@"不同意" forState:UIControlStateNormal];
    declineButton.layer.cornerRadius  = 4;
    declineButton.layer.masksToBounds = YES;
    [[declineButton rac_signalForControlEvents:UIControlEventTouchUpInside]
        subscribeNext:^(id x) {
            clickResult(0);
        }];
    [footerView addSubview:declineButton];

    frame                    = CGRectMake(horizonMargin + buttonWidth + horizonPadding, buttonOriginY, buttonWidth, buttonHeight);
    UIButton *okButton       = [[UIButton alloc] initWithFrame:frame];
    okButton.backgroundColor = [UIColor colorFromHexCode:@"#4F7AFD"];
    okButton.titleLabel.font = [UIFont fontWithName:[UIFont eh_regularFontName] size:16];
    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [okButton setTitle:@"同意并继续" forState:UIControlStateNormal];
    okButton.layer.cornerRadius  = 4;
    okButton.layer.masksToBounds = YES;
    [[okButton rac_signalForControlEvents:UIControlEventTouchUpInside]
        subscribeNext:^(id x) {
            clickResult(1);
        }];
    [footerView addSubview:okButton];
    return footerView;
}

+ (NSString *)_AppPrivacyShowedKey {
    return @"EHome_Privacy_Showed_Key_V1";
}

- (BOOL)hasShowedAppPrivacy {
    NSString *value = [StoreUtil stringForKey:[MMPrivacyManager _AppPrivacyShowedKey] isPermanent:NO];
    if (value.length > 0) {
        return [value boolValue];
    }
    return NO;
}

- (void)markAppPrivacyShowed {
    NSString *value = [NSString stringWithFormat:@"%d", YES];
    [StoreUtil setString:value forKey:[MMPrivacyManager _AppPrivacyShowedKey] isPermanent:NO];
}

@end
