//
//  MDLogManager.m
//  WeiKe
//
//  Created by WuShiHai on 3/16/16.
//  Copyright © 2016 WeiMob. All rights reserved.
//
#if APPLOGOPEN
#import "MDLogManager.h"
#import "MDFileManager.h"

@interface MDLogManager (){
    dispatch_queue_t fileManagerQueue;
}



@end

@implementation MDLogManager

+ (MDLogManager *)standardLogManager{
    static MDLogManager *sharedLogManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLogManager = [[self alloc] init];
    });
    return sharedLogManager;
}

- (instancetype)init{
    if (self = [super init]) {
        fileManagerQueue = dispatch_queue_create("file.manager.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (void)logFile:(NSString *)response
        request:(NSString *)request
         method:(NSString *)method{

    NSString *currentDateStr = [self nowString];

    [[MDLogManager standardLogManager] logFile:response
                                       request:request
                                        method:method
                                          time:currentDateStr];
}

+ (NSArray *)todayLogFiles{
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSString *cachePath = [self timeFolderPath:[self nowString]];
    NSArray *files = [fileManage subpathsOfDirectoryAtPath:cachePath error:nil];
    return files;
}

+ (NSString *)todayFilePath{
    return [self timeFolderPath:[self nowString]];
}

+ (BOOL)clearLog{
    
//    if (IS_TEST_VERSION) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *directoryPath = [self cacheFolderPath];
        
        return [fileManager removeItemAtPath:directoryPath error:nil];
//    }
    return YES;
}

- (void)logFile:(NSString *)response
        request:(NSString *)request
         method:(NSString *)method
           time:(NSString *)time{
    
    dispatch_async(fileManagerQueue, ^{
        NSString *filePath = [MDLogManager filePath:method time:time];
        NSMutableDictionary *dataDic = [@{} mutableCopy];
        [dataDic setObject:response forKey:@"response"];
        [dataDic setObject:request forKey:@"request"];
        BOOL isSuccess = [MDFileManager wirteFile:filePath data:dataDic];
        if (isSuccess == NO) {
            NSLog(@"失败了");
        }
    });
    
}

//time 秒级别
+ (NSString *)filePath:(NSString *)method time:(NSString *)time{
    NSString *cachePath = [self timeFolderPath:time];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    BOOL isExist = [fileManager fileExistsAtPath:cachePath
                                     isDirectory:&isDir];
    if (!isExist)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    
    NSString *fileName = [NSString stringWithFormat:@"%@&%@",time,[method stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
    
    return [cachePath stringByAppendingPathComponent:fileName];
}

+ (NSString *)nowString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    return currentDateStr;
}

+ (NSString *)timeFolderPath:(NSString *)time{
    NSString *cachePath = [self cacheFolderPath];
    
    if (time.length >= 8) {
        cachePath = [cachePath stringByAppendingPathComponent:[time substringToIndex:8]];
    }
    
    return cachePath;
}

+ (NSString *)cacheFolderPath{
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    cachePath = [cachePath stringByAppendingPathComponent:@"MDCache"];
//    if ([MySingleton sharedSingleton].loginedIn) {
//        cachePath = [cachePath stringByAppendingPathComponent:[MySingleton sharedSingleton].GV_ShopId];
//    }else{
        cachePath = [cachePath stringByAppendingPathComponent:@"Vistor"];
//    }
    return cachePath;
}

@end
#endif
