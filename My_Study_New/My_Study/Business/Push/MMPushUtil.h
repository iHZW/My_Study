//
//  MMPushUtil.h
//  My_Study
//
//  Created by hzw on 2023/2/17.
//  Copyright © 2023 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMPushUtil : NSObject

+ (void)AlertControllerWithTitle:(NSString *)title andMessage:(NSString *)message;

+ (BOOL)PushModel;

+ (void)SetPushModel:(BOOL)mode;

+ (NSString *)getHexStringForData:(NSData *)data;

+ (NSString *)formateTime:(NSDate *)date;

+ (void)pushLocalNotification:(NSString *)title userInfo:(NSDictionary *)userInfo;

/// 用户打开事项提醒后，取消同一事件尚未触发的连续提醒。
+ (BOOL)cancelContinuousReminderForUserInfo:(NSDictionary *)userInfo;

@end

NS_ASSUME_NONNULL_END
