//
//  LogUtils.m
//  NbcbBank
//
//  Created by nbcb on 2024/3/20.
//  Copyright © 2024 musheng zhangyan. All rights reserved.
//

#import "KlyyLogFormatter.h"
#import "KlyyLogUtils.h"
#import "MJExtension/MJExtension.h"

@implementation KlyyLogUtils
+ (void)load {
    @weakify(self);
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:nil usingBlock:^(NSNotification *_Nonnull note) {
        @strongify(self);
        [self uploadLogPath:KlyyDistUpgradeLogsPath errKey:KlyyDistUpgradeKEY];
        [self uploadLogPath:KlyyNetworkErrorLogsPath errKey:KlyyNetworkErrorKEY];
        [self uploadLogPath:KlyyGeTuiPushLogsPath errKey:KlyyGeTuiPushKEY];
        [self uploadLogPath:KlyyPhotoLogsPath errKey:KlyyPhotoKEY];
        [self uploadLogPath:KlyyLocationLogsPath errKey:KlyyLocationKEY];
        [self uploadLogPath:KlyyThirdRequestLogsPath errKey:KlyyThirdRequestKEY];
    }];
}
+ (void)addLog:(NSString *)path logType:(KlyyLogType)logType {
    DDLogFileManagerDefault *defaultManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:DOC_OF_PATH(path)];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:defaultManager];
    KlyyLogFormatter *formatter = [[KlyyLogFormatter alloc] init];
    [formatter addToAllowlist:logType];
    [fileLogger setLogFormatter:formatter];
    fileLogger.doNotReuseLogFiles = NO;
    fileLogger.rollingFrequency = 0;
    fileLogger.maximumFileSize = 1024 * 120;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    fileLogger.logFileManager.logFilesDiskQuota = 1024 * 1024 * 10;
    [DDLog addLogger:fileLogger];
}

+ (void)uploadLogPath:(NSString *)logPath errKey:(NSString *)errKey {
    if (![ZWUserAccountManager sharedZWUserAccountManager].isLogin) return;
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) return;
    NSFileManager *FM = [NSFileManager defaultManager];
    NSString *homePath = DOC_OF_PATH(logPath);
    NSError *error;
    NSArray *logsArray = [FM contentsOfDirectoryAtPath:homePath error:&error];
    if (error || logsArray.count == 0) return;

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *toDel = [NSMutableArray array];
        for (NSString *logFileName in logsArray) {
            NSString *path = [homePath stringByAppendingPathComponent:logFileName];
            NSError *readLogError;
            BOOL isFileExit = [FM fileExistsAtPath:path];
            if (!isFileExit) continue;
            
            NSString *logs = [NSString stringWithContentsOfFile:path encoding:(NSUTF8StringEncoding)error:&readLogError];
            if (ValidString(logs)) continue;
            NSLog(@"---87878*---%@", logs);
            [toDel addObject:logFileName];
            /** 听云上传日志  */
//            [TingyunUtil reportLog:errKey meta:@{@"logs": logs}];
        }
        for (NSString *fileName in toDel) {
            NSError *removeError;
            NSString *path = [homePath stringByAppendingPathComponent:fileName];
            [NSFileManager.defaultManager removeItemAtPath:path error:&removeError];
        }
    });
}

NSString *DOC_OF_PATH(NSString *path) {
    NSString *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [paths stringByAppendingPathComponent:path];
}

@end
