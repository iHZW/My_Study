//
//  PathConstants.m
//  StarterApp
//
//  Created by js on 2019/7/15.
//  Copyright © 2019 js. All rights reserved.
//

#import "PathConstants.h"
@implementation PathConstants
/**
 * APP 根路径
 */
+ (NSString *)appDirectory{
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [NSString stringWithFormat:@"%@/%@",docPath,@"app"];
}

/**
 * 数据目录
 */
+ (NSString *)appDataDirectory{
    return [NSString stringWithFormat:@"%@/%@",[self appDirectory],@"data"];
}

+ (NSString *)appImageDirectory{
    return [[self appDataDirectory] stringByAppendingPathComponent:@"image"];
}

+ (NSString *)appVoiceDirectory{
    return [[self appDataDirectory] stringByAppendingPathComponent:@"voice"];
}

+ (NSString *)userCacheDirectory {
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return paths.firstObject;
}

+ (NSString *)webFileDirectory{
    return [NSString stringWithFormat:@"%@/%@",[self appDirectory],@"webfile"];
}


/**
 * 缓存目录
 */
+ (NSString *)appCacheDirectory{
    return [NSString stringWithFormat:@"%@/%@",[self userCacheDirectory],@"app"];
}

+ (NSString *)sdWebImageCacheDirectory{
    return [[[self userCacheDirectory] stringByAppendingPathComponent:@"com.hackemist.SDImageCache"] stringByAppendingPathComponent:@"default"];
}

+ (NSString *)gcdWebServerRootDirectory{
    return [NSString stringWithFormat:@"%@/%@",[self appDirectory],@"hybridserver"];
}

/**
 * downLoad 目录 「documents/app/downLoad」
 */
+ (NSString *)downLoadDirectory
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[self appDirectory],@"downLoad"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return filePath;
}
/**
 * preversion 目录 「documents/app/preversion」
 */
+ (NSString *)preversionDirectory
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[self appDirectory],@"preversion"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return filePath;
}

+ (NSString *)fileWebServerRootDirectory{
    return [NSString stringWithFormat:@"%@/%@",NSTemporaryDirectory(),@"hybridserver"];
}
    
+ (NSString *)shareImageRootDirectory{
    return [NSString stringWithFormat:@"%@/%@",NSTemporaryDirectory(),@"share/image"];
}
@end
