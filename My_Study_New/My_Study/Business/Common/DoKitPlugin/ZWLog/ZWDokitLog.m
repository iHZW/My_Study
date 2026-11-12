#import "ZWDokitLog.h"

@implementation ZWDokitLog
+ (BOOL)isSensitiveKey:(NSString *)key {
    NSString *name = key.lowercaseString;
    for (NSString *word in @[@"password", @"passwd", @"pwd", @"token", @"authorization", @"cookie", @"secret"]) {
        if ([name containsString:word]) return YES;
    }
    return NO;
}

+ (id)sanitize:(id)value depth:(NSUInteger)depth {
    if (!value) return NSNull.null;
    if (depth > 8) return @"<超过日志嵌套上限>";
    if ([value isKindOfClass:NSDictionary.class]) {
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        NSUInteger count = 0;
        for (id key in value) {
            if (count++ >= 100) { result[@"日志截断"] = @YES; break; }
            NSString *name = [key description];
            result[name] = [self isSensitiveKey:name] ? @"***" : [self sanitize:value[key] depth:depth + 1];
        }
        return result;
    }
    if ([value isKindOfClass:NSArray.class]) {
        NSMutableArray *result = [NSMutableArray array];
        for (id item in value) {
            if (result.count >= 50) { [result addObject:@"<数组已截断>"]; break; }
            [result addObject:[self sanitize:item depth:depth + 1]];
        }
        return result;
    }
    if ([value isKindOfClass:NSData.class]) {
        if ([value length] > 16384) return [NSString stringWithFormat:@"<数据 %lu 字节，未展开>", (unsigned long)[value length]];
        id json = [NSJSONSerialization JSONObjectWithData:value options:NSJSONReadingFragmentsAllowed error:NULL];
        return json ? [self sanitize:json depth:depth + 1] : [NSString stringWithFormat:@"<二进制 %lu 字节>", (unsigned long)[value length]];
    }
    if ([value isKindOfClass:NSString.class]) {
        // 参数中的嵌套 URL 同样需要处理敏感查询项。
        NSString *text = value;
        if ([text containsString:@"://"]) {
            NSURLComponents *url = [NSURLComponents componentsWithString:text];
            if (url.host.length) {
                url.user = nil; url.password = nil;
                NSMutableArray *items = [NSMutableArray array];
                for (NSURLQueryItem *item in url.queryItems) {
                    NSString *content = item.value;
                    if ([self isSensitiveKey:item.name]) content = @"***";
                    else if ([item.name isEqualToString:@"param"]) {
                        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
                        id json = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL] : nil;
                        if (json) {
                            NSData *safe = [NSJSONSerialization dataWithJSONObject:[self sanitize:json depth:depth + 1] options:NSJSONWritingFragmentsAllowed error:NULL];
                            content = [[NSString alloc] initWithData:safe encoding:NSUTF8StringEncoding];
                        }
                    }
                    [items addObject:[NSURLQueryItem queryItemWithName:item.name value:content]];
                }
                if (url.query) url.queryItems = items;
                text = url.string ?: text;
            }
        }
        return text.length > 2048 ? [[text substringToIndex:2048] stringByAppendingString:@"<已截断>"] : text;
    }
    if ([value isKindOfClass:NSNumber.class] || value == NSNull.null) return value;
    return [NSString stringWithFormat:@"<%@>", NSStringFromClass([value class])];
}

+ (id)sanitizedValue:(id)value { return [self sanitize:value depth:0]; }

+ (NSString *)prettyJSON:(id)value {
    NSData *data = [NSJSONSerialization dataWithJSONObject:value ?: @{} options:NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys | NSJSONWritingFragmentsAllowed error:NULL];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"{}";
}

+ (NSString *)formattedEvent:(NSString *)event category:(NSString *)category fields:(NSDictionary *)fields {
    NSDictionary *safe = [self sanitizedValue:fields];
    NSString *text;
    if ([category isEqualToString:@"Router"]) {
        NSArray *types = @[@"push", @"present", @"Tab", @"action"];
        NSUInteger type = [safe[@"type"] unsignedIntegerValue];
        NSMutableString *message = [NSMutableString stringWithFormat:@"%@\n结果：%@\n方式：%@\n路径：%@\n目标页面：%@\n入参：\n%@",
            [safe[@"path"] length] ? safe[@"path"] : event, safe[@"result"] ?: event, type < types.count ? types[type] : @"未知",
            safe[@"path"] ?: @"", safe[@"target"] ?: @"", [self prettyJSON:safe[@"parameters"] ?: @{}]];
        if (safe[@"message"]) [message appendFormat:@"\n说明：%@", safe[@"message"]];
        if (safe[@"errorDomain"]) [message appendFormat:@"\n错误域：%@\n错误码：%@", safe[@"errorDomain"], safe[@"errorCode"] ?: @0];
        text = message;
    } else if ([category isEqualToString:@"Network"]) {
        NSMutableString *message = [NSMutableString stringWithFormat:@"%@ %@\n结果：%@\n请求编号：%@\n状态码：%@\n耗时：%.2f ms\n请求头：\n%@\n入参（Query）：\n%@\n入参（Body）：\n%@\n响应头：\n%@\n响应：\n%@",
            safe[@"method"] ?: @"HTTP", safe[@"url"] ?: safe[@"path"] ?: @"",
            event, safe[@"requestId"] ?: @"", safe[@"status"] ?: @0, [safe[@"durationMs"] doubleValue],
            [self prettyJSON:safe[@"headers"] ?: @{}], [self prettyJSON:safe[@"query"] ?: @{}],
            [self prettyJSON:safe[@"body"] ?: NSNull.null], [self prettyJSON:safe[@"responseHeaders"] ?: @{}],
            [self prettyJSON:safe[@"response"] ?: NSNull.null]];
        if (safe[@"message"]) [message appendFormat:@"\n说明：%@", safe[@"message"]];
        if ([safe[@"errorDomain"] length] || [safe[@"errorCode"] integerValue]) {
            [message appendFormat:@"\n错误域：%@\n错误码：%@", safe[@"errorDomain"] ?: @"", safe[@"errorCode"] ?: @0];
        }
        text = message;
    } else {
        text = [NSString stringWithFormat:@"%@\n%@", event, [self prettyJSON:safe]];
    }
    return text.length > 16384 ? [[text substringToIndex:16384] stringByAppendingString:@"\n<日志已截断>"] : text;
}

+ (void)event:(NSString *)event category:(NSString *)category fields:(NSDictionary *)fields {
#if defined(DEBUG) || defined(DOKIT)
    // 整条多行内容一次写入，Lumberjack 中仍然只占一条记录。
    DDLogInfo(@"[%@] %@", category, [self formattedEvent:event category:category fields:fields]);
#endif
}

+ (void)infoLog:(id)log { [self infoLog:log tag:nil]; }
+ (void)infoLog:(id)log tag:(NSString *)tag {
#if defined(DEBUG) || defined(DOKIT)
    id safe = [self sanitizedValue:log];
    NSString *text = [safe isKindOfClass:NSString.class] ? safe : [self prettyJSON:safe];
    if (!text.length) return;
    if (text.length > 16384) text = [[text substringToIndex:16384] stringByAppendingString:@"\n<日志已截断>"];
    DDLogInfo(@"[%@] %@", tag ?: @"App", text);
#endif
}
@end
