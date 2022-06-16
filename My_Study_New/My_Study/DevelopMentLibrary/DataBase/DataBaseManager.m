//
//  DataBaseManager.m
//  StarterApp
//
//  Created by js on 2019/7/12.
//  Copyright © 2019 js. All rights reserved.
//

#import "DataBaseManager.h"
@interface DataBaseManager()
@property (nonatomic, copy) NSMutableDictionary *databaseMap;
@end

@implementation DataBaseManager

+ (void)registerRootDirectory:(NSString *)rootDirectory{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[self sharedManager] setRootDirectory:rootDirectory];
    });
}

+ (instancetype)sharedManager{
    static DataBaseManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[DataBaseManager alloc] init];
    });
    return _instance;
}

- (instancetype)init{
    if (self = [super init]){
        _databaseMap = [NSMutableDictionary dictionary];
    }
    return self;
}


- (DataBase *)getDataBase:(nullable NSString *)identity{
    return [self getDataBase:identity dbName:@"app.db"];
}

- (DataBase *)getDataBase:(nullable NSString *)identity dbName:(NSString *)dbName{
    if (self.rootDirectory.length == 0){
        @throw [[NSException alloc] initWithName:@"参数验证" reason:@"数据库根路径为空" userInfo:nil];
        return nil;
    }
    
    if (dbName.length == 0){
        @throw [[NSException alloc] initWithName:@"参数验证" reason:@"数据库名称为空" userInfo:nil];
        return nil;
    }
    
    if (identity.length == 0){
        return nil;
    }
    
    @synchronized (self) {
        DataBase *db = [self.databaseMap objectForKey:identity];
        if (!db){
            NSString *dbPath = [self dbPath:identity dbName:dbName];
            db = [[DataBase alloc] initWithDBPath:dbPath];
            [self.databaseMap setObject:db forKey:identity];
        }
        [db open];
        return db;
    }
}

- (NSString *)dbPath:(NSString *)identity dbName:(NSString *)dbName{
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@",self.rootDirectory,identity,dbName];
    return path;
}


+ (void)closeDataBases:(NSArray *)dbIds{
    [[DataBaseManager sharedManager] closeDataBases:dbIds];
}

- (void)closeDataBases:(NSArray *)dbIds{
    NSArray *keys = self.databaseMap.allKeys;
    for (NSString *dbId in keys){
        if ([dbIds containsObject:dbId]){
            DataBase *dataBase = [self getDataBase:dbId];
            [dataBase close];
            [self.databaseMap removeObjectForKey:dbId];
        }
    }
}
@end
