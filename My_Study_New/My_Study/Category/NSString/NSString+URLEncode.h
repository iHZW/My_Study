//
//  NSString+URLEncode.h
//  PASecuritiesApp
//
//  Created by Howard on 16/8/1.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (URLEncode)

/**
 * iOS  9 以下使用的方法
 *使用stringByAddingPercentEscapesUsingEncoding方法，如果其中含有已转义的%等符号时,会再次转义而导致错误。此方法能解决该问题
 * @returns 编码后的URL
 */
- (NSString *)dzhURLEncodedString;


- (NSString *)encodeToPercentEscapeString;

- (NSString *)decodeFromPercentEscapeString;

/**
 * 使用stringByAddingPercentEscapesUsingEncoding方法，如果其中含有已转义的%等符号时,会再次转义而导致错误。此方法能解决该问题
 * @returns 编码后的URL
 */
- (NSString *)URLEncodedString;

/**
 * 给链接添加参数
 * @param parameterName 参数名称
 * @param parameterValue 参数值
 * @returns 添加参数后的链接字符串
 */
- (NSString *)urlWithParameters:(NSString *)parameterName value:(NSString *)parameterValue;

/**
 *  将URL参数转换为字典
 */
- (NSDictionary *)queryStringToDic;

/**
 *  将URL的query信息解析成字典模式
 *
 *  @param query url链接的query信息
 *
 *  @return return value description
 */
+ (NSDictionary *)parseQueryString:(NSString *)query;

@end


@interface NSMutableString (URLEncode)

/**
 * 给链接添加参数
 * @param parameterName 参数名称
 * @param parameterValue 参数值
 */
- (void)appendParameterComponent:(NSString *)parameterName value:(NSString *)parameterValue;

@end
