//
//  NSString+Extension.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/8/3.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

- (NSString *)urlExtension
{
    NSString *ext = @"";
    NSArray * path = [self componentsSeparatedByString:@"?"];
    if (path.count > 0) {
        NSString * component = [path objectAtIndex:0];
        NSArray * arr = [component componentsSeparatedByString:@"."];
        if (arr.count > 0) {
            ext = arr.lastObject;
        }
    }
    return ext;
}

/**
 *  判断链接的后缀名 是否 后缀名数组中
 *
 *  @param extensions    扩展字段数组
 */
- (BOOL)isURLMatchExtensions:(NSArray *)extensions
{
    NSString *ext = [self.urlExtension lowercaseString];
    for (NSString *item in extensions){
        if ([item isEqualToString:ext]){
            return YES;
        }
    }
    return NO;
}

/**
 *  url中占位符替换
 *  例如: @"https://m-qa.xiaoke.cn/callcenter/record/detail?logid=1010&pid=%@&recordId=%@&userWid=%@"
 *
 *  @param url    带有站位符的url
 *  @param  params    需要替换的参数数组
 */
+ (NSString *)getFormatterUrl:(NSString *)url params:(NSArray *)params
{
    NSInteger loc = 0;
    NSString *param = @"";
    if ([url containsString:@"?"]) {
        loc = [url rangeOfString:@"?"].location;
        param = loc+1 <= url.length ? [url substringFromIndex:loc+1] : url;
    } else {
        /** 如果不存在?直接返回url  */
        return url;
    }
    NSMutableArray *mutArr = [NSMutableArray array];
    NSArray *tempArr = [param componentsSeparatedByString:@"&"];
    /** 记录替换参数的下标   */
    NSInteger paramIndex = 0;
    for (int i = 0; i < tempArr.count ; i++) {
        NSString *pair = [tempArr objectAtIndex:i];
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        if ([elements count] > 1)
        {
            NSString *key = [[elements objectAtIndex:0] stringByRemovingPercentEncoding];
            NSString *val = [elements objectAtIndex:1];
            if ([val containsString:@"%"]) {
                if (paramIndex < params.count) {
                    val = [NSString stringWithFormat:@"%@",[params objectAtIndex:paramIndex]];
                    paramIndex += 1;
                }
            }
            if(key && val){
                [mutArr addObject:[NSString stringWithFormat:@"%@=%@", key, val]];
            }
        }
    }
    
    NSString *headUrl = @"";
    if ([url containsString:@"?"]) {
        headUrl = [url componentsSeparatedByString:@"?"].firstObject;
    }
    NSString *resultUrl = [NSString stringWithFormat:@"%@", headUrl];
    for (int i = 0; i < mutArr.count ; i++) {
        NSString *tempStr = [mutArr objectAtIndex:i];
        if (i == 0) {
            if ([url containsString:@"?"]) {
                resultUrl = [NSString stringWithFormat:@"%@?%@",resultUrl, tempStr];
            } else {
                resultUrl = [NSString stringWithFormat:@"%@%@",resultUrl, tempStr];
            }
        } else {
            resultUrl = [NSString stringWithFormat:@"%@&%@",resultUrl, tempStr];
        }
    }
    return resultUrl;
}


@end
