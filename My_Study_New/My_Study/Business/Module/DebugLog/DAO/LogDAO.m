//
//  LogDAO.m
//  CRM
//
//  Created by js on 2019/8/27.
//  Copyright © 2019 js. All rights reserved.
//

#import "LogDAO.h"
#import "FMDB.h"
#import "DBConstants.h"

@implementation LogDAO

DB_EXPORT_ID(DB_COMMON_ID)

+ (NSArray *)queryAllGroups{
    NSMutableArray *resultArray = [NSMutableArray array];
    NSString *sql = @"select context,count(*) from APP_Log group by context";
    [self.dataBase inDatabase:^(FMDatabase * _Nonnull db) {
       FMResultSet *resultSet =  [db executeQuery:sql];
        while ([resultSet next]) {
            
            NSString *title = [resultSet stringForColumnIndex:0];
            LogModel *logModel = [[LogModel alloc] init];
            logModel.context = title;
            logModel.count = [resultSet intForColumnIndex:1];;
            [resultArray addObject:logModel];
        }
        [resultSet close];
    }];
    
    [self requeue:resultArray move:@"CRMVOIPService"];
    [self requeue:resultArray move:@"LogUtil"];
    [self requeue:resultArray move:@"WMNative"];
    [self requeue:resultArray move:@"Router"];
    [self requeue:resultArray move:@"HttpClient"];
    [self requeue:resultArray move:@"ZWHttpNetworkManager"];
    
    return resultArray;
}

//把制定日志类型移到最前面
+ (void)requeue:(NSMutableArray *)resultArray move:(NSString *)context{
    LogModel *httpModel = nil;
    for (NSUInteger i = 0; i < resultArray.count; i++){
        LogModel *logModel = [resultArray objectAtIndex:i];
        if ([logModel.context hasPrefix:context]){
            httpModel = logModel;
            [resultArray removeObject:logModel];
            break;
        }
    }
    if (httpModel){
        if (resultArray.count > 0){
            [resultArray insertObject:httpModel atIndex:0];
        } else {
            [resultArray addObject:httpModel];
        }
        
    }
}

+ (NSArray *)queryLogs:(NSString *)context{
    NSMutableArray *resultArray = [NSMutableArray array];
   
    
    [self.dataBase inDatabase:^(FMDatabase * _Nonnull db) {
        
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setLocale:[NSLocale currentLocale]];
        [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [db setDateFormat:outputFormatter];
        
        FMResultSet *resultSet = nil;
        NSString *sql = nil;
        if (context){
            sql = @"select * from APP_Log where context = ? order by identifier desc limit 0,1500";
            resultSet =  [db executeQuery:sql,context];
        } else {
            sql = @"select * from APP_Log where context is null order by identifier desc limit 0,1500";
            resultSet =  [db executeQuery:sql];
        }
        while ([resultSet next]) {
            LogModel *logModel = [[LogModel alloc] init];
            logModel.identifier = [resultSet intForColumn:@"identifier"];
            logModel.msg = [resultSet stringForColumn:@"msg"];
            logModel.level = [resultSet stringForColumn:@"level"];
            logModel.thread = [resultSet stringForColumn:@"thread"];
            logModel.flag = [resultSet stringForColumn:@"flag"];
            logModel.context = [resultSet stringForColumn:@"context"];
            logModel.createTime = [resultSet dateForColumn:@"createtime"];
            [resultArray addObject:logModel];
        }
        [resultSet close];
    }];
    return resultArray;
    
}

+ (NSArray *)queryAllLogs{
    NSMutableArray *resultArray = [NSMutableArray array];
   
    
    [self.dataBase inDatabase:^(FMDatabase * _Nonnull db) {
        
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setLocale:[NSLocale currentLocale]];
        [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [db setDateFormat:outputFormatter];
        
        FMResultSet *resultSet = nil;
        NSString *sql = nil;
       
        sql = @"select * from APP_Log order by identifier desc limit 0,1500";
        resultSet =  [db executeQuery:sql];
        
        while ([resultSet next]) {
            LogModel *logModel = [[LogModel alloc] init];
            logModel.identifier = [resultSet intForColumn:@"identifier"];
            logModel.msg = [resultSet stringForColumn:@"msg"];
            logModel.level = [resultSet stringForColumn:@"level"];
            logModel.thread = [resultSet stringForColumn:@"thread"];
            logModel.flag = [resultSet stringForColumn:@"flag"];
            logModel.context = [resultSet stringForColumn:@"context"];
            logModel.createTime = [resultSet dateForColumn:@"createtime"];
            [resultArray addObject:logModel];
        }
        [resultSet close];
    }];
    return resultArray;
    
}

+ (LogModel *)queryLogDetails:(NSUInteger)identity{
    NSString *sql = @"select * from APP_Log where identifier = ?";
    __block LogModel *model = nil;
    [self.dataBase inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet =  [db executeQuery:sql,@(identity)];
        if ([resultSet next]) {
            LogModel *logModel = [[LogModel alloc] init];
            logModel.identifier = [resultSet intForColumn:@"identifier"];
            logModel.msg = [resultSet stringForColumn:@"msg"];
            logModel.level = [resultSet stringForColumn:@"level"];
            logModel.thread = [resultSet stringForColumn:@"thread"];
            logModel.flag = [resultSet stringForColumn:@"flag"];
            logModel.context = [resultSet stringForColumn:@"context"];
            logModel.createTime = [resultSet dateForColumn:@"createtime"];
            
            model = logModel;
        }
        [resultSet close];
    }];
    return model;
}


+ (void)deleteAll:(NSString *)context{
    if (context.length > 0){
        NSString *sql = @"delete from APP_Log where context = ?";
        [self.dataBase inDatabase:^(FMDatabase * _Nonnull db) {
            [db executeUpdate:sql,context];
        }];
    } else {
        NSString *sql = @"delete from APP_Log where 1 = 1";
        [self.dataBase inDatabase:^(FMDatabase * _Nonnull db) {
            [db executeUpdate:sql];
        }];
    }
    
}
@end
