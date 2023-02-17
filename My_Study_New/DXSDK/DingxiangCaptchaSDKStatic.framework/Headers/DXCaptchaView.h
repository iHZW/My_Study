//
//  DXCaptchaView.h
//  DingxiangCaptchaSDK
//
//  Created by xelz on 2017/9/25.
//  Copyright © 2017年  All rights reserved.
//

#import <WebKit/WebKit.h>
#import "DXCaptchaDelegate.h"

@interface DXCaptchaView : WKWebView

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration NS_UNAVAILABLE;

- (instancetype)initWithConfig:(NSDictionary *)config delegate:(id<DXCaptchaDelegate>)delegate frame:(CGRect)frame;
- (instancetype)initWithAppId:(NSString *)appId delegate:(id<DXCaptchaDelegate>)delegate frame:(CGRect)frame;

@end
