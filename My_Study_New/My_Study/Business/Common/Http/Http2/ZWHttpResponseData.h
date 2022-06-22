//
//  PASHttpResponseData.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWHttpNetworkData.h"
#import "ZWHttpEventInfo.h"
#import "ZWHttpNetworkData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  警告信息
 */
@protocol ZWWarningItem;
@interface ZWWarningItem : ZWHttpNetworkData


@end

@interface ZWHttpResponseData : ZWHttpNetworkData

/** 接口返回状态 1:成功 0:失败 998:tradesso重新登录 999:tradesso服务报错 6:非交易时间 */
@property (nonatomic, copy) NSString *status;

/** 接口返回错误信息 */
@property (nonatomic, copy) NSString *errmsg;

/** 接口返回登录态信息 */
@property (nonatomic, copy) NSString *actionAuth;

/** 业务层告警信息 */
@property (nonatomic, copy) NSArray <ZWWarningItem> *warning;
/* 响应时间 */
@property (nonatomic, copy) NSString *time;
/* 定位请求使用 */
@property (nonatomic, copy) NSString *globalTicket;

/**< 注册主推的时候 不会返回 pushMessageCode 使用该参数 来确定 是注册主推 还是主推数据返回 */
@property (nonatomic, copy) NSString *pushMessageCode; //业务推送messagecode
/* 埋点 */
+ (void)BI_restError:(NSString *)url status:(NSString *)status errmsg:(NSString *)errmsg;
/* 获取错误信息 */
+ (ZWHttpResponseData *)getErrorResponseData:(NSError *)error;

/**
 统一处理返回错误信息(不检测登录态)
 
 @param data 数据
 @param error 错误信息
 @param block 回调
 @param url 链接
 */
+ (void)handleCompletionErrorWithData:(id)data
                                error:(NSError *)error
                                block:(void(^)(NSInteger status,id obj))block
                                  url:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
