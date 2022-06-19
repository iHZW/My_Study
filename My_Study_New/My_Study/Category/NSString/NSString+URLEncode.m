//
//  NSString+URLEncode.m
//  PASecuritiesApp
//
//  Created by Howard on 16/8/1.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "NSString+URLEncode.h"
#import <CoreFoundation/CoreFoundation.h>


@implementation NSString (URLEncode)


/* iOS  9 以下使用的方法 */
- (NSString *)dzhURLEncodedString
{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)self,
                                                              (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                              NULL,
                                                              kCFStringEncodingUTF8));

    return encodedString;
}

- (NSString *)encodeByAddingPercentEscapes {
    NSMutableCharacterSet *charset = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [charset removeCharactersInString:@"!*'();:@&=+$,/?%#[]"];
    NSString *encodedValue = [self stringByAddingPercentEncodingWithAllowedCharacters:charset];
    return encodedValue;
}


- (NSString *)encodeToPercentEscapeString
{
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    NSString *outputStr = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                (CFStringRef)self,
                                                                                                NULL,
                                                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                kCFStringEncodingUTF8);
    return outputStr;
}

- (NSString *)decodeFromPercentEscapeString
{
    NSMutableString *outputStr = [NSMutableString stringWithString:self];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    
    return [outputStr stringByRemovingPercentEncoding];
//    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)URLEncodedString
{
    NSString *encodedString = [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"!$&'()*+,-./:;=?@_~%#[]"].invertedSet];
    return encodedString;
}

- (NSString *)urlWithParameters:(NSString *)parameterName value:(NSString *)parameterValue
{
    NSRange range = [self rangeOfString:@"?"];
    if(range.length == 0)
        return [self stringByAppendingFormat:@"?%@=%@",parameterName, parameterValue];
    else
        return [self stringByAppendingFormat:@"&%@=%@",parameterName,parameterValue];
}

- (NSDictionary *)queryStringToDic
{
    NSInteger loc             = [self rangeOfString:@"?"].location;
    NSString *param           = loc+1 <= self.length ? [self substringFromIndex:loc+1]: self;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (NSString *pair in [param componentsSeparatedByString:@"&"])
    {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        if ([elements count] > 1)
        {
            NSString *key = @"";
            NSString *val = @"";
//            key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
//            val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            key = [[elements objectAtIndex:0] stringByRemovingPercentEncoding];
            val = [[elements objectAtIndex:1] stringByRemovingPercentEncoding];
            
            if(key && val)
                [dict setObject:val forKey:key];
        }
    }
    return dict;
}


/**
 *  将URL的query信息解析成字典模式
 *
 *  @param query url链接的query信息
 *
 *  @return return value description
 */
+ (NSDictionary *)parseQueryString:(NSString *)query
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSRange rgn = [pair rangeOfString:@"="];
        if (rgn.location != NSNotFound) {
            NSString *key = [[pair substringToIndex:MAX(rgn.location, 0)] stringByRemovingPercentEncoding];
            NSString *val = (rgn.location+1 >= pair.length) ? @"" : [[pair substringFromIndex:MIN(rgn.location+1, pair.length-1)] stringByRemovingPercentEncoding];
            
            [dict setObject:val forKey:key];
        }
    }
    return dict;
}

@end

@implementation NSMutableString (URLEncode)

- (void)appendParameterComponent:(NSString *)parameterName value:(NSString *)parameterValue
{
    NSRange range = [self rangeOfString:@"?"];
    if(range.length == 0)
        [self appendFormat:@"?%@=%@",parameterName, parameterValue];
    else
        [self appendFormat:@"&%@=%@",parameterName,parameterValue];
}

@end
