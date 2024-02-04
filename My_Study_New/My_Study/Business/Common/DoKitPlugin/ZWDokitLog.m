//
//  ZWDokitLog.m
//  My_Study
//
//  Created by hzw on 2024/2/2.
//  Copyright © 2024 HZW. All rights reserved.
//

#import "ZWDokitLog.h"
#import "YYModel/YYModel.h"

@implementation ZWDokitLog

/// 添加日志
/// - Parameter log: 日志内容
+ (void)infoLog:(id)log {
    [ZWDokitLog infoLog:log tag:nil];
}

/// 添加日志
/// - Parameters:
///   - log: 日志内容
///   - tag: 添加标签,区分日志使用
+ (void)infoLog:(id)log tag:(NSString *)tag {
#ifdef DEBUG
    NSString *logInfo = @"";
    if ([log isKindOfClass:NSString.class]) {
        logInfo = log;
    } else {
        logInfo = [log yy_modelToJSONString];
    }
    if (!(logInfo && logInfo.length > 0)) return;

    if (ValidString(logInfo)) {
        logInfo = [NSString stringWithFormat:@"%@%@", tag ?: @"", logInfo];
        DDLogInfo(logInfo);
    }
#endif
}

@end
