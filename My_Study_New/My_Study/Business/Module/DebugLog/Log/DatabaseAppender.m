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
    
    NSString *sql = @"insert into App_Log(msg,level,thread,flag,context) values (?,?,?,?,?) ";
    [DatabaseAppender.dataBase inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeUpdate:sql,msg,
         logLevelString(logLevel),
         [NSThread currentThread].description,
         flag,
         NSStringFromClass([context class])];
    }];
}
@end
