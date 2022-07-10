//
//  ZWNative.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMObject.h"
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

#define WMBlockSafeRun(block, ...) block ? block(__VA_ARGS__) : nil

// js交互类

typedef void(^EvaluateJSBlock)(NSString *);
typedef void(^WebViewGoBackBlock)(void);
typedef void(^WebViewExitBlock)(void);
typedef void(^WebViewDateWheelBlock)(NSDictionary *);
typedef void(^WebViewFullScreenBlock)(BOOL);
typedef void(^WebViewInteractivePopBlock)(BOOL);
typedef void(^WebViewSetSizeBlock)(NSDictionary *);
typedef void(^WebViewStatusBarStyleBlock)(UIStatusBarStyle);


@interface ZWNative : CMObject

@property (nonatomic ,copy) EvaluateJSBlock calljsBlock;
@property (nonatomic ,copy) WebViewGoBackBlock goBackBlock;
@property (nonatomic ,copy) WebViewExitBlock exitBlock;
@property (nonatomic ,copy) WebViewDateWheelBlock dateWheelBlock;
@property (nonatomic, copy) WebViewFullScreenBlock fullScreenBlock;
@property (nonatomic, copy) WebViewInteractivePopBlock interactivePopBlock;
@property (nonatomic, copy) WebViewSetSizeBlock setSizeBlock;
@property (nonatomic, copy) WebViewStatusBarStyleBlock statusBarStyleBlock;

/**   */
- (BOOL)checkJsRequest:(nullable NSURLRequest *)request webView:(WKWebView *)webView;

// return 回调h5的格式化数据
- (NSString *)getParamStr:(NSString *)key
                     code:(NSNumber *)code
                     data:(id)data
                  message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
