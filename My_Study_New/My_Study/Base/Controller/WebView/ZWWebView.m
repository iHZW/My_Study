//
//  ZWWebView.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/26.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWWebView.h"
#import "WKWebViewConfiguration+Conslog.h"
#import "JSWeakObject.h"
#import <objc/runtime.h>

@interface ZWWebView ()<JSWeakObjectDeleaget>

@end

@implementation ZWWebView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorFromRGB(0xFFFFFF);
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration{
    if(self = [super initWithFrame:frame configuration:configuration]){

        // 默认是NO，这个值决定了用内嵌HTML5播放视频还是用本地的全屏控制
        configuration.allowsInlineMediaPlayback = NO;
        // 自动播放, 不需要用户采取任何手势开启播放
        // WKAudiovisualMediaTypeNone 音视频的播放不需要用户手势触发, 即为自动播放
        if (@available(iOS 10.0, *)) {
            configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
        } else {
            
        }
        configuration.allowsAirPlayForMediaPlayback = YES;
        configuration.allowsPictureInPictureMediaPlayback = YES;
        configuration.requiresUserActionForMediaPlayback = YES;
        
        if (configuration.showConsole) {
            WKUserContentController *userCC = configuration.userContentController;
            
            JSWeakObject * weakObject = [[JSWeakObject alloc]init];
            weakObject.delegate = self;
            
            [userCC addScriptMessageHandler:weakObject name:@"log"];
            [self showConsole];
        }
        [ZWWebView allowDisplayingKeyboardWithoutUserAction];
    }
    return self;
}

- (void)showConsole {
    
    //rewrite the method of console.log
//    NSString *jsCode = @"console.log = (function(oriLogFunc){\
//    return function(str)\
//    {\
//    window.webkit.messageHandlers.log.postMessage(str);\
//    oriLogFunc.call(console,str);\
//    }\
//    })(console.log);";
    
    NSString *jsCode = @"console.log = (function(oriLogFunc) {return function(str) { if (Object.prototype.toString.call(str) === \"[object String]\"){window.webkit.messageHandlers.log.postMessage(str);}else {window.webkit.messageHandlers.log.postMessage(JSON.stringify(str));}oriLogFunc.call(console, str);}})(console.log);";

    //injected the method when H5 starts to create the DOM tree
    [self.configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
}

- (void)WkUserContentView:(WKUserContentController *)contentView didReceiveScriptMessage:(WKScriptMessage *)message{
    [LogUtil debug:[NSString stringWithFormat:@"[javaScrip-Conslog] \n ======= %@",message.body] flag:@"console" context:self];
}


+ (void)allowDisplayingKeyboardWithoutUserAction {
    Class class = NSClassFromString(@"WKContentView");
    NSOperatingSystemVersion iOS_11_3_0 = (NSOperatingSystemVersion){11, 3, 0};
    NSOperatingSystemVersion iOS_12_2_0 = (NSOperatingSystemVersion){12, 2, 0};
    NSOperatingSystemVersion iOS_13_0_0 = (NSOperatingSystemVersion){13, 0, 0};
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_13_0_0]) {
        SEL selector = sel_getUid("_elementDidFocus:userIsInteracting:blurPreviousNode:activityStateChanges:userObject:");
        Method method = class_getInstanceMethod(class, selector);
        IMP original = method_getImplementation(method);
        IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, BOOL arg3, id arg4) {
        ((void (*)(id, SEL, void*, BOOL, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3, arg4);
        });
        method_setImplementation(method, override);
    }
   else if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_12_2_0]) {
        SEL selector = sel_getUid("_elementDidFocus:userIsInteracting:blurPreviousNode:changingActivityState:userObject:");
        Method method = class_getInstanceMethod(class, selector);
        IMP original = method_getImplementation(method);
        IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, BOOL arg3, id arg4) {
        ((void (*)(id, SEL, void*, BOOL, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3, arg4);
        });
        method_setImplementation(method, override);
    }
    else if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_11_3_0]) {
        SEL selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:changingActivityState:userObject:");
        Method method = class_getInstanceMethod(class, selector);
        IMP original = method_getImplementation(method);
        IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, BOOL arg3, id arg4) {
            ((void (*)(id, SEL, void*, BOOL, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3, arg4);
        });
        method_setImplementation(method, override);
    } else {
        SEL selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:");
        Method method = class_getInstanceMethod(class, selector);
        IMP original = method_getImplementation(method);
        IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, id arg3) {
            ((void (*)(id, SEL, void*, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3);
        });
        method_setImplementation(method, override);
    }
}

//WKWebview 全屏显示方法， (替代contentInset， 导致页面滚动上去不下来)
- (UIEdgeInsets)safeAreaInsets{
    return UIEdgeInsetsZero;
}



@end
