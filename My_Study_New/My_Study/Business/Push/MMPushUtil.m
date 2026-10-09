//
//  MMPushUtil.m
//  My_Study
//
//  Created by hzw on 2023/2/17.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "MMPushUtil.h"
#import <GTSDK/GeTuiSdk.h>
#import <CYLTabBarController/NSObject+CYLTabBarControllerExtention.h>
#import <UserNotifications/UserNotifications.h>


@implementation MMPushUtil

+ (void)AlertControllerWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction          = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:sureAction];
//    if ([[[UIApplication sharedApplication] delegate] isKindOfClass:[AppDelegate class]]) {
//        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        [delegate.homePage presentViewController:alertController animated:YES completion:nil];
//    }
    [[NSObject cyl_topmostViewController] presentViewController:alertController animated:YES completion:nil];
}

+ (BOOL)PushModel {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"OffPushMode"];
}

+ (void)SetPushModel:(BOOL)mode {
    [[NSUserDefaults standardUserDefaults] setBool:mode forKey:@"OffPushMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getHexStringForData:(NSData *)data {
    NSUInteger len             = [data length];
    char *chars                = (char *)[data bytes];
    NSMutableString *hexString = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < len; i++) {
        [hexString appendString:[NSString stringWithFormat:@"%0.2hhx", chars[i]]];
    }
    return hexString;
}

/// 时间转字符串
+ (NSString *)formateTime:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:date];
    return dateTime;
}

+ (void)pushLocalNotification:(NSString *)title userInfo:(NSDictionary *)userInfo {
    /*本地通知无法触发通知扩展， 官网文档：
     A UNNotificationServiceExtension object provides the entry point for a Notification Service app extension, which lets you customize the content of a remote notification before it is delivered to the user.
     */
    if (@available(iOS 10.0, *)) {
        //        UNMutableNotificationContent *content = [UNMutableNotificationContent new];
        //        content.title                         = title;
        //        content.subtitle                      = [NSString stringWithFormat:@"副标题:%@", title];
        //        content.body                          = title;
        //        content.userInfo                      = userInfo;
        //        UNNotificationRequest *req            = [UNNotificationRequest requestWithIdentifier:@"id1" content:content trigger:nil];
        //        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:req withCompletionHandler:^(NSError *_Nullable error) {
        //            NSLog(@"addNotificationRequest added");
        //        }];

        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = @"NotificationCenter";
        content.subtitle = @"testWord";
        content.body = @"本地通知测试";
        UNTimeIntervalNotificationTrigger *triger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
        NSString *requestIdentifier = @"request";
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:triger];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error){

        }];

    } else {
        // Fallback on earlier versions
    }
}

+ (BOOL)cancelContinuousReminderForUserInfo:(NSDictionary *)userInfo {
    if (![[userInfo objectForKey:@"type"] isEqualToString:@"scheduled_reminder"]) return NO;

    NSString *eventID = [userInfo objectForKey:@"reminder_event_id"];
    if (!eventID.length) return YES;

    NSMutableArray<NSString *> *identifiers = [NSMutableArray arrayWithCapacity:4];
    for (NSInteger index = 0; index < 4; index++) {
        [identifiers addObject:[NSString stringWithFormat:@"crm.reminder.%@.%ld", eventID, (long)index]];
    }
    UNUserNotificationCenter *center = UNUserNotificationCenter.currentNotificationCenter;
    [center removePendingNotificationRequestsWithIdentifiers:identifiers];
    [center removeDeliveredNotificationsWithIdentifiers:identifiers];
    // 再按事件标识扫描一次，兼容后续调整重复次数或历史版本生成的标识。
    [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> *requests) {
        NSMutableArray<NSString *> *matchedIdentifiers = [NSMutableArray array];
        for (UNNotificationRequest *request in requests) {
            NSString *requestEventID = [request.content.userInfo objectForKey:@"reminder_event_id"];
            if ([requestEventID isEqualToString:eventID]) [matchedIdentifiers addObject:request.identifier];
        }
        if (matchedIdentifiers.count) {
            [center removePendingNotificationRequestsWithIdentifiers:matchedIdentifiers];
        }
    }];
    NSLog(@"已取消事项 %@ 的后续连续提醒", eventID);
    return YES;
}

@end
