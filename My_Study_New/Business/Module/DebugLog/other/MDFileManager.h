//
//  MDFileManager.h
//  WeiKe
//
//  Created by WuShiHai on 3/16/16.
//  Copyright © 2016 WeiMob. All rights reserved.
//
#if APPLOGOPEN
#import <Foundation/Foundation.h>

/**
 *  文件的基本操作，读写，文件管理，命名等
 */
@interface MDFileManager : NSObject

/**
 *  将字典数据指定写入本地文件中
 *
 *  @param path <#path description#>
 *  @param data <#data description#>
 *
 *  @return <#return value description#>
 */
+ (BOOL)wirteFile:(NSString *)path data:(NSDictionary *)data;

/**
 *  从指定路径的文件中读取字典数据
 *
 *  @param path <#path description#>
 *
 *  @return <#return value description#>
 */
+ (NSDictionary *)dictionaryOfFile:(NSString *)path;

@end
#endif
