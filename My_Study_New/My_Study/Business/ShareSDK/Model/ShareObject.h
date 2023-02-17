//
//  ShareObject.h
//  My_Study
//
//  Created by Zhiwei Han on 2023/2/7.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "ShareParam.h"
#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString *_Nonnull const MM_SHARE_NAME_WECHAT;         // 微信
FOUNDATION_EXTERN NSString *_Nonnull const MM_SHARE_NAME_WECHAT_MOMENTS; // 微信朋友圈
FOUNDATION_EXTERN NSString *_Nonnull const MM_SHARE_NAME_QQ;             // QQ
FOUNDATION_EXTERN NSString *_Nonnull const MM_SHARE_NAME_SMS;            // SMS
FOUNDATION_EXTERN NSString *_Nonnull const MM_SHARE_NAME_WECHAT_WORK;    // 企业微信
FOUNDATION_EXTERN NSString *_Nonnull const MM_SHARE_NAME_MINI_PROGRAM;   // 小程序

NS_ASSUME_NONNULL_BEGIN

@interface ShareObject : NSObject
/** 分享平台 */
@property (nonatomic, copy) NSString *name;
/** 要显示的平台名称 */
@property (nonatomic, copy) NSString *nameCN;
/** 平台logo */
@property (nonatomic, copy) NSString *logoIconUrl;

@property (nonatomic, strong) ShareParam *shareParam;

@end

NS_ASSUME_NONNULL_END
