//
//  MMShareItem.m
//  My_Study
//
//  Created by Zhiwei Han on 2023/2/8.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "MMShareItem.h"
#import "UIApplication+Ext.h"
#import "MMShareActionManager.h"

NSString *const MMPlatformNameSina   = @"MMPlatformNameSina";
NSString *const MMPlatformNameQQ     = @"MMPlatformNameQQ";
NSString *const MMPlatformNameEmail  = @"MMPlatformNameEmail";
NSString *const MMPlatformNameSms    = @"MMPlatformNameSms";
NSString *const MMPlatformNameWechat = @"MMPlatformNameWechat";
NSString *const MMPlatformNameAlipay = @"MMPlatformNameAlipay";
// NSString *const  MMPlatformNameTwitter = @"MMPlatformNameTwitter";
// NSString *const  MMPlatformNameFacebook = @"MMPlatformNameFacebook";
// NSString *const  MMPlatformNameInstagram = @"MMPlatformNameInstagram";
// NSString *const  MMPlatformNameNotes = @"MMPlatformNameNotes";
// NSString *const  MMPlatformNameReminders = @"MMPlatformNameReminders";
// NSString *const  MMPlatformNameiCloud = @"MMPlatformNameiCloud";

NSString *const MMPlatformHandleSina      = @"MMPlatformHandleSina";
NSString *const MMPlatformHandleQQ        = @"MMPlatformHandleQQ";
NSString *const MMPlatformHandleEmail     = @"MMPlatformHandleEmail";
NSString *const MMPlatformHandleSms       = @"MMPlatformHandleSms";
NSString *const MMPlatformHandleWechat    = @"MMPlatformHandleWechat";
NSString *const MMPlatformHandleAlipay    = @"MMPlatformHandleAlipay";
NSString *const MMPlatformHandleTwitter   = @"MMPlatformHandleTwitter";
NSString *const MMPlatformHandleFacebook  = @"MMPlatformHandleFacebook";
NSString *const MMPlatformHandleInstagram = @"MMPlatformHandleInstagram";
NSString *const MMPlatformHandleNotes     = @"MMPlatformHandleNotes";
NSString *const MMPlatformHandleReminders = @"MMPlatformHandleReminders";
NSString *const MMPlatformHandleiCloud    = @"MMPlatformHandleiCloud";


#define MM_IMAGE_KEY                   @"image"
#define MM_TITLE_KEY                   @"title"
#define MM_ACTION_KEY                  @"action"

@interface MMShareItem ()

@end

@implementation MMShareItem

#pragma mark - 初始化方法

- (instancetype)initWithImage:(UIImage *)image
                        title:(NSString *)title
                       action:(ShareHandle)action {
    NSParameterAssert(title.length || image);

    self = [super init];
    if (self) {
        _title  = title;
        _image  = image;
        _action = action;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
                        title:(NSString *)title
                   actionName:(NSString *)actionName {
    self = [super init];
    if (self) {
        _title  = title;
        _image  = image;
        _action = [self actionFromString:actionName];
    }
    return self;
}

- (instancetype)initWithPlatformName:(NSString *)platformName {
    /******************************各种平台***********************************************/
    NSDictionary *messageDict;
    if ([platformName isEqualToString:MMPlatformNameSina]) {
        messageDict = @{MM_IMAGE_KEY: @"share_sina", MM_TITLE_KEY: @"新浪微博", MM_ACTION_KEY: MMPlatformHandleSina};
    }
    if ([platformName isEqualToString:MMPlatformNameQQ]) {
        messageDict = @{MM_IMAGE_KEY: @"share_qq", MM_TITLE_KEY: @"QQ", MM_ACTION_KEY: MMPlatformHandleQQ};
    }
    if ([platformName isEqualToString:MMPlatformNameEmail]) {
        messageDict = @{MM_IMAGE_KEY: @"share_email", MM_TITLE_KEY: @"邮件", MM_ACTION_KEY: MMPlatformHandleEmail};
    }
    if ([platformName isEqualToString:MMPlatformNameSms]) {
        messageDict = @{MM_IMAGE_KEY: @"share_sms", MM_TITLE_KEY: @"短信", MM_ACTION_KEY: MMPlatformHandleSms};
    }
    if ([platformName isEqualToString:MMPlatformNameWechat]) {
        messageDict = @{MM_IMAGE_KEY: @"share_weixin", MM_TITLE_KEY: @"微信", MM_ACTION_KEY: MMPlatformHandleWechat};
    }
    if ([platformName isEqualToString:MMPlatformNameAlipay]) {
        messageDict = @{MM_IMAGE_KEY: @"share_alipay", MM_TITLE_KEY: @"支付宝", MM_ACTION_KEY: MMPlatformHandleAlipay};
    }

    /*********************************end************************************************/

    self = [super init];
    if (self) {
        _title  = (messageDict[MM_TITLE_KEY] ? messageDict[MM_TITLE_KEY] : @"");
//        _image  = [UIImage imageNamed:[@"MMShareImage.bundle" stringByAppendingPathComponent:messageDict[MM_IMAGE_KEY]]];
        _image  = [UIImage imageNamed:messageDict[MM_IMAGE_KEY]];
        _action = [self actionFromString:messageDict[MM_ACTION_KEY]];
    }
    return self;
}

#pragma mark - 私有方法

// 字符串转 Block
- (ShareHandle)actionFromString:(NSString *)handleName {
    ShareHandle handle           = ^(MMShareItem *item) {
        [[MMShareActionManager sharedInstance] handleShareItemAction:handleName shareItem:item];
    };
    return handle;
}

@end

