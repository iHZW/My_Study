//
//  MMPushManager.m
//  My_Study
//
//  Created by hzw on 2023/2/17.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "MMPushManager.h"
#import <GTSDK/GeTuiSdk.h>
#import "MMPushUtil.h"

// GTSDK 配置信息
#define kGtAppId @"xXmjbbab3b5F1m7wAYZoG2"
#define kGtAppKey @"BZF4dANEYr8dwLhj6lRfx2"
#define kGtAppSecret @"yXRS5zRxDt8WhMW8DD8W05"


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
@interface MMPushManager () <GeTuiSdkDelegate, UNUserNotificationCenterDelegate>
#else
@interface MMPushManager () <GeTuiSdkDelegate>
#endif


@end



@implementation MMPushManager

+ (instancetype)sharedInstance {
    static MMPushManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}


- (void)startGTSDKOptions:(NSDictionary *)launchOptions {
    // [ GTSDK ]：是否允许APP后台运行
    //    [GeTuiSdk runBackgroundEnable:YES];
    
    // [ GTSDK ]：是否运行电子围栏Lbs功能和是否SDK主动请求用户定位
    //    [GeTuiSdk lbsLocationEnable:YES andUserVerify:YES];
    
    // [ GTSDK ]：自定义渠道
    //    [GeTuiSdk setChannelId:@"GT-Channel"];
    
    // [ GTSDK ]：使用APPID/APPKEY/APPSECRENT启动个推
    [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self launchingOptions:launchOptions];
    
    // [ 参考代码，开发者注意根据实际需求自行修改 ] 注册远程通知
    if (@available(iOS 10.0, *)) {
        [GeTuiSdk registerRemoteNotification: (UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge)];
    }
    
    // [ GTSDK ]：设置Group标识，通知扩展中也要设置[GeTuiExtSdk setApplicationGroupIdentifier:];
    // 用于回执统计
    [GeTuiSdk setApplicationGroupIdentifier:@"group.ent.com.getui.demo"];
    
}



////MARK: - 远程通知(推送)回调
//
///// [ 系统回调 ] 远程通知注册成功回调，获取DeviceToken成功，同步给个推服务器
//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//    // [ GTSDK ]：向个推服务器注册deviceToken
//    // 2.5.2.0 之前版本需要调用：
//    //[GeTuiSdk registerDeviceTokenData:deviceToken];
//    
//    NSString *token = [MMPushUtil getHexStringForData:deviceToken];
//    NSLog(@"token = %@", token);
//    
//    NSString *errorMsg = [NSString stringWithFormat:@"[ My_Study ] [ DeviceToken(NSString) ]: %@\n\n", token];
//    NSLog(@"errorMsg = %@", errorMsg);
//}
//
///// [ 系统回调:可选 ] 远程通知注册失败回调，获取DeviceToken失败，打印错误信息
//- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
//    NSString *msg = [NSString stringWithFormat:@"[ My_Study ] %@: %@", NSStringFromSelector(_cmd), error.localizedDescription];
//    NSLog(@"msg = %@", msg);
//
//}

//MARK: - GeTuiSdkDelegate


/// [ GTSDK回调 ] SDK启动成功返回cid
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    NSString *msg = [NSString stringWithFormat:@"[ My_Study ] [GTSdk RegisterClient]:%@", clientId];
    NSLog(@"GeTuiSdkDidRegisterClient = %@", msg);
}

/// [ GTSDK回调 ] SDK运行状态通知
- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)aStatus {
    NSLog(@"GeTuiSDkDidNotifySdkState = %@", @(aStatus));
//    [[NSNotificationCenter defaultCenter] postNotificationName:GTSdkStateNotification object:self];
}

- (void)GeTuiSdkDidOccurError:(NSError *)error {
    NSString *msg = [NSString stringWithFormat:@"[ My_Study ] [GeTuiSdk GeTuiSdkDidOccurError]:%@\n\n",error.localizedDescription];
    NSLog(@"GeTuiSdkDidOccurError = %@", msg);
}


//MARK: - 通知回调

/// 通知授权结果（iOS10及以上版本）
/// @param granted 用户是否允许通知
/// @param error 错误信息
- (void)GetuiSdkGrantAuthorization:(BOOL)granted error:(NSError *)error {
    NSString *msg = [NSString stringWithFormat:@"[ My_Study ] [APNs] %@ \n%@ %@", NSStringFromSelector(_cmd), @(granted), error];
    NSLog(@"GetuiSdkGrantAuthorization = %@", msg);
}

/// 通知展示（iOS10及以上版本）
/// @param center center
/// @param notification notification
/// @param completionHandler completionHandler
- (void)GeTuiSdkNotificationCenter:(UNUserNotificationCenter *)center
           willPresentNotification:(UNNotification *)notification
                 completionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)){
    NSString *msg = [NSString stringWithFormat:@"[ My_Study ] [APNs] %@ \n%@", NSStringFromSelector(_cmd), notification.request.content.userInfo];
    NSLog(@"GeTuiSdkNotificationCenter = %@", msg);
    // [ 参考代码，开发者注意根据实际需求自行修改 ] 根据APP需要，判断是否要提示用户Badge、Sound、Alert等
    //completionHandler(UNNotificationPresentationOptionNone); 若不显示通知，则无法点击通知
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}
 
/// 收到通知信息
/// @param userInfo apns通知内容
/// @param center UNUserNotificationCenter（iOS10及以上版本）
/// @param response UNNotificationResponse（iOS10及以上版本）
/// @param completionHandler 用来在后台状态下进行操作（iOS10以下版本）
- (void)GeTuiSdkDidReceiveNotification:(NSDictionary *)userInfo
                    notificationCenter:(UNUserNotificationCenter *)center
                              response:(UNNotificationResponse *)response
                fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler  API_AVAILABLE(ios(10.0)){
    NSString *msg = [NSString stringWithFormat:@"[ My_Study ] [APNs] %@ \n%@", NSStringFromSelector(_cmd), userInfo];
    NSLog(@"GeTuiSdkDidReceiveNotification = %@", msg);
    if(completionHandler) {
        // [ 参考代码，开发者注意根据实际需求自行修改 ] 根据APP需要自行修改参数值
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

/// 收到透传消息
/// @param userInfo    推送消息内容
/// @param fromGetui   YES: 个推通道  NO：苹果apns通道
/// @param offLine     是否是离线消息，YES.是离线消息
/// @param appId       应用的appId
/// @param taskId      推送消息的任务id
/// @param msgId       推送消息的messageid
/// @param completionHandler 用来在后台状态下进行操作（通过苹果apns通道的消息 才有此参数值）
- (void)GeTuiSdkDidReceiveSlience:(NSDictionary *)userInfo
                        fromGetui:(BOOL)fromGetui
                          offLine:(BOOL)offLine
                            appId:(NSString *)appId
                           taskId:(NSString *)taskId
                            msgId:(NSString *)msgId
           fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // [ GTSDK ]：汇报个推自定义事件(反馈透传消息)，开发者可以根据项目需要决定是否使用, 非必须
    // [GeTuiSdk sendFeedbackMessage:90001 andTaskId:taskId andMsgId:msgId];
    NSString *msg = [NSString stringWithFormat:@"[ My_Study ] [APN] %@ \nReceive Slience: fromGetui:%@ appId:%@ offLine:%@ taskId:%@ msgId:%@ userInfo:%@ ", NSStringFromSelector(_cmd), fromGetui ? @"个推消息" : @"APNs消息", appId, offLine ? @"离线" : @"在线", taskId, msgId, userInfo];
    NSLog(@"GeTuiSdkDidReceiveSlience = %@", msg);

    //本地通知UserInfo参数
    NSDictionary *dic = nil;
    if (fromGetui) {
        //个推在线透传
        dic = @{@"_gmid_": [NSString stringWithFormat:@"%@:%@", taskId ?: @"", msgId ?: @""]};
    } else {
        //APNs静默通知
        dic = userInfo;
    }
    if (fromGetui && offLine == NO) {
        //个推通道+在线，发起本地通知
        [MMPushUtil pushLocalNotification:userInfo[@"payload"] userInfo:dic];
    }
    if(completionHandler) {
        // [ 参考代码，开发者注意根据实际需求自行修改 ] 根据APP需要自行修改参数值
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (void)GeTuiSdkNotificationCenter:(UNUserNotificationCenter *)center
       openSettingsForNotification:(UNNotification *)notification  API_AVAILABLE(ios(10.0)){
    // [ 参考代码，开发者注意根据实际需求自行修改 ] 根据APP需要自行修改参数值
}


//MARK: - 发送上行消息

/// [ GTSDK回调 ] SDK收到sendMessage消息回调
- (void)GeTuiSdkDidSendMessage:(NSString *)messageId result:(BOOL)isSuccess error:(NSError *)aError {
    NSString *msg = [NSString stringWithFormat:@"[ My_Study ] [GeTuiSdk DidSendMessage]: \nReceive sendmessage:%@ result:%d error:%@", messageId, isSuccess, aError];
    NSLog(@"GeTuiSdkDidSendMessage = %@", msg);
}




@end
