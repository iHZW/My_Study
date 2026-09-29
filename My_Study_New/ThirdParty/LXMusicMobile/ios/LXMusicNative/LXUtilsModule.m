#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTUtils.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

@interface LXUtilsModule : RCTEventEmitter
@property (nonatomic, assign) BOOL keepAwake;
@property (nonatomic, strong) UIView *toastView;
@property (nonatomic, assign) NSUInteger toastGeneration;
@property (nonatomic, assign) BOOL hasEventListeners;
@end

@implementation LXUtilsModule

RCT_EXPORT_MODULE(UtilsModule)

+ (BOOL)requiresMainQueueSetup { return YES; }

- (NSArray<NSString *> *)supportedEvents {
  return @[@"screen-state", @"screen-size-changed"];
}

- (void)startObserving {
  self.hasEventListeners = YES;
}

- (void)stopObserving {
  self.hasEventListeners = NO;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(screenDidChange:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [center addObserver:self selector:@selector(screenDidChange:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center addObserver:self selector:@selector(windowDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  if (_keepAwake) {
    dispatch_async(dispatch_get_main_queue(), ^{ UIApplication.sharedApplication.idleTimerDisabled = NO; });
  }
}

- (void)screenDidChange:(NSNotification *)notification {
  if (!self.hasEventListeners) return;
  NSString *state = [notification.name isEqualToString:UIApplicationDidBecomeActiveNotification] ? @"ON" : @"OFF";
  [self sendEventWithName:@"screen-state" body:@{ @"state": state }];
}

- (NSDictionary *)windowSize {
  CGSize size = UIScreen.mainScreen.bounds.size;
  return @{ @"width": @(size.width), @"height": @(size.height) };
}

- (void)windowDidChange:(NSNotification *)notification {
  if (!self.hasEventListeners) return;
  [self sendEventWithName:@"screen-size-changed" body:[self windowSize]];
}

RCT_EXPORT_METHOD(listenWindowSizeChanged) {
  dispatch_async(dispatch_get_main_queue(), ^{ [self windowDidChange:nil]; });
}

RCT_EXPORT_METHOD(screenkeepAwake) {
  dispatch_async(dispatch_get_main_queue(), ^{
    self.keepAwake = YES;
    UIApplication.sharedApplication.idleTimerDisabled = YES;
  });
}

RCT_EXPORT_METHOD(screenUnkeepAwake) {
  dispatch_async(dispatch_get_main_queue(), ^{
    self.keepAwake = NO;
    UIApplication.sharedApplication.idleTimerDisabled = NO;
  });
}

RCT_REMAP_METHOD(getWIFIIPV4Address, wifiAddressWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  struct ifaddrs *interfaces = NULL;
  NSString *address = @"0.0.0.0";
  if (getifaddrs(&interfaces) == 0) {
    for (struct ifaddrs *entry = interfaces; entry != NULL; entry = entry->ifa_next) {
      if (entry->ifa_addr && entry->ifa_addr->sa_family == AF_INET &&
          strcmp(entry->ifa_name, "en0") == 0) {
        char buffer[INET_ADDRSTRLEN];
        struct sockaddr_in *ipv4 = (struct sockaddr_in *)entry->ifa_addr;
        if (inet_ntop(AF_INET, &ipv4->sin_addr, buffer, sizeof(buffer))) {
          address = [NSString stringWithUTF8String:buffer];
        }
        break;
      }
    }
    freeifaddrs(interfaces);
  }
  resolve(address);
}

RCT_REMAP_METHOD(getDeviceName, deviceNameWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  dispatch_async(dispatch_get_main_queue(), ^{ resolve(UIDevice.currentDevice.name); });
}

RCT_REMAP_METHOD(getSupportedAbis, supportedAbisWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
#if defined(__arm64__)
  resolve(@[@"arm64"]);
#else
  resolve(@[@"x86_64"]);
#endif
}

RCT_REMAP_METHOD(getWindowSize, windowSizeWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  dispatch_async(dispatch_get_main_queue(), ^{ resolve([self windowSize]); });
}

RCT_REMAP_METHOD(isNotificationsEnabled, notificationsEnabledWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  [UNUserNotificationCenter.currentNotificationCenter getNotificationSettingsWithCompletionHandler:
   ^(UNNotificationSettings *settings) { resolve(@(settings.authorizationStatus == UNAuthorizationStatusAuthorized ||
                                                   settings.authorizationStatus == UNAuthorizationStatusProvisional)); }];
}

RCT_REMAP_METHOD(getNotificationPermissionStatus, notificationPermissionStatusWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  [UNUserNotificationCenter.currentNotificationCenter getNotificationSettingsWithCompletionHandler:
   ^(UNNotificationSettings *settings) {
    switch (settings.authorizationStatus) {
      case UNAuthorizationStatusNotDetermined:
        resolve(@"notDetermined");
        break;
      case UNAuthorizationStatusAuthorized:
      case UNAuthorizationStatusProvisional:
        resolve(@"authorized");
        break;
      case UNAuthorizationStatusDenied:
      default:
        resolve(@"denied");
        break;
    }
  }];
}

RCT_REMAP_METHOD(requestNotificationAuthorization, requestNotificationAuthorizationWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  UNAuthorizationOptions options = UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
  [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:options
                                                                     completionHandler:^(BOOL granted, NSError *error) {
    if (error) {
      reject(@"notification_permission_error", error.localizedDescription, error);
      return;
    }
    resolve(@(granted));
  }];
}

RCT_REMAP_METHOD(openNotificationPermissionActivity, openNotificationSettingsWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  dispatch_async(dispatch_get_main_queue(), ^{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [UIApplication.sharedApplication openURL:url options:@{} completionHandler:^(BOOL success) { resolve(@(success)); }];
  });
}

RCT_EXPORT_METHOD(shareText:(NSString *)shareTitle title:(NSString *)title text:(NSString *)text) {
  dispatch_async(dispatch_get_main_queue(), ^{
    UIViewController *controller = RCTPresentedViewController();
    if (!controller) return;
    UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:@[text ?: @""]
                                                                      applicationActivities:nil];
    share.popoverPresentationController.sourceView = controller.view;
    share.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(controller.view.bounds),
                                                                 CGRectGetMidY(controller.view.bounds), 1, 1);
    [controller presentViewController:share animated:YES completion:nil];
  });
}

RCT_EXPORT_METHOD(showToast:(NSString *)message duration:(NSString *)duration position:(NSString *)position) {
  dispatch_async(dispatch_get_main_queue(), ^{
    UIWindow *window = RCTPresentedViewController().view.window ?: UIApplication.sharedApplication.keyWindow;
    if (!window || message.length == 0) return;
    [self.toastView removeFromSuperview];
    self.toastGeneration++;
    NSUInteger generation = self.toastGeneration;

    CGFloat maxWidth = MAX(160, CGRectGetWidth(window.bounds) - 48);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = message;
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    CGSize textSize = [label sizeThatFits:CGSizeMake(maxWidth - 32, CGFLOAT_MAX)];
    CGFloat width = MIN(maxWidth, MAX(96, textSize.width + 32));
    CGFloat height = MAX(40, textSize.height + 20);
    CGFloat centerY = CGRectGetMidY(window.bounds);
    if ([position isEqualToString:@"top"]) centerY = window.safeAreaInsets.top + 80;
    else if ([position isEqualToString:@"bottom"]) {
      centerY = CGRectGetHeight(window.bounds) - window.safeAreaInsets.bottom - 80;
    }
    UIView *toast = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(window.bounds) - width) / 2,
                                                             centerY - height / 2, width, height)];
    toast.backgroundColor = [UIColor colorWithWhite:0.12 alpha:0.88];
    toast.layer.cornerRadius = 12;
    toast.clipsToBounds = YES;
    toast.userInteractionEnabled = NO;
    label.frame = CGRectInset(toast.bounds, 16, 10);
    [toast addSubview:label];
    [window addSubview:toast];
    self.toastView = toast;
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message);

    NSTimeInterval seconds = [duration isEqualToString:@"long"] ? 3.5 : 2.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
      if (generation != self.toastGeneration) return;
      [UIView animateWithDuration:0.2 animations:^{ toast.alpha = 0; }
                       completion:^(BOOL finished) { [toast removeFromSuperview]; }];
    });
  });
}

RCT_REMAP_METHOD(getSystemLocales, systemLocalesWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  NSString *locale = NSLocale.preferredLanguages.firstObject ?: @"";
  resolve([[locale stringByReplacingOccurrencesOfString:@"-" withString:@"_"] lowercaseString]);
}

RCT_REMAP_METHOD(isIgnoringBatteryOptimization, batteryOptimizationWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  // iOS 没有 Android 的电池优化白名单；返回已满足，避免引导用户前往不存在的设置项。
  resolve(@YES);
}

RCT_REMAP_METHOD(requestIgnoreBatteryOptimization, requestBatteryOptimizationWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(@YES);
}

RCT_REMAP_METHOD(installApk, installApk:(NSString *)filePath authority:(NSString *)authority
                 resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  reject(@"ios_unsupported", @"iOS 不支持安装 APK", nil);
}

RCT_EXPORT_METHOD(exitApp) {
  // iOS 不允许应用主动退出；由界面导航处理返回。
}

@end
