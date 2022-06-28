//
//  URLObject.m
//  CRM
//
//  Created by js on 2021/12/10.
//  Copyright © 2021 CRM. All rights reserved.
//

#import "URLObject.h"

@implementation URLObject
+ (instancetype)makeObject:(NSString *)host params:(nullable NSDictionary *)params{
    URLObject *object = [[URLObject alloc] init];
    object.host = host;
    object.params = params;
    return object;
}
@end
