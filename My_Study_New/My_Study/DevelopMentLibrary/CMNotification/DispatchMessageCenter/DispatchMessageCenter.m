//
//  DispatchMessageCenter.m
//  PASecuritiesApp
//
//  Created by Howard on 16/3/2.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "DispatchMessageCenter.h"

/**
 *  通知名称键值
 */
NSString const * kNotifyNameKey         = @"notifyName";

/**
 *  通知传递用户信息键值
 */
NSString const * kNotifyUserInfoKey     = @"notifyUserInfo";

/**
 *  通知传递对象键值
 */
NSString const * kNotifyObjectKey       = @"notifyObject";

/**
 *  消息中心对象
 */
NSString const * kNotifyCenterKey       = @"notifyCenter";


@interface DispatchMessageCenter ()

@property (nonatomic, strong) CMNotificationCenter *notifCenter;
@property (nonatomic, copy) NSString *msgName;

@end


@implementation DispatchMessageCenter

- (void)dealloc
{
    if (self.notifCenter)
        [self.notifCenter removeObserver:self];
    
}

/**
 *  指定通知中心创建消息分发中心
 *
 *  @param notifCenter 消息中心
 *
 *  @return 消息分发中心对象
 */
- (instancetype)initWithMessageCenter:(CMNotificationCenter *)notifCenter
{
    self = [super init];
    
    if (self)
    {
        self.notifCenter    = notifCenter;
    }
    
    return self;
}

/**
 *  分发消息
 *
 *  @param notifMsg {kNotifyNameKey:xxx, kNotifyUserInfoKey:xxx, kNotifyObjectKey:xxx}
 */
- (void)dispatchMessageWithUserInfo:(NSDictionary *)notifMsg
{
    [DispatchMessageCenter dispatchMessageWithUserInfo:self.notifCenter notifMsg:notifMsg];
}

/**
 *  分发消息
 *
 *  @param notifCenter 指定CMNotificationCenter
 *  @param notifMsg    {kNotifyNameKey:xxx, kNotifyUserInfoKey:xxx, kNotifyObjectKey:xxx}
 */
+ (void)dispatchMessageWithUserInfo:(CMNotificationCenter *)notifCenter notifMsg:(NSDictionary *)notifMsg
{
    NSString *name          = notifMsg[kNotifyNameKey];
    id obj                  = notifMsg[kNotifyObjectKey];
    NSDictionary *userInfo  = notifMsg[kNotifyUserInfoKey];
    
    [notifCenter postNotificationName:name object:obj userInfo:userInfo];
}

@end
