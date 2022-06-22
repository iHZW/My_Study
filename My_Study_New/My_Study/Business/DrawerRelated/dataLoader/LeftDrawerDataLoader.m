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

#define kCacheString_ClientChatDetail     @"CacheStringClientChatDetail"   //数据缓存


@implementation LeftDrawerDataLoader

/**
 * 资讯-要闻-头部轮播数据
 * @param block 回调
 */
- (void)sendRequestForInfoNewsHeadBanner:(ResponseLoaderBlock)block
{
    NSString *url = kClientChatDetailURL;
    if (!([url hasPrefix:@"http"]||[url hasPrefix:@"https"])) {
       url = [NSString stringWithFormat:@"%@%@", [ZWSiteAddressManager getBaseHttpURL], url]  ;
    }
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
//    [paramDic setObject:@"infoNewsHead" forKey:@"confName"];
//    [paramDic setObject:natConfVer forKey:@"confVersion"];
    [paramDic setObject:@"IOS" forKey:@"channelType"];
//    [paramDic setObject:[PASUserInfoBridgeModule aneVersion] forKey:@"appVersion"];
//    url = GetHttpURLForGetMethod(url, &paramDic,1);
    
    @pas_weakify_self
    [self sendRequest:url params:paramDic httpMethod:HttpMethodPOST constructingBlock:^(ZWHttpEventInfo *eventInfo) {
        @pas_strongify_self
        eventInfo.responseClass = [LeftDrawerModel class];
        eventInfo.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
//        [self setLocalCache:kCacheString_InfoNewsHeadBanner eventInfo:eventInfo];
        eventInfo.bolCacheKey = @"status";
        eventInfo.bolCacheValue = @"1";
        eventInfo.progressMaskType = HttpProgressMaskTypeNone;
    } responseBlock:block];

}

@end
