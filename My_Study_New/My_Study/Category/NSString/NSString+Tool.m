//
//  NSString+Tool.m
//  My_Study
//
//  Created by Zhiwei Han on 2023/3/15.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "NSString+Tool.h"
#import <YYCategories/YYCategories.h>
#import <SDWebImage/SDWeakProxy.h>

#define CONFIG_APP_BASE_URL @"https://www.zw.com/app"     // app  baseUrl
#define CONFIG_WEB_BASE_URL @"https://www.zw.com/web"     // webview  baseUrl
#define CONFIG_REQUEST_BASE_URL @"https://www.zw.com/request" // 请求baseUrl
#define CONFIG_IMAGE_BASE_URL @"https://www.zw.com/image" // image baseUrl
#define CONFIG_IMAGE_OSS_BASE_URL @"https://www.zw.com/image/oss" // image oss baseUrl

//#define CONFIG_WEB_BASE_URL @"https://www.zw.com"

@implementation NSString (Tool)

#pragma mark - modify
- (NSString*)eh_append:(NSString*)str {
    return [NSString stringWithFormat:@"%@%@", self, str];
}

/// 前边拼接字符串s
- (NSString*)eh_front_append:(NSString*)str {
    return [NSString stringWithFormat:@"%@%@", str, self];
}

/// 拼接H5 跳转 url
/// - Parameter dic: 参数
- (NSString *)eh_webview_url:(NSDictionary<NSString*, NSString*>*)dic {
    NSString *webUrlStr;
    NSString *path = self;
    if ([path hasPrefix:@"http"] ||
        [path hasPrefix:@"https"]) {
        webUrlStr = path;
    } else {
        // 拼接域名
        path = [path eh_front_append:CONFIG_WEB_BASE_URL];
        // 拼接参数
        if (dic) {
            path = [path eh_append:@"?"];
            path = [path eh_append_url_parameter:dic];
        }
        webUrlStr = path;
    }
    return webUrlStr;
}

#pragma mark - Url
/// Convert to url
- (NSURL*)eh_url {
    return [NSURL URLWithString:self];
}


/// 路由跳转拼接域名
- (NSURL *)eh_base_url {
    NSURL *url;
    NSString *urlName = self;
    if ([urlName hasPrefix:@"http"] ||
        [urlName hasPrefix:@"https"]) {
        url = urlName.eh_url;
    } else {
        if (![urlName hasPrefix:@"/"]) {
            urlName = [NSString stringWithFormat:@"/%@", urlName];
        }
        url = [urlName eh_front_append:CONFIG_REQUEST_BASE_URL].eh_url;
    }
    return url;
}

- (NSURL*)eh_image_url {
    NSURL *url;
    NSString *urlName = self;
    if ([urlName hasPrefix:@"http"] ||
        [urlName hasPrefix:@"https"]) {
        url = urlName.eh_url;
    } else {
        if (![urlName hasPrefix:@"/"]) {
            urlName = [NSString stringWithFormat:@"/%@", urlName];
        }
        url = [urlName eh_front_append:CONFIG_IMAGE_BASE_URL].eh_url;
    }
    return url;
}

- (NSURL*)eh_image_url_look {
    NSURL *url;
    NSString *urlName = self;
    if ([urlName hasPrefix:@"http"] ||
        [urlName hasPrefix:@"https"]) {
        url = urlName.eh_url_look;
    } else {
        if (![urlName hasPrefix:@"/"]) {
            urlName = [NSString stringWithFormat:@"/%@", urlName];
        }
        url = [urlName eh_front_append:CONFIG_IMAGE_OSS_BASE_URL].eh_url_look;
    }
    return url;
}

/// Convert to url
- (NSURL*)eh_url_look {
    NSString* lastPathComponet = self.lastPathComponent.stringByURLEncode;
    NSString * headPaths = [self substringWithRange:NSMakeRange(0, self.length - self.lastPathComponent.length)];
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", headPaths, lastPathComponet]];
}

#pragma mark - File Path
- (NSString *)eh_documentPath {
    NSArray *userPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[userPaths objectOrNilAtIndex:0] stringByAppendingPathComponent:self];
}

- (NSString *)eh_libraryPath {
    NSArray *userPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [[userPaths objectOrNilAtIndex:0] stringByAppendingPathComponent:self];
}

- (NSString *)eh_cachesPath {
    NSArray *userPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[userPaths objectOrNilAtIndex:0] stringByAppendingPathComponent:self];
}

- (NSString *)eh_tempPath {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:self];
}

- (NSString *)eh_homePath {
    return [NSHomeDirectory() stringByAppendingPathComponent:self];
}

- (BOOL)eh_fileExist {
    if (self.length==0) {
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:self];
    return isExist;
}

- (unsigned long long)eh_fileSize {
    unsigned long long fileSize = 0;
    if([[NSFileManager defaultManager] fileExistsAtPath:self]){
        NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self error:NULL];
        fileSize = [attributes fileSize];
    }
    return fileSize;
}

- (void)eh_createFile {
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:self]) {
        [manager createFileAtPath:self contents:nil attributes:nil];
    }
}

- (BOOL)eh_createDir {
    if (self.length==0) {
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isSuccess = YES;
    BOOL isExist = [fileManager fileExistsAtPath:self];
    if (isExist==NO) {
        NSError *error;
        if (![fileManager createDirectoryAtPath:self withIntermediateDirectories:YES attributes:nil error:&error]) {
            isSuccess = NO;
            NSLog(@"creat Directory Failed:%@",[error localizedDescription]);
        }
    }
    return isSuccess;
}

#pragma mark - AppInfo
/// 获取App的版本号
+ (NSString*)eh_appVersion {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *mainVersion = [infoDic stringValueForKey:@"CFBundleShortVersionString" default:@"0"];
    NSString *buildVersion = [infoDic stringValueForKey:@"CFBundleVersion" default:@"0"];
    return [[mainVersion eh_append:@"."] eh_append:buildVersion];
}

/// 获取App的版本号
+ (NSString*)eh_mainVersion {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *mainVersion = [infoDic stringValueForKey:@"CFBundleShortVersionString" default:@"0"];
    return mainVersion;
}

/// 获取App的build版本
+ (NSString*)eh_appBuildVersion {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *buildVersion = [infoDic stringValueForKey:@"CFBundleVersion" default:@"0"];
    return buildVersion;
}

/// 手机号码脱敏  188**7870
/// - Parameter number:
+ (NSString *)cipherNumber:(NSString *)number {
    return [self cipherNumber:number keepDigitLen:3 cipherLen:0 replaceStr:@"*"];
}

/// 手机号码脱敏  188****7870
/// - Parameter number:
+ (NSString *)cipherNumber:(NSString *)number cipherLen:(NSUInteger)cipherLen {
    return [self cipherNumber:number keepDigitLen:3 cipherLen:cipherLen replaceStr:@"*"];
}

#pragma mark - 从字符串中过滤出数字
- (NSString *)eh_filterOutNumbers {
    return [self eh_filterCharactorsWithRegex:@"[^0-9]"];
}

- (NSString *)eh_filterCharactorsWithRegex:(NSString *)regexStr {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *result = [regex stringByReplacingMatchesInString:self options:NSMatchingReportCompletion range:NSMakeRange(0, self.length) withTemplate:@""];
    
    return result;
}

#pragma mark - 加密数字，len：保留数字位数，replaceStr：每个数字替代字符
+ (NSString *)cipherNumber:(NSString *)number
              keepDigitLen:(NSUInteger)len
                replaceStr:(NSString *)replaceStr {
    return [self cipherNumber:number
                 keepDigitLen:len
                    cipherLen:0
                   replaceStr:replaceStr];
}

+ (NSString *)cipherNumber:(NSString *)number
              keepDigitLen:(NSUInteger)len
                 cipherLen:(NSUInteger)cipherLen
                replaceStr:(NSString *)replaceStr {
    if (number.length <= len) {
        return number;
    }
    
    NSUInteger totalLen = number.length;
    NSUInteger count = 0;
    NSUInteger realLen = len;
    
    for (int i = 0; i < totalLen; i++) {
        char c = [number characterAtIndex:i];
        if (c >= '0' && c <= '9') {
            count++;
        }
        
        if (len == count) {
            realLen = i + 1;
            break;
        }
    }
    
    NSUInteger clipLen = totalLen - realLen;
    if (cipherLen > 0) {
        clipLen = cipherLen <= clipLen ? cipherLen : clipLen;
    }
    
    NSString *str = [self stringWithRepeatString:replaceStr len:clipLen];
    number = [number stringByReplacingCharactersInRange:NSMakeRange(realLen, clipLen) withString:str];
    return number;
    
}

+ (NSString *)stringWithRepeatString:(NSString *)repeatStr len:(NSUInteger)len {
    NSMutableString *strM = [NSMutableString stringWithCapacity:len];
    for (NSUInteger i = 0; i < len; i++) {
        [strM appendString:repeatStr];
    }
    return [strM copy];
}


/// 扩展名
- (NSString *)eh_urlExtension {
    NSString *ext = @"";
    NSArray *path = [self componentsSeparatedByString:@"?"];
    if (path.count > 0) {
        NSString *component = [path objectAtIndex:0];
        NSArray *arr        = [component componentsSeparatedByString:@"."];
        if (arr.count > 0) {
            ext = arr.lastObject;
        }
    }
    return ext;
}

/// 判断扩展名数组 是否包含当前扩展名
/// - Parameter extensions: 扩展名数组
- (BOOL)eh_isURLMatchExtensions:(NSArray *)extensions {
    NSString *ext = [self.eh_urlExtension lowercaseString];

    for (NSString *item in extensions) {
        if ([item isEqualToString:ext]) {
            return YES;
        }
    }
    return NO;
}

/// 给 URL 拼接参数
/// - Parameter dic: 参数
- (NSString*)eh_append_url_parameter:(NSDictionary<NSString*, NSString*>*)dic {
    __block NSString* parameters = [self rangeOfString:@"?"].length > 0 ? @"" : @"?";
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.length > 0) {
            parameters = [parameters stringByAppendingFormat:@"%@=%@&", key, obj];
        }
    }];

    if (parameters.length > 1) {
        parameters = [parameters substringWithRange:NSMakeRange(0, [parameters length] - 1)];
    }
    
    if ([parameters isEqualToString:@"?"]) {
        parameters = @"";
    }
    return [self stringByAppendingString:parameters];
}

/// 读取缓存数据
- (id)eh_getCacheData {
    NSInputStream *inStream = [[NSInputStream alloc] initWithFileAtPath:self];
    [inStream open];
    NSError *error = nil;
    id data = [NSJSONSerialization JSONObjectWithStream:inStream options:NSJSONReadingAllowFragments error:&error];
    [inStream close];
    return data;
}

/// 向当前路径写入数据
/// - Parameters:
///   - data: 需要写入的数据
///   - version: 新数据对应的版本号
///   - userDefaultKey: 查找版本号，依赖的key
- (BOOL)eh_saveCacheData:(id)data version:(NSString*)version userDefaultKey:(NSString*)userDefaultKey {
    BOOL update = false;
    if ([data isKindOfClass:NSArray.class] || [data isKindOfClass:NSDictionary.class]) {
        // 取出缓存的版本号
        NSString *homeDecorationVersion = [[NSUserDefaults standardUserDefaults] stringForKey:userDefaultKey];

        // 如果待写入的数据，与，本地数据没有差异，不需要写入，页不需要刷新UI
        if (homeDecorationVersion.length > 0 && [homeDecorationVersion isEqualToString:version]) {
            // 版本号一致，无需刷新
            NSLog(@"log_info = %@", @"版本号一致，无需刷新");
        }
        else {
            // 保存最新的版本号
            if ([version isKindOfClass:NSString.class] && version.length > 0) {
                [[NSUserDefaults standardUserDefaults] setValue:version forKey:userDefaultKey];
            }
            else {
                NSLog(@"log_error excpetion = %@", @"版本号为啥为空");
            }
            
            // 保存最新的数据
            [self eh_createFile];
            NSOutputStream *outStream = [[NSOutputStream alloc] initToFileAtPath:self append:NO];
            [outStream open];
            NSError *error = nil;
            [NSJSONSerialization writeJSONObject:data toStream:outStream options:NSJSONWritingPrettyPrinted error:&error];
            [outStream close];
            if (error == nil) {
                update = true;
            }
        }
    }
    return update;
}

@end
