#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTUtils.h>
#import <WebKit/WebKit.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

static NSString * const LXWebBrowserLastURLKey = @"LXWebBrowserLastURL";

static UIColor *LXWebColor(CGFloat red, CGFloat green, CGFloat blue) {
  return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1.0];
}

@interface LXWebBrowserViewController : UIViewController <WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIButton *siteButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, copy) NSArray<NSString *> *siteNames;
@property (nonatomic, copy) NSArray<NSString *> *siteURLs;
+ (UINavigationController *)persistentNavigationController;
@end

@implementation LXWebBrowserViewController

+ (UINavigationController *)persistentNavigationController {
  // 浏览器只在首次使用时创建，并由应用进程持续持有；关闭页面不会销毁网页和浏览历史。
  static UINavigationController *navigationController;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    LXWebBrowserViewController *browser = [[LXWebBrowserViewController alloc] init];
    navigationController = [[UINavigationController alloc] initWithRootViewController:browser];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    navigationController.modalPresentationCapturesStatusBarAppearance = YES;
  });
  return navigationController;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = LXWebColor(244, 248, 247);
  [self.navigationController setNavigationBarHidden:YES animated:NO];
  [self.navigationController setToolbarHidden:YES animated:NO];

  self.siteNames = @[@"VIP影视", @"VIP电影院", @"剧迷", @"80s电影", @"片库",
                     @"全景影院", @"牛牛影院", @"豌豆影院", @"鸭奈飞影视",
                     @"电影导航网", @"万能搜", @"YouTube Music", @"DeepSeek", @"AICode"];
  self.siteURLs = @[@"https://dhuangmi.com/",
                    @"https://www.xierizhi.cn/vod/tv/Q4Fpb07mRzHnNX.html",
                    @"https://gimy.video/",
                    @"https://www.bj-qdcg.com/",
                    @"https://www.qwshu.com/ms/1--hits---------.html",
                    @"https://www.quanjingyy.com/",
                    @"http://www.yhmjt.com/",
                    @"http://www.283bt.com/",
                    @"https://yanetflix.com/",
                    @"http://www.sody123.com/",
                    @"https://www.ahhhhfs.com/",
                    @"https://music.youtube.com",
                    @"https://chat.deepseek.com",
                    @"http://116.62.212.112:3000/playground"];

  UIView *headerView = [[UIView alloc] init];
  headerView.translatesAutoresizingMaskIntoConstraints = NO;
  headerView.backgroundColor = LXWebColor(244, 248, 247);
  [self.view addSubview:headerView];

  UIButton *closeButton = [self roundButtonWithTitle:@"‹" action:@selector(closeBrowser)];
  closeButton.titleLabel.font = [UIFont systemFontOfSize:34 weight:UIFontWeightLight];
  closeButton.accessibilityLabel = @"关闭网页浏览";
  [headerView addSubview:closeButton];

  self.titleLabel = [[UILabel alloc] init];
  self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
  self.titleLabel.text = @"网页浏览";
  self.titleLabel.textColor = LXWebColor(48, 91, 99);
  self.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
  self.titleLabel.textAlignment = NSTextAlignmentCenter;
  self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  [headerView addSubview:self.titleLabel];

  self.siteButton = [UIButton buttonWithType:UIButtonTypeSystem];
  self.siteButton.translatesAutoresizingMaskIntoConstraints = NO;
  self.siteButton.backgroundColor = LXWebColor(226, 239, 240);
  self.siteButton.layer.cornerRadius = 16;
  self.siteButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
  [self.siteButton setTitle:@"网站  ▾" forState:UIControlStateNormal];
  [self.siteButton setTitleColor:LXWebColor(70, 137, 157) forState:UIControlStateNormal];
  [self.siteButton addTarget:self action:@selector(showSiteMenu) forControlEvents:UIControlEventTouchUpInside];
  [headerView addSubview:self.siteButton];

  self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
  self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
  self.progressView.progressTintColor = LXWebColor(91, 161, 179);
  self.progressView.trackTintColor = UIColor.clearColor;
  self.progressView.hidden = YES;
  [self.view addSubview:self.progressView];

  WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
  configuration.allowsInlineMediaPlayback = YES;
  self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
  self.webView.translatesAutoresizingMaskIntoConstraints = NO;
  self.webView.navigationDelegate = self;
  self.webView.allowsBackForwardNavigationGestures = YES;
  self.webView.backgroundColor = LXWebColor(244, 248, 247);
  self.webView.opaque = NO;
  [self.view addSubview:self.webView];

  UIView *controlBar = [[UIView alloc] init];
  controlBar.translatesAutoresizingMaskIntoConstraints = NO;
  controlBar.backgroundColor = UIColor.whiteColor;
  controlBar.layer.cornerRadius = 22;
  controlBar.layer.shadowColor = [LXWebColor(47, 88, 95) colorWithAlphaComponent:0.18].CGColor;
  controlBar.layer.shadowOpacity = 1;
  controlBar.layer.shadowRadius = 12;
  controlBar.layer.shadowOffset = CGSizeMake(0, 4);
  [self.view addSubview:controlBar];

  self.backButton = [self controlButtonWithTitle:@"‹" action:@selector(goBack) accessibilityLabel:@"后退"];
  self.forwardButton = [self controlButtonWithTitle:@"›" action:@selector(goForward) accessibilityLabel:@"前进"];
  UIButton *refreshButton = [self controlButtonWithTitle:@"↻" action:@selector(refreshPage) accessibilityLabel:@"刷新"];
  UIStackView *controlStack = [[UIStackView alloc] initWithArrangedSubviews:@[self.backButton, refreshButton, self.forwardButton]];
  controlStack.translatesAutoresizingMaskIntoConstraints = NO;
  controlStack.axis = UILayoutConstraintAxisHorizontal;
  controlStack.alignment = UIStackViewAlignmentFill;
  controlStack.distribution = UIStackViewDistributionFillEqually;
  [controlBar addSubview:controlStack];

  UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
  [NSLayoutConstraint activateConstraints:@[
    [headerView.topAnchor constraintEqualToAnchor:safeArea.topAnchor],
    [headerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
    [headerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    [headerView.heightAnchor constraintEqualToConstant:58],
    [closeButton.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:16],
    [closeButton.centerYAnchor constraintEqualToAnchor:headerView.centerYAnchor],
    [closeButton.widthAnchor constraintEqualToConstant:40],
    [closeButton.heightAnchor constraintEqualToConstant:40],
    [self.siteButton.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor constant:-16],
    [self.siteButton.centerYAnchor constraintEqualToAnchor:headerView.centerYAnchor],
    [self.siteButton.widthAnchor constraintEqualToConstant:82],
    [self.siteButton.heightAnchor constraintEqualToConstant:34],
    [self.titleLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:closeButton.trailingAnchor constant:10],
    [self.titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.siteButton.leadingAnchor constant:-10],
    [self.titleLabel.centerXAnchor constraintEqualToAnchor:headerView.centerXAnchor],
    [self.titleLabel.centerYAnchor constraintEqualToAnchor:headerView.centerYAnchor],
    [self.progressView.topAnchor constraintEqualToAnchor:headerView.bottomAnchor],
    [self.progressView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
    [self.progressView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    [self.progressView.heightAnchor constraintEqualToConstant:2],
    [controlBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
    [controlBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
    [controlBar.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor constant:-10],
    [controlBar.heightAnchor constraintEqualToConstant:56],
    [controlStack.topAnchor constraintEqualToAnchor:controlBar.topAnchor constant:4],
    [controlStack.leadingAnchor constraintEqualToAnchor:controlBar.leadingAnchor constant:8],
    [controlStack.trailingAnchor constraintEqualToAnchor:controlBar.trailingAnchor constant:-8],
    [controlStack.bottomAnchor constraintEqualToAnchor:controlBar.bottomAnchor constant:-4],
    [self.webView.topAnchor constraintEqualToAnchor:self.progressView.bottomAnchor],
    [self.webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
    [self.webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    [self.webView.bottomAnchor constraintEqualToAnchor:controlBar.topAnchor constant:-10],
  ]];

  [self updateNavigationItems];

  NSString *savedURL = [NSUserDefaults.standardUserDefaults stringForKey:LXWebBrowserLastURLKey];
  [self loadURLString:savedURL.length > 0 ? savedURL : self.siteURLs.firstObject remember:NO];
}

- (UIButton *)roundButtonWithTitle:(NSString *)title action:(SEL)action {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
  button.translatesAutoresizingMaskIntoConstraints = NO;
  button.backgroundColor = LXWebColor(231, 239, 238);
  button.layer.cornerRadius = 14;
  [button setTitle:title forState:UIControlStateNormal];
  [button setTitleColor:LXWebColor(48, 91, 99) forState:UIControlStateNormal];
  [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
  return button;
}

- (UIButton *)controlButtonWithTitle:(NSString *)title
                              action:(SEL)action
                  accessibilityLabel:(NSString *)accessibilityLabel {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
  button.titleLabel.font = [UIFont systemFontOfSize:29 weight:UIFontWeightRegular];
  [button setTitle:title forState:UIControlStateNormal];
  [button setTitleColor:LXWebColor(70, 137, 157) forState:UIControlStateNormal];
  [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
  button.accessibilityLabel = accessibilityLabel;
  return button;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  if (@available(iOS 13.0, *)) return UIStatusBarStyleDarkContent;
  return UIStatusBarStyleDefault;
}

- (void)closeBrowser {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)goBack {
  if (self.webView.canGoBack) [self.webView goBack];
}

- (void)goForward {
  if (self.webView.canGoForward) [self.webView goForward];
}

- (void)refreshPage {
  [self.webView reload];
}

- (void)updateNavigationItems {
  self.backButton.enabled = self.webView.canGoBack;
  self.forwardButton.enabled = self.webView.canGoForward;
  self.backButton.alpha = self.backButton.enabled ? 1.0 : 0.28;
  self.forwardButton.alpha = self.forwardButton.enabled ? 1.0 : 0.28;
}

- (void)showSiteMenu {
  UIAlertController *menu = [UIAlertController alertControllerWithTitle:@"切换网站"
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
  __weak typeof(self) weakSelf = self;
  [self.siteNames enumerateObjectsUsingBlock:^(NSString *name, NSUInteger index, BOOL *stop) {
    [menu addAction:[UIAlertAction actionWithTitle:name
                                             style:UIAlertActionStyleDefault
                                           handler:^(__unused UIAlertAction *action) {
      [weakSelf loadURLString:weakSelf.siteURLs[index] remember:YES];
    }]];
  }];
  [menu addAction:[UIAlertAction actionWithTitle:@"自定义网址…"
                                           style:UIAlertActionStyleDefault
                                         handler:^(__unused UIAlertAction *action) {
    [weakSelf showCustomURLInput];
  }]];
  [menu addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
  menu.popoverPresentationController.sourceView = self.siteButton;
  menu.popoverPresentationController.sourceRect = self.siteButton.bounds;
  [self presentViewController:menu animated:YES completion:nil];
}

- (void)showCustomURLInput {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"自定义网址"
                                                                  message:@"未填写协议时默认使用 https://"
                                                           preferredStyle:UIAlertControllerStyleAlert];
  NSString *savedURL = [NSUserDefaults.standardUserDefaults stringForKey:LXWebBrowserLastURLKey];
  [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    textField.placeholder = @"例如：https://example.com";
    textField.text = savedURL;
    textField.keyboardType = UIKeyboardTypeURL;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
  }];
  [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
  __weak typeof(self) weakSelf = self;
  __weak UIAlertController *weakAlert = alert;
  [alert addAction:[UIAlertAction actionWithTitle:@"打开"
                                            style:UIAlertActionStyleDefault
                                          handler:^(__unused UIAlertAction *action) {
    NSString *urlString = [weakSelf normalizedURLString:weakAlert.textFields.firstObject.text];
    if (urlString.length > 0) {
      [weakSelf loadURLString:urlString remember:YES];
    } else {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)),
                     dispatch_get_main_queue(), ^{ [weakSelf showInvalidURLAlert]; });
    }
  }]];
  [self presentViewController:alert animated:YES completion:nil];
}

- (NSString *)normalizedURLString:(NSString *)input {
  NSString *urlString = [input stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
  if (urlString.length == 0) return nil;
  if ([urlString rangeOfString:@"://"].location == NSNotFound) {
    urlString = [@"https://" stringByAppendingString:urlString];
  }
  NSURLComponents *components = [NSURLComponents componentsWithString:urlString];
  NSString *scheme = components.scheme.lowercaseString;
  if ((![scheme isEqualToString:@"http"] && ![scheme isEqualToString:@"https"]) ||
      components.host.length == 0) return nil;
  return components.URL.absoluteString;
}

- (void)loadURLString:(NSString *)urlString remember:(BOOL)remember {
  NSString *normalizedURL = [self normalizedURLString:urlString];
  if (normalizedURL.length == 0) {
    [self showInvalidURLAlert];
    return;
  }
  if (remember) [NSUserDefaults.standardUserDefaults setObject:normalizedURL forKey:LXWebBrowserLastURLKey];
  [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:normalizedURL]]];
}

- (void)showInvalidURLAlert {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"网址无效"
                                                                  message:@"请输入有效的 HTTP 或 HTTPS 网址。"
                                                           preferredStyle:UIAlertControllerStyleAlert];
  [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  self.titleLabel.text = webView.title.length > 0 ? webView.title : @"网页浏览";
  [self.progressView setProgress:1 animated:YES];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
    self.progressView.hidden = YES;
    self.progressView.progress = 0;
  });
  [self updateNavigationItems];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
  self.titleLabel.text = @"正在加载…";
  self.progressView.hidden = NO;
  [self.progressView setProgress:0.18 animated:NO];
  [self updateNavigationItems];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
  [self.progressView setProgress:0.7 animated:YES];
  [self updateNavigationItems];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
  self.progressView.hidden = YES;
  [self updateNavigationItems];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
  self.progressView.hidden = YES;
  [self updateNavigationItems];
}

@end

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

RCT_EXPORT_METHOD(openWebBrowser) {
  dispatch_async(dispatch_get_main_queue(), ^{
    UIViewController *controller = RCTPresentedViewController();
    if (!controller) return;

    UINavigationController *navigationController =
        [LXWebBrowserViewController persistentNavigationController];
    if (navigationController.presentingViewController || navigationController.view.window ||
        controller == navigationController || controller.navigationController == navigationController) return;

    [controller presentViewController:navigationController animated:YES completion:nil];
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
