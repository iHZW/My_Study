//
//  LeftDrawerDataLoader.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "LeftDrawerDataLoader.h"
#import "ZWSiteAddressManager.h"
#import "RestIOManager.h"
#import "CacheDataLoader+ZWNIO.h"
#import "LeftDrawerModel.h"
#import "ZWHttpNetworkManager.h"


/** 抽屉请求的key  可以用作取消请求使用 */
#define kLeftDrawerRequestEventKey  @"kLeftDrawerRequestEventKey"

@implementation LeftDrawerDataLoader

/**
 * 资讯-要闻-头部轮播数据
 * @param block 回调
 */
- (void)sendRequestForInfoNewsHeadBanner:(ResponseLoaderBlock)block
{
    /** 取消请求 */
    [[ZWHttpNetworkManager sharedHttpManager] cancelTaskWithKey:kLeftDrawerRequestEventKey];
    
    NSString *url = kClientChatDetailURL;
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:@"IOS" forKey:@"channelType"];
    
    @pas_weakify_self
    [self sendRequest:url params:paramDic httpMethod:HttpMethodPOST constructingBlock:^(ZWHttpEventInfo *eventInfo) {
        @pas_strongify_self
        eventInfo.responseClass = [LeftDrawerModel class];
        /* 设置缓存 */
        eventInfo.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        [self setLocalCache:kCacheString_clientChatDetailConfig eventInfo:eventInfo];
//        eventInfo.bolCacheKey = @"status";
//        eventInfo.bolCacheValue = @"1";
        /** 设置请求Key,   后期可做取消请求使用 */
        eventInfo.requstEventKey = kLeftDrawerRequestEventKey;
        eventInfo.progressMaskType = HttpProgressMaskTypeDefault;
    } responseBlock:block];

}

- (void)sendRequestDouBan:(ResponseLoaderBlock)block
{
    /** 取消请求 */
    [[ZWHttpNetworkManager sharedHttpManager] cancelTaskWithKey:kLeftDrawerRequestEventKey];
    
    NSString *url = @"http://283bt.com/search.php";
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:@"5" forKey:@"searchtype"];
    [paramDic setObject:@"1" forKey:@"page"];
    [paramDic setObject:@"time" forKey:@"order"];
    
    /** 这个得到的是一个html文件  */
    @pas_weakify_self
    [ZWM.http requestWithPath:url method:HttpRequestPost paramenters:paramDic prepareExecute:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        @pas_strongify_self
        NSString *str = [JSONUtil jsonString:responseObject];
        BlockSafeRun(block, 1, str);
        
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
            BlockSafeRun(block, 0, error);
        }];
    return;
    
    
    [self sendRequest:url params:paramDic httpMethod:HttpMethodPOST constructingBlock:^(ZWHttpEventInfo *eventInfo) {
        @pas_strongify_self
//        eventInfo.responseClass = [LeftDrawerModel class];
//        /* 设置缓存 */
//        eventInfo.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
//        [self setLocalCache:kCacheString_clientChatDetailConfig eventInfo:eventInfo];
////        eventInfo.bolCacheKey = @"status";
////        eventInfo.bolCacheValue = @"1";
//        /** 设置请求Key,   后期可做取消请求使用 */
//        eventInfo.requstEventKey = kLeftDrawerRequestEventKey;
//        eventInfo.progressMaskType = HttpProgressMaskTypeDefault;
    } responseBlock:block];
    
}


/**
 * 获取地址信息列表
 * @param block 回调
 */
- (void)sendRequestAddressList:(ResponseLoaderBlock)block {
    
    NSString *url = AddressAreaList;
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
//    [paramDic setObject:@"IOS" forKey:@"channelType"];
    
    @pas_weakify_self
    [self sendRequest:url params:paramDic httpMethod:HttpMethodPOST constructingBlock:^(ZWHttpEventInfo *eventInfo) {
        @pas_strongify_self
//        eventInfo.responseClass = [LeftDrawerModel class];
        /** 设置请求Key,   后期可做取消请求使用 */
        eventInfo.progressMaskType = HttpProgressMaskTypeDefault;
    } responseBlock:block];
}


@end
