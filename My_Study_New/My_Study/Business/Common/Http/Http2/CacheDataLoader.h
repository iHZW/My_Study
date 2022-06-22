//
//  CacheDataLoader.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMObject.h"
#import "CommonFileFunc.h"
#import "ZWHttpEventInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ResponseLoaderBlock)(NSInteger status,id _Nullable obj);

/**
 *  数据加载状态
 */
typedef NS_ENUM(NSInteger, LoaderStatus){
    /**
     *  无加载状态
     */
    LoaderStatusNone,
    /**
     *  加载本地数据完成
     */
    LoaderStatusLocalData,
    /**
     *  正在加载
     */
    LoaderStatusLoading,
    /**
     *  加载失败
     */
    LoaderStatusFailure,
    /**
     *  加载成功
     */
    LoaderStatusSuccess,
};

/**
 *  CacheDataLoader状态
 */
typedef NS_ENUM(NSInteger, CacheDataLoaderType){
    /**
     *  缓存数据加载
     */
    CacheDataLoaderType_Cache = 0,
    /**
     *  数据刷新
     */
    CacheDataLoaderType_Refresh,
    /**
     *  数据累积加载
     */
    CacheDataLoaderType_Append
};

@interface CacheDataLoader : CMObject

@property (nonatomic, assign) BOOL   bolNoCheckLoginToken;
@property (nonatomic, assign) NSUInteger requestNo;             // 请求序号或页码
@property (nonatomic, assign) NSUInteger requestSize;           // 请求条数，默认20条
@property (nonatomic, readonly) LoaderStatus loaderStatus;      // 加载状态
@property (nonatomic, readonly) BOOL hasMore;                   // 是否可以加载更多
@property (nonatomic, assign) NSUInteger total;                 // 数据总量
@property (nonatomic, strong) id loaderData;                    // 返回数据
@property (nonatomic, strong) NSMutableDictionary *commonParams;// http 请求参数
@property (nonatomic, assign) BOOL loadCacheData;               // 是否允许加载缓存数据
@property (nonatomic, copy) NSString *cacheFolderPath;          // 缓存文件保存目录
@property (nonatomic, copy) NSString *cacheFileName;            // 缓存文件名
@property (nonatomic, assign) NSTimeInterval timeOut;           // 请求超时时间
@property (nonatomic, assign) BOOL isParserByMannual;           // 数据解析是否采用自动化解析处理(默认为NO:手动解析 YES:自动化解析)

/**
 *  抽象方法，需要子类实现
 *
 *  @return 实例化后的子类loader
 */
+ (instancetype)defaultLoader;

/**
 *  首次数据请求加载缓存数据，网络请求数据返回后，再显示网络数据
 *
 *  @param loaderFinish 数据请求成功回调
 */
- (void)loadData:(void(^)(CacheDataLoader *loader, NSError *error, CacheDataLoaderType loaderType))loaderFinish;

@end


@interface CacheDataLoader (CacheData)

/**
 *  从缓存文件提取二进制数据
 *
 *  @return 二进制数据
 */
- (NSData *)loadBinaryCacheData;

/**
 *  将网络请求数据保存到指定缓存路径中
 *
 *  @param cacheData 缓存数据
 */
- (void)saveBinaryCacheData:(NSData *)cacheData fileName:(NSString *)fileName;

/**
 *  抽象方法，对返回的数据进行解析处理
 *
 *  @param data     返回二进制数据
 *  @param postDic  post请求参数
 *
 *  @return 如果解析失败返回对应Error值
 */
- (NSError *)parserData:(NSData *)data postDic:(NSDictionary * _Nullable)postDic;

/**
 *  从本地加载数据(如有特殊处理，子类可覆盖此方法)
 *
 *  @param loadLocalFinished 数据加载完成后的实例
 */
- (void)loadCacheData:(void(^)(BOOL success, NSError *error))loadLocalFinished;

/**
 *  抽象方法，从网络请求数据
 *
 *  @param loadNetworkFinished 请求完成后的回调
 */
- (void)loadNetworkData:(void(^)(BOOL success, NSError *error))loadNetworkFinished;

/**
 *  网络数据在本地缓存
 *
 *  @param filename  缓存key，会作为绝对路径的文件名
 *  @param eventInfo 请求信息
 */
- (void)setLocalCache:(NSString *)filename eventInfo:(ZWHttpEventInfo *)eventInfo;

@end

NS_ASSUME_NONNULL_END
