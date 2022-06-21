//
//  PASDataParsing.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

/* 自动解析 */
#import "CMObject.h"
#import "ZWHttpEventInfo.h"

typedef void (^ZWParsedCompletionBlock)(id _Nullable parsedData, NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface ZWDataParsing : CMObject

+ (ZWDataParsing *)sharedZWDataParsing;

/**
 *  根据requestEventInfo自动解析，如果解析错误直接返回原数据
 *
 *  @param sourceData       原数据
 *  @param requestEventInfo 参数
 *  @param completionBlock  解析完成block
 */
- (void)parseResponseData:(id)sourceData requestEventInfo:(ZWHttpEventInfo *)requestEventInfo parsedCompletionBlock:(ZWParsedCompletionBlock)completionBlock;

/**
 *  根据class解析成对象
 *
 *  @param sourceData       原数据
 *  @param toClass         class类
 *  @param completionBlock  解析完成block
 */
- (void)parseResponseData:(id)sourceData toClass:(Class)toClass parsedCompletionBlock:(ZWParsedCompletionBlock)completionBlock;

// 静态方法
+ (void)parseResponseData:(id)sourceData toClass:(Class)toClass parsedCompletionBlock:(ZWParsedCompletionBlock)completionBlock;

+ (void)parseResponseData:(id)sourceData requestEventInfo:(ZWHttpEventInfo *)requestEventInfo parsedCompletionBlock:(ZWParsedCompletionBlock)completionBlock;


@end

NS_ASSUME_NONNULL_END
