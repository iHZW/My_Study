//
//  ZWClearWebViewCache.m
//  My_Study
//
//  Created by Zhiwei Han on 2023/4/27.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "ZWClearWebViewCache.h"
#import <WebKit/WebKit.h>

@implementation ZWClearWebViewCache

+ (instancetype)sharedInstance {
    static ZWClearWebViewCache *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

#pragma mark--  清理WKWebView的缓存
- (void)clearWKWebViewCache {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        /**< 清理所有webview的缓存*/
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{}];
    } else {
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        NSError *errors;
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
    }

    [self cleanWebview];
}

- (void)cleanWebview {
    // 清除cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    // 清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    //    [[NSURLSession sharedSession] resetWithCompletionHandler:^{
    //
    //    }];
    [[NSURLSession sharedSession] flushWithCompletionHandler:^{

    }];
}

@end
