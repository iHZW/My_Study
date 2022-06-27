//
//  RouterParam.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "RouterParam.h"

@implementation RouterParam

+ (instancetype)makeWith:(NSString*)originUrl
                 destURL:(NSString *)destURL
                  params:(NSDictionary *)params
                    type:(RouterType)type
                 context:(nullable id)context
{
    RouterParam *instance = [self makeWith:originUrl destURL:destURL params:params type:type context:context success:nil fail:nil];
    return instance;
}

+ (instancetype)makeWith:(NSString*)originUrl
                 destURL:(NSString *)destURL
                  params:(NSDictionary *)params
                    type:(RouterType)type
                 context:(nullable id)context
                 success:(nullable RouterSuccessBlock)successBlock
                    fail:(nullable RouterFailBlock)failBlock
{
    RouterParam *instance = [[RouterParam alloc] init];
    instance.destURL = destURL;
    instance.originUrl = originUrl;
    instance.type = type;
    instance.params = params;
    instance.context = context;
    instance.successBlock = successBlock;
    instance.failBlock = failBlock;
    
    return instance;
}

@end
