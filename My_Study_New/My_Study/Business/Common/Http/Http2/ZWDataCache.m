//
//  ZWDataCache.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWDataCache.h"
#import "PINCache.h"
#import "CommonFileFunc.h"

@interface ZWDataCache ()

@property (nonatomic, strong) PINCache *dataCache;

@end

@implementation ZWDataCache
DEFINE_SINGLETON_T_FOR_CLASS(ZWDataCache)

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dataCache = [PINCache sharedCache];
    }
    return self;
}

#pragma mark -- 统一的cache

- (id)objectFromCacheWithKey:(NSString *)key
{
    id object = [self.dataCache objectForKey:key];
    return object;
}

- (void)objectFromCacheWithKey:(NSString *)key cacheBlock:(ZWCacheObjectBlock)cacheBlock
{
    [self.dataCache objectForKey:key block:^(PINCache * _Nonnull cache, NSString * _Nonnull key, id  _Nullable object) {
        if (cacheBlock)
            cacheBlock(key, object);
    }];
}

- (BOOL)saveObject:(id)object toCacheWithKey:(NSString *)key
{
    [self.dataCache setObject:object forKey:key];
    return YES;
}

- (void)removeFromCacheWithKey:(NSString *)key
{
    [self.dataCache removeObjectForKey:key];
}

- (void)clearAllCache
{
    [self.dataCache removeAllObjects];
}

#pragma mark -- 自定义路径

- (NSData *)objectFromCacheWithPath:(NSString *)path
{
    NSData *cacheData = nil;
    if (path)
    {
        cacheData = [NSData dataWithContentsOfFile:path];
    }
    return cacheData;
}

- (BOOL)saveData:(NSData *)data toCacheWithPath:(NSString *)path
{
    // 先判断路径目录有没有，没有的话先创建
    NSURL *pathUrl = [NSURL URLWithString:path];
    NSString *directorPath = [[pathUrl URLByDeletingLastPathComponent] absoluteString];
    BOOL bRet = [CommonFileFunc createDirector:directorPath];

    if (bRet && data)
    {
        [data writeToFile:path atomically:YES];
        return YES;
    }
    return NO;
}

- (void)removeFromCacheWithPath:(NSString *)path
{
    [CommonFileFunc removeFilePath:path];
}

+ (NSString *)absolutePathWithPath:(NSString *)path
{
    NSString *absolutePath = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), path];
    return absolutePath;
}

+ (NSString *)absolutePathWithPath:(NSString *)path inDirectory:(NSSearchPathDirectory)directory
{
    NSString *absolutePath = [CommonFileFunc getFilePathWithFilePath:path dirType:directory];
    return absolutePath;
}

@end
