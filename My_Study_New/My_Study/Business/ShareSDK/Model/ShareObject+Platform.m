//
//  ShareObject+Platform.m
//  My_Study
//
//  Created by Zhiwei Han on 2023/2/7.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "ShareObject+Platform.h"

@implementation ShareObject (Platform)

+ (NSString *)wechatName {
    return MM_SHARE_NAME_WECHAT;
}

+ (NSString *)wechatMomentsName {
    return MM_SHARE_NAME_WECHAT_MOMENTS;
}

+ (NSString *)qqName {
    return MM_SHARE_NAME_QQ;
}

+ (NSString *)smsName {
    return MM_SHARE_NAME_SMS;
}

+ (NSString *)weChatWorkName {
    return MM_SHARE_NAME_WECHAT_WORK;
}

- (BOOL)isWechat {
    return [self.name isEqualToString:[ShareObject wechatName]];
}
/** 朋友圈 */
- (BOOL)isWechatMoments {
    return [self.name isEqualToString:[ShareObject wechatMomentsName]];
}
/** QQ */
- (BOOL)isQQ {
    return [self.name isEqualToString:[ShareObject qqName]];
}
/** 短信 */
- (BOOL)isSMS {
    return [self.name isEqualToString:[ShareObject smsName]];
}

/**是否是企业微信*/
- (BOOL)isWeChatWork {
    return [self.name isEqualToString:[ShareObject weChatWorkName]];
}

#pragma mark -
/** 文字分享 */
- (BOOL)isText {
    ShareParam *shareParam = self.shareParam;
    return ![self isImage] && ![self isWeb] && shareParam.desc.length > 0;
}
/** 图片分享 */
- (BOOL)isImage {
    ShareParam *shareParam = self.shareParam;
    return ![self isWeb] && (shareParam.imgUrl.length > 0 || self.shareParam.img != nil);
}
/** 图文URL分享 */
- (BOOL)isWeb {
    ShareParam *shareParam = self.shareParam;
    return shareParam.linkUrl.length > 0;
}

/** 小程序分享 */
- (BOOL)isMiniProgram {
    ShareParam *shareParam = self.shareParam;
    return shareParam.miniProgramID.length > 0;
}

- (BOOL)isMiniProgramApp {
    return [self.name isEqualToString:MM_SHARE_NAME_MINI_PROGRAM];
}
@end
