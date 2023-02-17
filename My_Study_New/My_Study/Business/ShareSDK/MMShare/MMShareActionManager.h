//
//  MMShareActionManager.h
//  My_Study
//
//  Created by Zhiwei Han on 2023/2/8.
//  Copyright © 2023 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMShareItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface MMShareActionManager : NSObject

+ (instancetype)sharedInstance;


/// 处理分享view中的item点击
/// - Parameters:
///   - handleName: 回调名称
///   - shareItem: 分享item
- (void)handleShareItemAction:(NSString *)handleName shareItem:(MMShareItem *)shareItem;


/// 处理发送邮件
/// - Parameters:
///   - email: 邮件地址
///   - shareText: 分享文本
///   - shareUrl: 分享链接
///   - shareImage: 分享图片
- (void)sendmailTO:(NSString *)email
         shareText:(NSString *)shareText
          shareUrl:(NSString *)shareUrl
        shareImage:(UIImage *)shareImage;


/// 发送信息
/// - Parameters:
///   - phoneNum: 手机号
///   - shareText: 分享文本
///   - shareUrl: 分享链接
- (void)sendMessageTO:(NSString *)phoneNum
            shareText:(NSString *)shareText
             shareUrl:(NSString *)shareUrl;

@end

NS_ASSUME_NONNULL_END
