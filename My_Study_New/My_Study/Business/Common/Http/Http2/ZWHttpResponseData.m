//
//  PASHttpResponseData.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWHttpResponseData.h"

@implementation ZWHttpResponseData

#pragma mark - handerror
+ (void)BI_restError:(NSString *)url status:(NSString *)status errmsg:(NSString *)errmsg
{
    
}

+ (ZWHttpResponseData *)getErrorResponseData:(NSError *)error
{
    ZWHttpResponseData *tempData = [[ZWHttpResponseData alloc] init];
    tempData.status = [NSString stringWithFormat:@"%d", -6001];
    tempData.errmsg = @"网络连接失败，请检查您的网络！！";
    return tempData;
}

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
                                  url:(NSString *)url
{
    ZWHttpResponseData *tempData = data;
    if ([tempData isKindOfClass:[ZWHttpResponseData class]]) {
        if ([tempData.status length] && [tempData.status integerValue] != 1) {
            [ZWHttpResponseData BI_restError:url status:tempData.status errmsg:TransToString(tempData.errmsg)];
        } else if([tempData isKindOfClass:[NSDictionary class]]) {
            NSString *status = [DataFormatterFunc strValueForKey:@"status" ofDict:(NSDictionary *)tempData];
            NSString *errmsg = [DataFormatterFunc strValueForKey:@"errmsg" ofDict:(NSDictionary *)tempData];
            if (status.length && [status integerValue] != 1) {
                [ZWHttpResponseData BI_restError:url status:status errmsg:errmsg];
            }
        }
    }
    
    if (error) {
        tempData = [ZWHttpResponseData getErrorResponseData:error];
    }
    
    if ([tempData isKindOfClass:[ZWHttpResponseData class]] && block) {
        block([tempData.status integerValue],tempData);
    } else if (block) {
        block(-6000, data);
    }
}

@end
