//
//  ZWHttpEventInfo.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMObject.h"
#import "AFNetworking.h"
#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

extern const CGFloat DefaultTimeoutInterval; // 默认超时时间

#pragma mark -- enum

/** 数据类型（用于编码与解码判断） */
typedef NS_ENUM(NSInteger, DataParseType){
    DataParseTypeJSON,  /** json */
    DataParseTypeXML,  /** xml */
    DataParseTypeData,  /** 二进制数据（不解析） */
    DataParseTypeUnknown,  /** 未知类型（不解析） */
};

/** 获取到缓存数据以后是否继续请求网络  */
typedef NS_ENUM (NSUInteger,HttpReturnCachePolicy){
    HttpReturnCacheDataContinueLoad,
    HttpReturnCacheDataDontLoad,        //如果有缓存，那么不在调网络
    HttpReturnCacheDataOnlyCache,       //只取本地缓存，不走网络
};

/** 请求网络时Progress风格 */
typedef NS_ENUM(NSInteger, HttpProgressMaskType) {
    HttpProgressMaskTypeDefault,
    HttpProgressMaskTypeNone,
};

/* 通道类型 */
typedef NS_ENUM(NSUInteger, HttpChannelType) {
    HttpChannelTypeNative,  //native请求
    HttpChannelTypeH5,      //h5请求
};

#pragma mark -- 相关回调block

@class ZWHttpEventInfo;

/**
 *  发送请求时修改默认eventInfo的回调
 *
 *  @param eventInfo 默认创建的eventInfo
 */
typedef void (^ZWConstructingBlock)(ZWHttpEventInfo *eventInfo);

/**
 *  网络结束时回调
 *
 *  @param responseData 返回获取到的数据，如果json数据，返回json或者自动解析后的对象，其它的直接返回原始数据（比如：nsdata）
 *  @param error        如果发生错误，则返回error
 */
typedef void (^ZWCompletionBlock)(id responseData, NSError *error);

/**
 *  网络结束时回调
 *
 *  @param responseData 返回获取到的数据，如果json数据，返回json或者自动解析后的对象，其它的直接返回原始数据（比如：nsdata）
 *  @param error        如果发生错误，则返回error
 *  @param response     http url加载响应response，包含返回网络状态及错误信息
 */
typedef void (^ZWCompletionWithResponseBlock)(id responseData, NSError *error, NSURLResponse *response);

/**
 *  上传或者下载文件时进度变化回调
 *
 *  @param progress 当前的progress
 */
typedef void (^ZWProgressBlock)(NSProgress *progress);

/**
 *  afnetwork post请求时拼装数据用的
 *
 *  @param formData 当前生成的data
 */
typedef void (^ZWAFFormDataBlock)(id <AFMultipartFormData> formData);

#pragma mark -- ZWHttpEventInfo

@interface ZWHttpEventInfo : CMObject

/** "post" "get" ... */
@property (nonatomic) NSInteger httpMethod;
/** 数据解析方式 JSON，XML， Data...,如果需要返回原始二进制数据，请使用DataParseTypeData*/
@property (nonatomic) DataParseType parseType; // 数据解析方式 JSON，XML， Data...,
/** 设置请求的超时时间,默认30s */
@property (nonatomic) NSTimeInterval timeoutInterval;
/**如果此次请求的ContentType不在默认ContentType里面，则需要重新设置（只有不是DataParseTypeJSON是设置才有才生效) */
@property (nonatomic, copy) NSString *acceptableContentType;
/** 发起请求时间(距离1970年耗时多少毫秒) */
@property (nonatomic) int64_t requestTime;
/** 数据返回时间(距离1970年耗时多少毫秒) */
@property (nonatomic) int64_t responseTime;
/** 通道类型 */
@property (nonatomic) HttpChannelType httpChannelType;

// 请求地址和功能号
@property (nonatomic, copy) NSString *hostName;
@property (nonatomic, copy) NSString *relativePath;
@property (nonatomic) NSInteger funcId;
@property (nonatomic) NSInteger subFuncId;

/** 参数，会先读取调用方法传入的参数，如果重新设置之前传入的会失效 */
@property (nonatomic, strong) NSDictionary *parameters;

/** 自动解析对象的class */
@property (nonatomic) Class responseClass;

// 缓存相关
/** NSUrlRequest属性 */
@property (nonatomic) NSURLRequestCachePolicy cachePolicy;
/** 是否使用自定义缓存 */
@property (nonatomic) BOOL isUsingSelfCache;
/** 设置请求的key，作为取消联网操作或者自定义缓存的标识 */
@property (nonatomic, copy) NSString *requstEventKey;
/** 设置缓存文件的完整路径，用于需要指定路径缓存的请求 */
@property (nonatomic, copy) NSString *absoluteCachePath;

/**
更新缓存数据依据，适合组合请求，和bolCacheKey 互斥
如{@"result.data1.content":@"result.data1",@"result.data2.content":@"result.data2"}的组合请求
result.data1 代表json中数据路径，result.data1.content存在 代表需要更新本地result.data1结点数据，否则不更新
*/
@property (nonatomic, copy) NSDictionary *groupCacheUpdateMapDict;
@property (nonatomic) HttpReturnCachePolicy returnCachePolicy;  /** 获取到缓存数据以后是否继续请求网络 */

//根据返回数据的一级key value来判断是否缓存数据,如果value不存在，那么判断根据key获取的value是否存在，判断是否缓存，用于单一请求
@property (nonatomic, copy) NSString *bolCacheKey;

//如果设值，那么比较数据相等关系，如果不设，只检测bolCacheKey对应的值是否存在
@property (nonatomic, strong) id bolCacheValue;

/** 设置请求的hud方式，如果不需要hud，设置为none */
@property (nonatomic) HttpProgressMaskType progressMaskType;
/** 加载hud的view，如果不设置，默认加载到当前topController view */
@property (nonatomic, weak) UIView *progressTargetView;

// 扩展block
@property (nonatomic, copy) ZWProgressBlock uploadProgressBlock;
@property (nonatomic, copy) ZWProgressBlock downloadProgressBlock;
@property (nonatomic, copy) ZWAFFormDataBlock afFormDataBlock;

//// 页面消失后是否需要取消网络请求
//@property (nonatomic) BOOL isCancelOperationAfterDisappear;


@end

NS_ASSUME_NONNULL_END
