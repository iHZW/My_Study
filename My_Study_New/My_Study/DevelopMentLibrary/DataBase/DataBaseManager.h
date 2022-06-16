//
//  DataBaseManager.h
//  StarterApp
//
//  Created by js on 2019/7/12.
//  Copyright © 2019 js. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataBase.h"
NS_ASSUME_NONNULL_BEGIN

@interface DataBaseManager : NSObject

//数据库文件存储的根目录
@property (nonatomic, copy) NSString *rootDirectory;

+ (void)registerRootDirectory:(NSString *)rootDirectory;

/**
 * 关闭数据库
 */
+ (void)closeDataBases:(NSArray *)dbIds;
/**
 * 单例
 */
+ (instancetype)sharedManager;

/**
 * 获取数据库，有就返回，没有就创建
 */
- (DataBase *)getDataBase:(nullable NSString *)identity;

- (DataBase *)getDataBase:(nullable NSString *)identity dbName:(NSString *)dbName;
@end

NS_ASSUME_NONNULL_END
