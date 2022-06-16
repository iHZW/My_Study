//
//  DataFormatterFunc+RegularExpression.h
//  TZYJ_IPhone
//
//  Created by Howard on 15/11/6.
//
//

#import "DataFormatterFunc.h"

@interface DataFormatterFunc (RegularExpression)

/**
 *  返回第一个正则匹配头标记和尾标记中间字符串内容
 *
 *  @param content           检索过滤字符串
 *  @param regularPatternStr 正则表达式
 *
 *  @return 返回第一个正则匹配头标记和尾标记中间字符串内容
 */
+ (NSString *)firstMatchFilterRegularExpression:(NSString *)content regularPatternStr:(NSString *)regularPatternStr;

/**
 *  正则匹配配头标记和尾标记中间字符串所有列表
 *
 *  @param content           检索过滤字符串
 *  @param regularPatternStr 正则表达式
 *
 *  @return 正则匹配头标记和尾标记中间字符串内容列表
 */
+ (NSArray *)matchesFilterRegularExpression:(NSString *)content regularPatternStr:(NSString *)regularPatternStr;

/**
 *  返回第一个正则匹配头标记和尾标记中间字符串内容
 *
 *  @param content 检索过滤字符串
 *  @param headTag 头标记字符串(注意正则通配符处理)
 *  @param tailTag 尾标记字符串(注意正则通配符处理)
 *
 *  @return 返回第一个正则匹配头标记和尾标记中间字符串内容
 */
+ (NSString *)firstMatchFilterRegularExpression:(NSString *)content headTag:(NSString *)headTag tailTag:(NSString *)tailTag;

/**
 *  返回去除前缀和后缀标记的字符串内容
 *
 *  @param content 检索过滤字符串
 *  @param headTag 头标记字符串
 *  @param tailTag 尾标记字符串
 *
 *  @return 返回过滤后字符串
 */
+ (NSString *)filterContentWithTag:(NSString *)content headTag:(NSString *)headTag tailTag:(NSString *)tailTag;

/**
 *  正则匹配配头标记和尾标记中间字符串所有列表
 *
 *  @param content 检索过滤字符串
 *  @param headTag 头标记字符串(注意正则通配符处理)
 *  @param tailTag 尾标记字符串(注意正则通配符处理)
 *
 *  @return 正则匹配头标记和尾标记中间字符串内容列表
 */
+ (NSArray *)matchesFilterRegularExpression:(NSString *)content headTag:(NSString *)headTag tailTag:(NSString *)tailTag;

/**
 *  对检索字符串内容做URL链接的正则匹配，并返回正则匹配结果列表
 *
 *  @param content 检索字符串内容
 *
 *  @return 返回正则匹配结果列表
 */
+ (NSArray *)matchesURLRegularExpression:(NSString *)content;

/**
 *  正则检测邮箱合法性
 *
 *  @param email 邮箱地址
 *
 *  @return 是否合法
 */
+ (BOOL)validateEmail:(NSString *)email;

/**
 *  正则检测身份证合法性
 *
 *  @param identityCard 身份证信息
 *
 *  @return 是否合法
 */
+ (BOOL)validateIdentityCard:(NSString *)identityCard;

@end
