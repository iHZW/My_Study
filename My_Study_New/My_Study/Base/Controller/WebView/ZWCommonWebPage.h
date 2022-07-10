//
//  ZWCommonWebPage.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/26.
//  Copyright © 2022 HZW. All rights reserved.
//
/** webView  */
#import "ZWBaseViewController.h"
#import "ZWWebView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWCommonWebPage : ZWBaseViewController

@property (nonatomic, strong, readonly) ZWWebView *webView;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *titleName;

/** 加载url  */
- (void)loadUrlString:(NSString *)urlString;

- (void)getCurrRoutePathCompletionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler;

//WMNative 内存地址
- (NSString *)apiGroup;

@end

NS_ASSUME_NONNULL_END
