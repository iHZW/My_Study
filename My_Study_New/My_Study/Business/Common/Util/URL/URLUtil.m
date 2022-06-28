//
//  URLUtil.m
//  CRM
//
//  Created by js on 2021/12/10.
//  Copyright © 2021 CRM. All rights reserved.
//

#import "URLUtil.h"
#import "URLObject.h"

@implementation URLUtil
+ (NSURL *)formateToGetURL:(NSString *)urlString{
    /**
     https://sales-qa.xiaoke.cn/?ucid=30533234&plan_id=126620347&unit_id=6411615289&keyword_id=346221626164&creative_id=54917788293&matchtype=1&dongtai=0&trig_flag=nm&crowdid={crowdid}&kw_enc=%E9%94%80%E6%B0%AAcrm%E7%99%BB%E9%99%86%E5%85%A5%E5%8F%A3&kw_enc_utf8=%E9%94%80%E6%B0%AAcrm%E7%99%BB%E9%99%86%E5%85%A5%E5%8F%A3&promotion_channel=1&sdclkid=b52pALq6152lxrDlA-&bd_vid=8527847846981538862
     */
    
    URLObject *urlObject = [self parseURL:urlString];
    if (urlObject){
        return [self createGETURLFromString:urlObject.host params:urlObject.params];
    }
    
    return nil;
}

+ (nullable URLObject *)parseURL:(NSString *)urlString{
    if(urlString.length==0) {
        return nil;
    }
    
    //先截取问号
    NSArray* allElements = [urlString componentsSeparatedByString:@"?"];
    NSString *host = nil;
    if (allElements.count > 0){
        host = [allElements objectAtIndex:0];
    }
    NSMutableDictionary* params = [NSMutableDictionary dictionary];//待set的参数字典
    
    if(allElements.count == 2) {
        //有参数或者?后面为空
        NSString* paramsString = allElements[1];
        //获取参数对
        NSArray*paramsArray = [paramsString componentsSeparatedByString:@"&"];
        if(paramsArray.count>=2) {
            for(NSInteger i =0; i < paramsArray.count; i++) {
                NSString* singleParamString = paramsArray[i];
                NSArray* singleParamSet = [singleParamString componentsSeparatedByString:@"="];
                if(singleParamSet.count==2) {
                    NSString* key = singleParamSet[0];
                    NSString* value = singleParamSet[1];
                    if(key.length>0|| value.length>0) {
                        [params setObject: value.length>0? value:@"" forKey:key.length>0?key:@""];
                    }
                }
            }
        }else if(paramsArray.count == 1) {//无 &。url只有?后一个参数
            NSString* singleParamString = paramsArray[0];
            
            NSArray* singleParamSet = [singleParamString componentsSeparatedByString:@"="];
            if(singleParamSet.count==2) {
                NSString* key = singleParamSet[0];
                NSString* value = singleParamSet[1];
                if(key.length>0 || value.length>0) {
                    [params setObject:value.length>0?value:@""forKey:key.length>0?key:@""];
                }
            }else{
                //问号后面啥也没有 xxxx?  无需处理
            }
        }
        //整合url及参数
        return [URLObject makeObject:host params:params];
    }else if(allElements.count>2) {
        NSLog(@"连接不合法！连接包含多个\"?\"");
        return nil;
    }else{
        NSLog(@"连接不包含参数！");
        return [URLObject makeObject:host params:nil];
    }
}

+ (NSURL *)createGETURLFromString:(NSString *)urlString params:(NSDictionary *)params{
    if (urlString.length == 0){
        return nil;
    }
    
    if (params.allKeys.count == 0){
        return [NSURL URLWithString:urlString];
    }
    NSURL *parsedURL = [NSURL URLWithString:urlString];
    
    NSString* queryPrefix = parsedURL.query ? @"&" : @"?";
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in [params keyEnumerator]) {
        if (![[params objectForKey:key] isKindOfClass:[NSString class]]) {
            continue;
        }
        NSString *value = (NSString *)[params objectForKey:key];
        
        NSCharacterSet *allowedCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~"];
        
        NSString *urlEncodingKey = [key stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        NSString *urlEncodingValue = [value stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", urlEncodingKey, urlEncodingValue]];
    }
    NSString* query = [pairs componentsJoinedByString:@"&"];
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", urlString, queryPrefix, query]];
}
@end
