//
//  MMShareItem.h
//  My_Study
//
//  Created by Zhiwei Han on 2023/2/8.
//  Copyright © 2023 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define  ALERT_MSG(TITLE,MESSAGE,CONTROLLER) UIAlertController *alertController = [UIAlertController alertControllerWithTitle:TITLE message:MESSAGE preferredStyle:UIAlertControllerStyleAlert];\
[alertController addAction:[UIAlertAction actionWithTitle:@"确定"style:UIAlertActionStyleDefault handler:nil]];\
[CONTROLLER presentViewController:alertController animated:YES completion:nil];

@class MMShareItem;

typedef void (^__nullable ShareHandle)(MMShareItem *item);

// 预制的分享平台
FOUNDATION_EXTERN NSString *_Nonnull const MMPlatformNameSina;   // 新浪微博
FOUNDATION_EXTERN NSString *_Nonnull const MMPlatformNameQQ;     // QQ
FOUNDATION_EXTERN NSString *_Nonnull const MMPlatformNameEmail;  // 邮箱
FOUNDATION_EXTERN NSString *_Nonnull const MMPlatformNameSms;    // 短信
FOUNDATION_EXTERN NSString *_Nonnull const MMPlatformNameWechat; // 微信
FOUNDATION_EXTERN NSString *_Nonnull const MMPlatformNameAlipay; // 支付宝

/******************************没有图片、待补充***********************************************/
// FOUNDATION_EXTERN NSString *_Nonnull const  MMPlatformNameTwitter;//推特
// FOUNDATION_EXTERN NSString *_Nonnull const  MMPlatformNameFacebook;//脸书
// FOUNDATION_EXTERN NSString *_Nonnull const  MMPlatformNameInstagram;//instagram
// FOUNDATION_EXTERN NSString *_Nonnull const  MMPlatformNameNotes;//备忘录
// FOUNDATION_EXTERN NSString *_Nonnull const  MMPlatformNameReminders;//提醒事项
// FOUNDATION_EXTERN NSString *_Nonnull const  MMPlatformNameiCloud;//iCloud

// 预制的分享事件
FOUNDATION_EXTERN NSString *_Nonnull const MMPlatformHandleSina;      // 新浪微博
FOUNDATION_EXTERN NSString *_Nonnull const MMPlatformHandleQQ;        // QQ
FOUNDATION_EXTERN NSString *_Nonnull const MMPlatformHandleEmail;     // 邮箱
FOUNDATION_EXTERN NSString *_Nonnull const MMPlatformHandleSms;       // 短信
FOUNDATION_EXTERN NSString *_Nonnull const MMPlatformHandleWechat;    // 微信
FOUNDATION_EXTERN NSString *_Nonnull const MMPlatformHandleAlipay;    // 支付宝
FOUNDATION_EXTERN NSString *_Nonnull const MMPlatformHandleTwitter;   // 推特
FOUNDATION_EXTERN NSString *_Nonnull const MMPlatformHandleFacebook;  // 脸书
FOUNDATION_EXTERN NSString *_Nonnull const MMPlatformHandleInstagram; // instagram
FOUNDATION_EXTERN NSString *_Nonnull const MMPlatformHandleNotes;     // 备忘录
FOUNDATION_EXTERN NSString *_Nonnull const MMPlatformHandleReminders; // 提醒事项
FOUNDATION_EXTERN NSString *_Nonnull const MMPlatformHandleiCloud;    // iCloud

@interface MMShareItem : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, weak) UIViewController *presentVC;
@property (nonatomic, copy) ShareHandle action;

@property (nullable, nonatomic, strong) NSString *shareText;
@property (nullable, nonatomic, strong) UIImage *shareImage;
@property (nullable, nonatomic, strong) NSURL *shareUrl;

/*
 * 调用以下代码获取手机中装的App的所有Share Extension的ServiceType

 SLComposeViewController *composeVc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];

 * 我获得的部分数据

 com.taobao.taobao4iphone.ShareExtension  淘宝
 com.apple.share.Twitter.post  推特
 com.apple.share.Facebook.post 脸书
 com.apple.share.SinaWeibo.post 新浪微博
 com.apple.share.Flickr.post 雅虎
 com.burbn.instagram.shareextension   instagram
 com.amazon.AmazonCN.AWListShareExtension 亚马逊
 com.apple.share.TencentWeibo.post 腾讯微博
 com.smartisan.notes.SMShare 锤子便签
 com.zhihu.ios.Share 知乎
 com.tencent.mqq.ShareExtension QQ
 com.tencent.xin.sharetimeline 微信
 com.alipay.iphoneclient.ExtensionSchemeShare 支付宝
 com.apple.mobilenotes.SharingExtension  备忘录
 com.apple.reminders.RemindersEditorExtension 提醒事项
 com.apple.Health.HealthShareExtension      健康
 com.apple.mobileslideshow.StreamShareService  iCloud

 */

- (instancetype)initWithImage:(UIImage *)image
                        title:(NSString *)title
                       action:(ShareHandle)action;

- (instancetype)initWithImage:(UIImage *)image
                        title:(NSString *)title
                   actionName:(NSString *)actionName;

- (instancetype)initWithPlatformName:(NSString *)platformName;

@end

NS_ASSUME_NONNULL_END
