//
//  DispatchMessageCenter.h
//  PASecuritiesApp
//
//  Created by Howard on 16/3/2.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMNotificationCenter.h"


/**
 *  通知名称键值
 */
extern NSString const * kNotifyNameKey;

/**
 *  通知传递用户信息键值
 */
extern NSString const * kNotifyUserInfoKey;

/**
 *  通知传递对象键值
 */
extern NSString const * kNotifyObjectKey;

/**
 *  消息中心对象
 */
extern NSString const * kNotifyCenterKey;


@interface DispatchMessageCenter : NSObject

/**
 *  指定通知中心创建消息分发中心
 *
 *  @param notifCenter 消息中心
 *
 *  @return 消息分发中心对象
 */
- (instancetype)initWithMessageCenter:(CMNotificationCenter *)notifCenter;

/**
 *  分发消息
 *
 *  @param notifMsg {kNotifyNameKey:xxx, kNotifyUserInfoKey:xxx, kNotifyObjectKey:xxx}
 */
- (void)dispatchMessageWithUserInfo:(NSDictionary *)notifMsg;

/**
 *  分发消息
 *
 *  @param notifCenter 指定CMNotificationCenter
 *  @param notifMsg    {kNotifyCenterKey:xxx,kNotifyObjectKey:xxx, kNotifyNameKey:xxx, kNotifyUserInfoKey:xxx, kNotifyObjectKey:xxx}
 */
+ (void)dispatchMessageWithUserInfo:(CMNotificationCenter *)notifCenter notifMsg:(NSDictionary *)notifMsg;


@end
