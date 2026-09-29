//
//  ZWWebView.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/26.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <TDWebViewSwipeBack/UIViewController+GCWebViewSwipeBack.h>

NS_ASSUME_NONNULL_BEGIN

// 注入方法导出js的conslog

@interface ZWWebView : WKWebView<GCWebViewSwipeBackProtocol>

+ (void)allowDisplayingKeyboardWithoutUserAction;

@end

NS_ASSUME_NONNULL_END
