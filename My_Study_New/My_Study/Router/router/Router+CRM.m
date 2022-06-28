//
//  Router+CRM.m
//  CRM
//
//  Created by js on 2019/8/20.
//  Copyright © 2019 js. All rights reserved.
//

#import "Router+CRM.h"

@implementation Router (CRM)
+ (void)push:(NSString *)clsName
      params:(NSDictionary *)params
     context:(id)context{
    [self push:clsName params:params context:context success:nil fail:nil];
}

+ (void)push:(NSString *)clsName
      params:(NSDictionary *)params
     context:(id)context
     success:(nullable void (^)(id))successBlock
        fail:(nullable void (^)(NSError *))failBlock{
    RouterParam *routerParam = [RouterParam makeWith:@"" destURL:clsName params:params type:RouterTypeNavigate context:context];
    [ZWM.router execute:routerParam success:successBlock fail:failBlock];
}

+ (void)present:(NSString *)clsName
         params:(NSDictionary *)params
        context:(id)context{
    [self present:clsName params:params context:context success:nil fail:nil];
}

+ (void)present:(NSString *)clsName
      params:(NSDictionary *)params
        context:(id)context
     success:(nullable void (^)(id))successBlock
        fail:(nullable void (^)(NSError *))failBlock{
    RouterParam *routerParam = [RouterParam makeWith:@"" destURL:clsName params:params type:RouterTypeNavigatePresent context:context];
    [ZWM.router execute:routerParam success:successBlock fail:failBlock];
}

+ (NSString *)urlEncode:(NSDictionary *)param{
    NSString *jsonString = [JSONUtil jsonString:param options:0];
    NSCharacterSet *characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<>:?@/,;? "] invertedSet];
    jsonString = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    return jsonString;
}

+ (NSString *)encodeRouterUrl:(NSString *)url params:(NSDictionary *)params{
    if (params != nil){
        NSMutableDictionary *mutDict = [NSMutableDictionary dictionaryWithDictionary:params];
        if ([url containsString:@"?param="]){
            NSDictionary *dict = [self decodeRouterUrl:url];
            NSString *path = [dict objectForKey:@"path"];
            id data = [dict objectForKey:@"data"];
            if ([data isKindOfClass:[NSDictionary class]]){
                [mutDict addEntriesFromDictionary:data];
                NSString *route = [NSString stringWithFormat:@"%@?param=%@",path,[self urlEncode:mutDict]];
                return route;
            } else {
                return url;
            }
            return nil;
        } else {
            NSString *route = [NSString stringWithFormat:@"%@?param=%@",url,[self urlEncode:params]];
            return route;
        }
    } else {
        return url;
    }
    
}

+ (NSDictionary *)decodeRouterUrl:(NSString *)route{
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    route = route;
    NSArray *components = [route componentsSeparatedByString:@"?"];
    NSString *path = components.firstObject;
    if (path.length > 0){
        mutDict[@"path"] = path;
        NSString *dataStr = components.lastObject;
        if (dataStr.length > 0){
            if ([dataStr hasPrefix:@"param="]){
                NSString *parmasString = [dataStr substringFromIndex:6];
                //URL解码
                parmasString = [parmasString stringByRemovingPercentEncoding];
                
                id data = [JSONUtil jsonObject:parmasString];
                mutDict[@"data"] = data;
            }
        }
    }
    return mutDict;
}
#warning -- 拼接 universalLink 处理的域名
+ (NSString *)appCustomDomain{
    /** 拼接域名  */
    return @"https://zw.home.cn";
//    NSString *url = [NSString stringWithFormat:@"https://%@",[Config sharedInstance].associatedDomain];
//    return url;
}

#warning -- 拼接  schema
+ (NSString *)appCustomSchema{
    /** 拼接schema  */
    return @"zwapp://zw.app/open";
//    NSString *url = [NSString stringWithFormat:@"%@://%@/open",[Config sharedInstance].crmScheme,[Config sharedInstance].crmHost];
//    return url;
}

+ (void)openApp:(NSString *)universalLink{
    NSArray *components = [universalLink componentsSeparatedByString:@"?"];
    if (components.count == 2){
        NSString *path = components.firstObject;
        if ([path hasPrefix:[self appCustomDomain]]){
            NSString *params = components.lastObject;
            
            if ([params hasPrefix:@"param="]){
                NSString *param = [params substringFromIndex:6];
                NSString *appURL = [param stringByRemovingPercentEncoding];
                
                NSString *suffix = [NSString stringWithFormat:@"%@?param=",[self appCustomSchema]];
                if ([appURL hasPrefix:suffix]){
                    NSString *appRouteDictString = [appURL substringFromIndex:suffix.length];
                    
                    NSDictionary *routeDict = [JSONUtil jsonObject:[appRouteDictString stringByRemovingPercentEncoding]];
                    if (routeDict){
                        NSString *route = [Router encodeRouterUrl:[routeDict objectForKey:@"route"] params:[routeDict objectForKey:@"param"]];
                        [ZWM.router executeURLNoCallBack:route];
                    }
                }
            }
        } else {
            NSString *suffix = [NSString stringWithFormat:@"%@?param=",[self appCustomSchema]];
            if ([universalLink hasPrefix:suffix]){
                NSString *appRouteDictString = [universalLink substringFromIndex:suffix.length];
                
                NSDictionary *routeDict = [JSONUtil jsonObject:[appRouteDictString stringByRemovingPercentEncoding]];
                if (routeDict){
                    NSString *route = [Router encodeRouterUrl:[routeDict objectForKey:@"route"] params:[routeDict objectForKey:@"param"]];
                    [ZWM.router executeURLNoCallBack:route];
                }
            }
        }
    }
}

+ (BOOL)supportOpenApp{
    return 1;
//    LoginResponse *response = UserManager.sharedInstance.loginResponse;
//    return response.indexType == 1;
}

+ (BOOL)canOpenApp:(NSString *)universalLink{
    NSArray *components = [universalLink componentsSeparatedByString:@"?"];
    if (components.count == 2){
        NSString *path = components.firstObject;
        if ([path hasPrefix:[self appCustomDomain]]){
            NSString *params = components.lastObject;
            
            if ([params hasPrefix:@"param="]){
                NSString *param = [params substringFromIndex:6];
                NSString *appURL = [param stringByRemovingPercentEncoding];
                
                NSString *suffix = [NSString stringWithFormat:@"%@?param=",[self appCustomSchema]];
                if ([appURL hasPrefix:suffix]){
                    NSString *appRouteDictString = [appURL substringFromIndex:suffix.length];
                    
                    NSDictionary *routeDict = [JSONUtil jsonObject:[appRouteDictString stringByRemovingPercentEncoding]];
                    if (routeDict){
                        return YES;
                    }
                }
            }
        } else {
            NSString *suffix = [NSString stringWithFormat:@"%@?param=",[self appCustomSchema]];
            if ([universalLink hasPrefix:suffix]){
                NSString *appRouteDictString = [universalLink substringFromIndex:suffix.length];
                
                NSDictionary *routeDict = [JSONUtil jsonObject:[appRouteDictString stringByRemovingPercentEncoding]];
                if (routeDict){
                    return YES;
                }
            }
        }
    }
    return NO;
}
@end
