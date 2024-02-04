//
//  ZWDokitLog.h
//  My_Study
//
//  Created by hzw on 2024/2/2.
//  Copyright © 2024 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#import <CocoaLumberjack/CocoaLumberjack.h>
#define LOG_LEVEL_DEF ddLogLevel
static const int ddLogLevel = DDLogLevelDebug;
#else
static const int ddLogLevel = DDLogLevelInfo;
#endif

NS_ASSUME_NONNULL_BEGIN

@interface ZWDokitLog : NSObject


/// 添加日志
/// - Parameter log: 日志内容
+ (void)infoLog:(id)log;

/// 添加日志
/// - Parameters:
///   - log: 日志内容
///   - tag: 添加标签,区分日志使用
+ (void)infoLog:(id)log tag:(NSString * _Nullable)tag;


@end

NS_ASSUME_NONNULL_END
