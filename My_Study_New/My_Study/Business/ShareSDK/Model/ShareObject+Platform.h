//
//  ShareObject+Platform.h
//  My_Study
//
//  Created by Zhiwei Han on 2023/2/7.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "ShareObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface ShareObject (Platform)
+ (NSString *)wechatName;
+ (NSString *)wechatMomentsName;
+ (NSString *)qqName;
+ (NSString *)smsName;
+ (NSString *)weChatWorkName; // 企业微信

/** 微信*/
- (BOOL)isWechat;
/** 朋友圈 */
- (BOOL)isWechatMoments;
/** QQ */
- (BOOL)isQQ;
/** 短信 */
- (BOOL)isSMS;
/** 企业微信*/
- (BOOL)isWeChatWork;

/** 文字分享 */
- (BOOL)isText;
/** 图片分享 */
- (BOOL)isImage;
/** 图文URL分享 */
- (BOOL)isWeb;
/** 小程序分享 */
- (BOOL)isMiniProgram;

/** 拉起小程序 */
- (BOOL)isMiniProgramApp;
@end

NS_ASSUME_NONNULL_END
