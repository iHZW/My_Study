//
//  ZWDataParsing.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWDataParsing.h"
#import "JSONModel/JSONModel.h"
#import "MJExtension.h"


static dispatch_queue_t data_parse_operation_processing_queue() {
    static dispatch_queue_t data_parse_operation_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        data_parse_operation_processing_queue = dispatch_queue_create("com.ZW.data.parsing.operation.queue", DISPATCH_QUEUE_CONCURRENT );
    });
    
    return data_parse_operation_processing_queue;
}

@implementation ZWDataParsing

+ (ZWDataParsing *)sharedZWDataParsing
{
    static ZWDataParsing *sharedObj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObj = [[[self class] alloc] init];
    });
    return sharedObj;
}

- (void)parseResponseData:(id)sourceData
                  toClass:(Class)toClass
    parsedCompletionBlock:(ZWParsedCompletionBlock)completionBlock
{
    dispatch_sync(data_parse_operation_processing_queue(), ^{
        NSError *error = nil;
        id outputData = nil;
        
        if (sourceData && toClass)
        {
            Class responseClass = toClass;
            //                outputData = [responseClass mj_objectWithKeyValues:sourceData];
            if ([sourceData isKindOfClass:[NSDictionary class]])
            {
                outputData = [[responseClass alloc] initWithDictionary:sourceData error:&error];
            }
            else if ([sourceData isKindOfClass:[NSString class]])
            {
                outputData = [[responseClass alloc] initWithString:sourceData error:&error];
            }
            else if ([sourceData isKindOfClass:[NSData class]])
            {
                outputData = [[responseClass alloc] initWithData:sourceData error:&error];
            }
        }
        
        if (completionBlock)
        {
            if (outputData && !error)
                completionBlock(outputData, nil);
            else
                completionBlock(sourceData, error);
        }
    });
}

- (void)parseResponseData:(id)sourceData
         requestEventInfo:(ZWHttpEventInfo *)requestEventInfo
    parsedCompletionBlock:(ZWParsedCompletionBlock)completionBlock
{
    if (sourceData && requestEventInfo.parseType == DataParseTypeJSON)
    {
        return [self parseResponseData:sourceData
                               toClass:requestEventInfo.responseClass
                 parsedCompletionBlock:completionBlock];
    }
    else
    {
        if (completionBlock)
            completionBlock(sourceData, nil);
    }
}

+ (void)parseResponseData:(id)sourceData toClass:(Class)toClass parsedCompletionBlock:(ZWParsedCompletionBlock)completionBlock
{
    return[[[self class] sharedZWDataParsing] parseResponseData:sourceData toClass:toClass parsedCompletionBlock:completionBlock];
}

+ (void)parseResponseData:(id)sourceData
         requestEventInfo:(ZWHttpEventInfo *)requestEventInfo
    parsedCompletionBlock:(ZWParsedCompletionBlock)completionBlock
{
    return [[[self class] sharedZWDataParsing] parseResponseData:sourceData requestEventInfo:requestEventInfo parsedCompletionBlock:completionBlock];
}

@end
