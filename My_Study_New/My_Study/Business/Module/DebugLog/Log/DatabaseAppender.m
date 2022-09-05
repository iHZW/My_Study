//
//  DatabaseAppender.m
//  StarterApp
//
//  Created by js on 2019/7/12.
//  Copyright © 2019 js. All rights reserved.
//

#import "DatabaseAppender.h"
#import "FMDB.h"
#import "DBConstants.h"
#import "Logan.h"
#import "DataFormatterFunc+JSON.h"


typedef NS_ENUM(NSInteger, LoganType) {
    
    LoganTypeAction = 1,  //用户行为日志
    
    LoganTypeNetwork = 2, //网络级日志
};

@implementation DatabaseAppender

DB_EXPORT_ID(DB_COMMON_ID)


+ (void)createTable{
    NSString *sql = @"create table if not exists App_Log(identifier INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,msg text,level text,thread text,flag text,context text,createtime timestamp not null default (datetime('now','localtime')))";
    [self.dataBase inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeUpdate:sql];
    }];
}

- (void)log:(NSString *)msg level:(LogLevel)logLevel flag:(NSString *)flag context:(id)context{
    [DatabaseAppender createTable];
    
    NSString *labelStr = [NSString stringWithFormat:@"%@\n%@", NSStringFromClass([context class]), __String_Not_Nil(msg)];
    [self eventLogType:1 forLabel:labelStr];
    NSString *sql = @"insert into App_Log(msg,level,thread,flag,context) values (?,?,?,?,?) ";
    [DatabaseAppender.dataBase inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeUpdate:sql,msg,
         logLevelString(logLevel),
         [NSThread currentThread].description,
         flag,
         NSStringFromClass([context class])];
    }];
    
    loganFlush();

    [self getFileInfo];
}

/**
 用户行为日志

 @param eventType 事件类型
 @param label 描述
 */
- (void)eventLogType:(NSInteger)eventType forLabel:(NSString *)label {
    NSMutableString *s = [NSMutableString string];
    [s appendFormat:@"%d\t", (int)eventType];
    [s appendFormat:@"%@\t", label];
    logan(LoganTypeAction, s);
}

- (NSString *)getFileInfo
{
//    NSFileManager *fm = [NSFileManager defaultManager];
//    NSString *path = [[self class] loganLogDirectory];
//    id data = [NSData dataWithContentsOfFile:path];
//    NSError *error;
//    NSString *dataStr1 = [DataFormatterFunc jsonObjectFromData:data error:&error];
//    NSString *dataStr2 = [DataFormatterFunc parseDataToDict:data];
//    NSDictionary *dict111 = [[NSDictionary alloc] initWithContentsOfFile:path];
//    NSArray *tempArray = [NSArray arrayWithContentsOfFile:path];
//    NSString *dataStr3 = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    NSString *dataStr4 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *files = loganAllFilesInfo();

    NSMutableString *str = [[NSMutableString alloc] init];
    for (NSString *k in files.allKeys) {
        [str appendFormat:@"文件日期 %@，大小 %@byte\n", k, [files objectForKey:k]];
    }
    return str;
}



+ (NSString *)loganLogDirectory {
    static NSString *dir = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"LoganLoggerv3/2022-08-17"];
    });
    return dir;
}


@end
