//
//  NSFileManager+Ext.m
//  StarterApp
//
//  Created by js on 2019/7/12.
//  Copyright © 2019 js. All rights reserved.
//

#import "NSFileManager+Ext.h"
#import "LogUtil.h"
@implementation NSFileManager (Ext)
- (BOOL)createFileIfNotExist:(NSURL *)filePath contents:(NSData *)data{
    if (filePath.hasDirectoryPath){
        [LogUtil warn:@"创建文件没有文件名" flag:nil context:self];
        return NO;
    }
    
    if (![self fileExistsAtPath:filePath.path]){
        NSURL *directoryURL = filePath.URLByDeletingLastPathComponent;
        NSError *error = nil;
        BOOL isSuccess = [self createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&error];
        if (isSuccess){
            isSuccess = [self createFileAtPath:filePath.path contents:data attributes:nil];
        } else {
            [LogUtil warn:error.localizedDescription flag:nil context:self];
        }
        return isSuccess;
    }
    return YES;
}


- (NSString *)generateRandomFileName{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time = [date timeIntervalSince1970] * 1000; // 毫秒级
    NSString *timeStr = [NSString stringWithFormat:@"%.0f", time];
    NSString *randomStr = [self randomString:10];
    NSString *name = [NSString stringWithFormat:@"WMUPLOAD%@%@", timeStr, randomStr];
    return name;
}

- (NSString *)randomString:(NSInteger)len
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:len];
    for (NSInteger i = 0; i < len; i++) {
        int index = arc4random_uniform((uint32_t)[letters length]);
        [randomString appendFormat: @"%C", [letters characterAtIndex:index]];
    }
    return randomString;
}

- (NSString *)generateRandomImageName{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time = [date timeIntervalSince1970] * 1000; // 毫秒级
    NSString *timeStr = [NSString stringWithFormat:@"%.0f", time];
    return [NSString stringWithFormat:@"IMAGE%@.jpg", timeStr];
}

- (NSString *)generateRandomVideoName{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time = [date timeIntervalSince1970] * 1000; // 毫秒级
    NSString *timeStr = [NSString stringWithFormat:@"%.0f", time];
    return [NSString stringWithFormat:@"vVIDEO%@.mp4", timeStr];
}

- (BOOL)deleteAllFilesInDirectory:(NSString *)directory error:(NSError **)error{
    NSArray *subpaths = [[NSFileManager defaultManager] subpathsAtPath:directory];
    BOOL isSuccess = YES;
    for (NSString *subpath in subpaths){
        NSString *fullPath = [directory stringByAppendingPathComponent:subpath];
        isSuccess = [self removeItemAtPath:fullPath error:error];
        if (!isSuccess){
            if (error){
                [LogUtil debug:[NSString stringWithFormat:@"删除文件失败 : %@ - %@",fullPath,[*error localizedDescription]] flag:nil context:self];
            } else {
                [LogUtil debug:[NSString stringWithFormat:@"删除文件失败 : %@",fullPath] flag:nil context:self];
            }
            break;
        }
    }
    return isSuccess;
}
@end
