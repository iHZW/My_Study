//
//  LogRouterIntercept.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "LogRouterIntercept.h"

@implementation LogRouterIntercept

- (RouterParam *)doIntercept:(RouterParam *)routerParam{
    
    if ([routerParam.originUrl hasPrefix:@"/client/list"] || [routerParam.originUrl hasPrefix:@"/client/select"]) {
//        BaseRequest * requset = [BaseRequest defaultRequest];
//        requset.data = routerParam.params;
//        [WM.http post:API_APP_VIEW_LIST_ROLE requestModel:requset complete:^(ResultObject * _Nonnull result) {
//            if (result.resultType == ResultTypeSuccess) {
//                if ([result.data boolValue] == true) {
//                    [subscriber sendNext:routerParam];
//                    [subscriber sendCompleted];
//                }else{
//                    NSError *error = [NSError defaultBreakError];
//                    [subscriber sendError:error];
//                }
//            }else{
//                NSError *error = [NSError defaultBreakError];
//                [subscriber sendError:error];
//            }
//        }];
        return routerParam;
    }else{
//        [subscriber sendNext:routerParam];
//        [subscriber sendCompleted];
        return routerParam;
    }
}

@end
