//
//  ZWNative.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWNative.h"
#import "ZWUserInfoBridgeModule.h"
#import "NSString+VersionCompare.h"

@implementation ZWNative

- (BOOL)checkJsRequest:(nullable NSURLRequest *)request webView:(WKWebView *)webView
{
    NSString *urlString = request.URL.absoluteString;
    
    if ([urlString hasPrefix:@"zwapp"]) {
        NSString *logString = [NSString stringWithFormat:@"拦截Web的URL: %@",urlString];
        [LogUtil debug:logString flag:@"ZWNative" context:self];
        
        NSDictionary * classAndParam = [self getActionAndParams:urlString];
        NSDictionary * param = classAndParam[@"data"][@"param"];
        NSString * action = classAndParam[@"action"];
                
//        id<ZWApiProtocol> apiObject = [WMOMApi createApiObject:urlString action:action group:[self apiGroup]];
//        ZWApiParam *savedApiParam = nil;
//        if ([apiObject respondsToSelector:@selector(savedApiParam)]){
//            savedApiParam = [apiObject savedApiParam];
//        }
        
        id apiObject;
        if (apiObject){
            NSDictionary * data = [param objectForKey:@"data"];
            BOOL needUpgrade = NO;
            if ([data isKindOfClass:[NSDictionary class]]){
                BOOL ignoreCompat = [data[@"ignoreCompat"] boolValue];
                NSString *minVersion = data[@"minVersion"];
                NSInteger compareResult = [NSString compareVersion:[ZWUserInfoBridgeModule appVersion] otherVersion:minVersion];
                if (!ignoreCompat && compareResult < 0){
                    //api 版本太低 需要升级
                    needUpgrade = YES;
                }
            }
            
            if (needUpgrade){
                /** 跳转升级引导页  */
                [ZWM.router executeURLNoCallBack:@"/h5/common/upgrade/version-tip"];
            } else {
//                __weak typeof(self) weakSelf = self;
//                ZWApiParam *apiParam = [ZWApiParam make:urlString action:action params:param completeBlock:^(id result, BOOL needNotifyH5) {
//                    if (needNotifyH5){
//                        __strong typeof(weakSelf) strongSelf = weakSelf;
//                        //录音，播放 每次通知h5 都使用开始事件的key
//                        NSDictionary *modifiedParam = savedApiParam.params ?: param;
//                        [strongSelf sendResponseToReact:result param:modifiedParam];
//                    }
//                }];
//                apiParam.webView = webView;
//                apiParam.group = [self apiGroup];
//                [apiObject execute:apiParam];
            }
            
        } else {
            //api 未实现，升级
            NSDictionary * data = [param objectForKey:@"data"];
            if ([data isKindOfClass:[NSDictionary class]]){
                BOOL ignoreCompat = [data[@"ignoreCompat"] boolValue];
                if (!ignoreCompat){
                    [ZWM.router executeURLNoCallBack:@"/h5/common/upgrade/version-tip"];
                }
            }
        }
        return NO;
    }
    return YES;
}

// 解析参数成对象

- (NSDictionary *)getActionAndParams:(NSString *)url{
    url = [url stringByRemovingPercentEncoding];
    NSArray *components = [url componentsSeparatedByString:@"?"];
    NSString *path = components.firstObject;
    if (path.length > 0){
        NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
        NSString *clsName = [[path componentsSeparatedByString:@"/"] lastObject];
        if (clsName.length > 0){
            mutDict[@"action"] = clsName;
        }
        NSString *dataStr = [url substringFromIndex:path.length];
        if (dataStr.length > 0){
            //去掉?
            dataStr = [dataStr substringFromIndex:1];
            
            if ([dataStr hasPrefix:@"param="]){
                NSString *parmasString = [dataStr substringFromIndex:6];

                id data = [JSONUtil jsonObject:parmasString];
                if (data){
                    NSMutableDictionary *mutParams = [NSMutableDictionary dictionaryWithCapacity:2];
                    mutParams[@"param"] = data;
                    mutParams[@"RouterURL"] = url;
                    mutDict[@"data"] = mutParams;
                }
            }
        }
        return mutDict;
    }
    return nil;
}


// return 回调h5的格式化数据
- (NSString *)getParamStr:(NSString *)key
                          code:(NSNumber *)code
                          data:(id)data
                       message:(NSString *)message{
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setObject:key forKey:@"key"];
    
    NSMutableDictionary * dataDic = [NSMutableDictionary dictionary];
    [dataDic setObject:code forKey:@"code"];
    [dataDic setObject:data forKey:@"data"];
    [dataDic setObject:message forKey:@"message"];

    [dic setObject:dataDic forKey:@"data"];
    
    NSData * dicData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString * result = [[NSString alloc]initWithData:dicData encoding:NSUTF8StringEncoding];
    
    return result;
}

@end
