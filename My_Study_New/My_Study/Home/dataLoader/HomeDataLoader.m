//
//  HomeDataLoader.m
//  My_Study
//
//  Created by hzw on 2022/9/23.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "HomeDataLoader.h"
#import "RestIOManager.h"
#import "CacheDataLoader+ZWNIO.h"
#import "ZWHttpNetworkManager.h"
#import "ZWHomeModel.h"


@interface HomeDataLoader ()



@end

@implementation HomeDataLoader


- (void)sendRequestTest:(ResponseLoaderBlock)block
{
    NSString *url = @"http://127.0.0.1:4523/m1/1102411-0-5ea01a58/zq/crm/trade/app/approval/list";
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:@"IOS" forKey:@"channelType"];
    
    @pas_weakify_self
    [self sendRequest:url params:paramDic httpMethod:HttpMethodPOST constructingBlock:^(ZWHttpEventInfo *eventInfo) {
        @pas_strongify_self
        eventInfo.responseClass = [ZWHomeModel class];
        /* 设置缓存 */
        eventInfo.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
//        [self setLocalCache:kCacheString_clientChatDetailConfig eventInfo:eventInfo];
//        eventInfo.bolCacheKey = @"status";
//        eventInfo.bolCacheValue = @"1";
        /** 设置请求Key,   后期可做取消请求使用 */
//        eventInfo.requstEventKey = kLeftDrawerRequestEventKey;
        eventInfo.progressMaskType = HttpProgressMaskTypeDefault;
    } responseBlock:block];
    
}

@end
