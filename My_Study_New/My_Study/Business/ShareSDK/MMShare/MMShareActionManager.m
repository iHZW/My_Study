//
//  MMShareActionManager.m
//  My_Study
//
//  Created by Zhiwei Han on 2023/2/8.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "MMShareActionManager.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import "UIApplication+Ext.h"
#import "MMShareManager.h"

@interface MMShareActionManager () <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@end

@implementation MMShareActionManager

+ (instancetype)sharedInstance {
    static MMShareActionManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MMShareActionManager alloc] init];
    });
    return _instance;
}


- (void)handleShareItemAction:(NSString *)handleName shareItem:(MMShareItem *)shareItem {
    NSString *tipPlatform;
    if ([handleName isEqualToString:MMPlatformHandleEmail]) {
        [[MMShareActionManager sharedInstance] sendmailTO:@"" shareText:shareItem.shareText shareUrl:[NSString stringWithFormat:@"%@", shareItem.shareUrl] shareImage:shareItem.image];
        return;
    }
    if ([handleName isEqualToString:MMPlatformHandleSms]) {
        [[MMShareActionManager sharedInstance] sendMessageTO:@"" shareText:shareItem.shareText shareUrl:[NSString stringWithFormat:@"%@", shareItem.shareUrl]];
        return;
    }
    /******************************各种平台***********************************************/
    NSString *platformID;
    if ([handleName isEqualToString:MMPlatformHandleSina]) {
        platformID  = @"com.apple.share.SinaWeibo.post";
        tipPlatform = @"新浪微博";
    }
    if ([handleName isEqualToString:MMPlatformHandleQQ]) {
        platformID  = @"com.tencent.mqq.ShareExtension";
        tipPlatform = @"QQ";
    }
    if ([handleName isEqualToString:MMPlatformHandleWechat]) {
        platformID  = @"com.tencent.xin.sharetimeline";
        tipPlatform = @"微信";
        
        
    }
    if ([handleName isEqualToString:MMPlatformHandleAlipay]) {
        platformID  = @"com.alipay.iphoneclient.ExtensionSchemeShare";
        tipPlatform = @"支付宝";
    }
    if ([handleName isEqualToString:MMPlatformHandleTwitter]) {
        platformID  = @"com.apple.share.Twitter.post";
        tipPlatform = @"推特";
    }
    if ([handleName isEqualToString:MMPlatformHandleFacebook]) {
        platformID  = @"com.apple.share.Facebook.post";
        tipPlatform = @"脸书";
    }
    if ([handleName isEqualToString:MMPlatformHandleInstagram]) {
        platformID  = @"com.burbn.instagram.shareextension";
        tipPlatform = @"instagram";
    }
    if ([handleName isEqualToString:MMPlatformHandleNotes]) {
        platformID  = @"com.apple.mobilenotes.SharingExtension";
        tipPlatform = @"备忘录";
    }
    if ([handleName isEqualToString:MMPlatformHandleReminders]) {
        platformID  = @"com.apple.reminders.RemindersEditorExtension";
        tipPlatform = @"提醒事项";
    }
    if ([handleName isEqualToString:MMPlatformHandleiCloud]) {
        platformID  = @"com.apple.mobileslideshow.StreamShareService";
        tipPlatform = @"iCloud";
    }
}


#pragma mark - 邮件
- (void)sendmailTO:(NSString *)email
         shareText:(NSString *)shareText
          shareUrl:(NSString *)shareUrl
        shareImage:(UIImage *)shareImage {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        [controller setToRecipients:@[email]];
        if (shareText) {
            [controller setSubject:shareText];
        }
        if (shareUrl) {
            [controller setMessageBody:[NSString stringWithFormat:@"%@", shareUrl] isHTML:YES];
        }
        if (shareImage) {
            NSData *imageData = UIImagePNGRepresentation(shareImage);
            [controller addAttachmentData:imageData mimeType:@"image/png" fileName:@"图片.png"];
        }
        [controller setMailComposeDelegate:self];
        [[UIApplication displayViewController] presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - 短信
- (void)sendMessageTO:(NSString *)phoneNum
            shareText:(NSString *)shareText
             shareUrl:(NSString *)shareUrl {
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        [controller setRecipients:@[phoneNum]];
        NSString *bodySting = @"";
        if (shareText) {
            bodySting = [bodySting stringByAppendingString:shareText];
        }
        if (shareUrl) {
            bodySting = [bodySting stringByAppendingString:shareUrl];
        }
        controller.body                    = bodySting; // 此处的body就是短信将要发生的内容
        controller.navigationBar.tintColor = [UIColor redColor];
        controller.messageComposeDelegate  = self;
        [[UIApplication displayViewController] presentViewController:controller animated:YES completion:nil];
    }
}


#pragma mark - 微信
- (void)handleShareWechatAction {
    ShareParam *shareParam = [ShareParam new];
    shareParam.desc = @"测试说明";

    ShareObject *model = [[ShareObject alloc] init];
    model.name = @"Wechat";
    model.shareParam = shareParam;
    [MMShareManager shareObject:model complete:^(BOOL y, NSError * _Nullable error) {
//        [Toast show:error.localizedDescription];
    }];
}


#pragma mark - 朋友圈
- (void)handleShareWechatMomentsAction {
    
}




#pragma mark - 邮件、短息代理方法
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [[UIApplication displayViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [[UIApplication displayViewController] dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MessageComposeResultSent:
            // 信息传送成功
            break;
        case MessageComposeResultFailed:
            // 信息传送失败
            break;
        case MessageComposeResultCancelled:
            // 信息被用户取消传送
            break;
        default:
            break;
    }
}

@end
