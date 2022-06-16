//
//  DataBase.h
//  StarterApp
//
//  Created by js on 2019/7/12.
//  Copyright © 2019 js. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class FMDatabase;
@interface DataBase : NSObject
/**
 * 数据库文件地址
 */
@property (nonatomic, copy,readonly) NSString *dbPath;

@property (nonatomic, assign,readonly) BOOL isOpened;


- (instancetype)initWithDBPath:(NSString *)dbPath;

- (void)open;
- (void)close;

- (void)inDatabase:(__attribute__((noescape)) void (^)(FMDatabase *db))block;
    
- (void)inTransaction:(void (^)(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback))block;
@end

NS_ASSUME_NONNULL_END
