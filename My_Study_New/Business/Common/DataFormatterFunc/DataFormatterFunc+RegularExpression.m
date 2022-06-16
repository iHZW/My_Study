//
//  DataFormatterFunc+RegularExpression.m
//  TZYJ_IPhone
//
//  Created by Howard on 15/11/6.
//
//

#import "DataFormatterFunc+RegularExpression.h"

@implementation DataFormatterFunc (RegularExpression)

/**
 *  返回第一个正则匹配头标记和尾标记中间字符串内容
 *
 *  @param content           检索过滤字符串
 *  @param regularPatternStr 正则表达式
 *
 *  @return 返回第一个正则匹配头标记和尾标记中间字符串内容
 */
+ (NSString *)firstMatchFilterRegularExpression:(NSString *)content regularPatternStr:(NSString *)regularPatternStr
{
    NSRegularExpression *regularExpStr = [NSRegularExpression regularExpressionWithPattern:regularPatternStr options:NSRegularExpressionCaseInsensitive error:nil];
    if ([regularExpStr numberOfMatchesInString:content options:kNilOptions range:NSMakeRange(0, [content length])] > 0)
    {
        NSRange rg = [regularExpStr rangeOfFirstMatchInString:content options:0 range:NSMakeRange(0, [content length])];
        return [content substringWithRange:rg];
    }
    
    return @"";
}

/**
 *  正则匹配配头标记和尾标记中间字符串所有列表
 *
 *  @param content           检索过滤字符串
 *  @param regularPatternStr 正则表达式
 *
 *  @return 正则匹配头标记和尾标记中间字符串内容列表
 */
+ (NSArray *)matchesFilterRegularExpression:(NSString *)content regularPatternStr:(NSString *)regularPatternStr
{
    NSRegularExpression *regularExpStr = [NSRegularExpression regularExpressionWithPattern:regularPatternStr options:NSRegularExpressionCaseInsensitive error:nil];
    if ([regularExpStr numberOfMatchesInString:content options:kNilOptions range:NSMakeRange(0, [content length])] > 0)
    {
        NSArray *arrayOfAllMatches = [regularExpStr matchesInString:content options:0 range:NSMakeRange(0, [content length])];
        
        NSMutableArray *filterList = [NSMutableArray arrayWithCapacity:arrayOfAllMatches.count];
        [arrayOfAllMatches enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSTextCheckingResult *result, NSUInteger idx, BOOL *stop) {
            [filterList addObject:[content substringWithRange:result.range]];
        }];
    }
    
    return @[];
}

/**
 *  返回第一个正则匹配头标记和尾标记中间字符串内容
 *
 *  @param content 检索过滤字符串
 *  @param headTag 头标记字符串(注意正则通配符处理)
 *  @param tailTag 尾标记字符串(注意正则通配符处理)
 *
 *  @return 返回第一个正则匹配头标记和尾标记中间字符串内容
 */
+ (NSString *)firstMatchFilterRegularExpression:(NSString *)content headTag:(NSString *)headTag tailTag:(NSString *)tailTag
{
    NSString *regularPatternStr = [NSString stringWithFormat:@"(?<=%@).*(?=%@)", headTag, tailTag];
    return [DataFormatterFunc firstMatchFilterRegularExpression:content regularPatternStr:regularPatternStr];
}

/**
 *  返回去除前缀和后缀标记的字符串内容
 *
 *  @param content 检索过滤字符串
 *  @param headTag 头标记字符串
 *  @param tailTag 尾标记字符串
 *
 *  @return 返回过滤后字符串
 */
+ (NSString *)filterContentWithTag:(NSString *)content headTag:(NSString *)headTag tailTag:(NSString *)tailTag
{
    NSRange rgn1 = [content rangeOfString:headTag options:NSCaseInsensitiveSearch];
    if (rgn1.location != NSNotFound)
    {
        content = [content substringFromIndex:rgn1.location + rgn1.length];
    }
    else
        return @"";
    
    NSRange rgn2 = [content rangeOfString:tailTag options:NSBackwardsSearch];
    if (rgn2.location != NSNotFound)
    {
        content = [content substringToIndex:MAX(rgn2.location, 0)];
    }
    else
        return @"";
    
    return content;
}

/**
 *  正则匹配配头标记和尾标记中间字符串所有列表
 *
 *  @param content 检索过滤字符串
 *  @param headTag 头标记字符串(注意正则通配符处理)
 *  @param tailTag 尾标记字符串(注意正则通配符处理)
 *
 *  @return 正则匹配头标记和尾标记中间字符串内容列表
 */
+ (NSArray *)matchesFilterRegularExpression:(NSString *)content headTag:(NSString *)headTag tailTag:(NSString *)tailTag
{
    NSString *regularPatternStr = [NSString stringWithFormat:@"(?<=%@).*(?=%@)", headTag, tailTag];
    return [DataFormatterFunc matchesFilterRegularExpression:content regularPatternStr:regularPatternStr];
}

/**
 *  对检索字符串内容做URL链接的正则匹配，并返回正则匹配结果列表
 *
 *  @param content 检索字符串内容
 *
 *  @return 返回正则匹配结果列表
 */
+ (NSArray *)matchesURLRegularExpression:(NSString *)content
{
    // URL 链接正则匹配处理
    NSString *expStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.(com|edu|gov|int|mil|net|org|biz|tel|pro|top|mobi|asia|arpa|info|name|pro|aero|coop|museum|travel|[a-zA-Z]{2})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.(com|edu|gov|int|mil|net|org|biz|tel|pro|top|mobi|asia|arpa|info|name|pro|aero|coop|museum|travel|[a-zA-Z]{2})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|([a-zA-Z0-9\\.\\-]+\\.(com|edu|gov|int|mil|net|org|biz|tel|pro|top|mobi|asia|arpa|info|name|pro|aero|coop|museum|travel|[a-zA-Z]{2})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    
    NSRegularExpression *regularExpURL = [NSRegularExpression regularExpressionWithPattern:expStr options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *matches = [regularExpURL matchesInString:content options:kNilOptions range:NSMakeRange(0, [content length])];
    
    return matches;
}

/**
 *  正则检测邮箱合法性
 *
 *  @param email 邮箱地址
 *
 *  @return 是否合法
 */
+ (BOOL)validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

/**
 *  正则检测身份证合法性
 *
 *  @param identityCard 身份证信息
 *
 *  @return 是否合法
 */
+ (BOOL)validateIdentityCard:(NSString *)identityCard
{
    BOOL flag;
    if (identityCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}

@end
