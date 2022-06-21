//
//  CacheDataLoader.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CacheDataLoader.h"
#import "CommonFileFunc.h"
#import "NSString+URLEncode.h"
#import "systemInfoFunc.h"
#import "ZWSDK.h"

#define CacheDataLoader_Exception_Format @"在%@的子类中必须override:%@方法"

@interface CacheDataLoader ()

@property (nonatomic, assign) BOOL hasMore; //是否可以加载更多
@property (nonatomic, assign) LoaderStatus loaderStatus; //加载状态

@end

@implementation CacheDataLoader

+ (instancetype)defaultLoader
{
    static CacheDataLoader *loader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loader = [[[self class] alloc] init];
    });
    return loader;
    
//    [NSException raise:NSInternalInconsistencyException format:CacheDataLoader_Exception_Format, [NSString stringWithUTF8String:object_getClassName(self)], NSStringFromSelector(_cmd)];
//    return nil;
}

- (instancetype)init
{
    if (self = [super init]) {
        _requestNo          = 1;
        _loadCacheData      = YES;
        _isParserByMannual  = NO;
        _requestSize        = 20;
        _loaderStatus       = LoaderStatusNone;
        _timeOut            = 30.0f;
        self.commonParams   = [NSMutableDictionary dictionary];//@{@"psize" : @(self.requestSize)};
    }
    return self;
}

/**
 *  加载数据，优先加载本地数据，网络返回成功时同步本地数据
 */
- (void)loadData:(void (^)(CacheDataLoader *loader, NSError *error, CacheDataLoaderType loaderType))loaderFinish
{
    if (_loadCacheData) {   // 加载本地缓存数据
        @pas_weakify_self
        [self loadCacheData:^(BOOL success, NSError *fetchError) {
            @pas_strongify_self
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    loaderFinish(self, nil, CacheDataLoaderType_Cache);
                } else {
                    loaderFinish(self, fetchError, CacheDataLoaderType_Cache);
                }
            });
        }];
    }
    
    void(^loadLocalDataBlock)(NSError *netWorkError, CacheDataLoaderType loaderType) = ^(NSError *netWorkError, CacheDataLoaderType loaderType){    // 网络异常检测
        if (netWorkError) {
            loaderFinish(self, netWorkError, loaderType);
        } else {
            loaderFinish(self, nil, loaderType);
        }
    };
    
    if (self.requestNo == 1) {  // 从网络获取最新数据
        self.loaderStatus = LoaderStatusLocalData;
        @pas_weakify_self
        [self loadNetworkData:^(BOOL success, NSError *error) {
            @pas_strongify_self
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    self.loaderStatus = LoaderStatusSuccess;
                    loaderFinish(self, nil, CacheDataLoaderType_Refresh);
                } else {
                    self.loaderStatus = LoaderStatusFailure;
                    loaderFinish(self, error, CacheDataLoaderType_Refresh);
                }
            });
        }];
    } else {    // 加载更多
        @pas_weakify_self
        [self loadNetworkData:^(BOOL success, NSError *error) {
            @pas_strongify_self
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    self.loaderStatus = LoaderStatusSuccess;
                } else {
                    self.loaderStatus = LoaderStatusFailure;
                }
                loadLocalDataBlock(success ? nil : error, CacheDataLoaderType_Append);
            });
        }];
    }
}

- (BOOL)hasMore
{
    return (self.requestNo * self.self.requestSize) < self.total;
}

@end


@implementation CacheDataLoader (CacheData)

/**
 *  从缓存文件提取二进制数据
 *
 *  @return 二进制数据
 */
- (NSData *)loadBinaryCacheData
{
    NSData *retData = nil;
    
    if ([self.cacheFolderPath length] > 0 && [self.cacheFileName length] > 0) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", self.cacheFolderPath, self.cacheFileName];
        retData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
    }
    return retData;
}

/**
 *  将网络请求数据保存到指定缓存路径中
 *
 *  @param cacheData 缓存数据
 */
- (void)saveBinaryCacheData:(NSData *)cacheData fileName:(NSString *)fileName
{
    if ([self.cacheFolderPath length] > 0 && [self.cacheFileName length] > 0) {
        [CommonFileFunc saveDataToDirector:self.cacheFolderPath fileName:fileName data:cacheData];
    }
}

/**
 *  抽象方法，对返回的数据进行解析处理
 *
 *  @param data     返回二进制数据
 *  @param postDic  post请求参数
 *
 *  @return 如果解析失败返回对应Error值
 */
- (NSError *)parserData:(NSData *)data postDic:(NSDictionary * _Nullable)postDic
{
    [NSException raise:NSInternalInconsistencyException format:CacheDataLoader_Exception_Format, [NSString stringWithUTF8String:object_getClassName(self)], NSStringFromSelector(_cmd)];
    return nil;
}

/**
 *  从本地加载数据(如有特殊处理，子类可覆盖此方法)
 *
 *  @param loadLocalFinished 数据加载完成后的实例
 */
- (void)loadCacheData:(void(^)(BOOL success, NSError *error))loadLocalFinished
{
    NSData *cacheData = [self loadBinaryCacheData];
    if (cacheData && self.requestNo <= 1)
    {
        NSError *retErr = [self parserData:cacheData postDic:nil];
        BOOL retStatus = retErr ? NO : YES;
        loadLocalFinished(retStatus, retErr);
    }
}

/**
 *  抽象方法，从网络请求数据
 *
 *  @param loadNetworkFinished 请求完成后的回调
 */
- (void)loadNetworkData:(void(^)(BOOL success, NSError *error))loadNetworkFinished
{
    [NSException raise:NSInternalInconsistencyException format:CacheDataLoader_Exception_Format, [NSString stringWithUTF8String:object_getClassName(self)], NSStringFromSelector(_cmd)];
}

- (void)setLocalCache:(NSString *)filename eventInfo:(ZWHttpEventInfo *)eventInfo
{
    eventInfo.isUsingSelfCache = YES;
    eventInfo.absoluteCachePath = [CommonFileFunc getNetWorkingDataCaches:filename];
}

@end
