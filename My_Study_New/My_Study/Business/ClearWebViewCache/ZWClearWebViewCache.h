//
//  ZWClearWebViewCache.h
//  My_Study
//
//  Created by Zhiwei Han on 2023/4/27.
//  Copyright © 2023 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZWClearWebViewCache : NSObject

+ (instancetype)sharedInstance;

/**< 清理WKWebView的缓存 */
- (void)clearWKWebViewCache;

@end

NS_ASSUME_NONNULL_END
