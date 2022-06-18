//
//  JSONUtil.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/18.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "JSONUtil.h"
#import "LogUtil.h"
#import "NSArray+Func.h"

@implementation JSONUtil

+ (NSString *)jsonString:(id)object{
    return [self jsonString:object options:NSJSONWritingPrettyPrinted];
}

+ (NSString *)jsonString:(id)object options:(NSUInteger)options{
    if (object == nil){
        return nil;
    }
    
    if ([object isKindOfClass:[NSString class]]){
        return object;
    }
    
    BOOL isData = [object isKindOfClass:[NSData class]];
    if (isData){
        return [[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding];
    } else {
        NSError* error = nil;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                           options:options
                                                             error:&error];
        
        if (error != nil) {
            [LogUtil error:[NSString stringWithFormat:@"JSONString error: %@", [error localizedDescription]] flag:nil context:self];
            return nil;
        } else {
            return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }
    
}

+ (id)jsonObject:(NSString *)string{
    if (string == nil){
        return nil;
    }
    NSError* error = nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error != nil){
        [LogUtil error:[NSString stringWithFormat:@"JSONObject error: %@", [error localizedDescription]] flag:nil context:self];
        return nil;
    } else{
        return object;
    }
}

+ (NSDictionary *)modelToJSONObject:(NSObject *)model{
    if (model == nil){
        return nil;
    }
    return [model mj_JSONObject];
}

+ (NSString *)modelToJSONString:(NSObject *)model{
    if (model == nil){
        return nil;
    }
    return [model mj_JSONString];
}


+ (NSString *)modelArraysToJSONString:(NSArray *)models{
    if (models.count == 0){
        return nil;
    }
    
    NSArray *resultArray = [models flatMap:^id _Nonnull(id  _Nonnull item) {
        return [item mj_keyValues];
    }];
    return [JSONUtil jsonString:resultArray options:0];
}

+ (NSArray *)modelArraysToJSONObject:(NSArray *)models{
    if (models.count == 0){
        return nil;
    }
    
    NSArray *resultArray = [models flatMap:^id _Nonnull(id  _Nonnull item) {
        return [JSONUtil modelToJSONObject:item];
    }];
    return resultArray;
}
/**
 * 字符串转成对象
 */
+ (id)parseObject:(id)json targetClass:(Class)cls{
    if (json == nil){
        return nil;
    }
    if (cls == nil){
        return nil;
    }
    
    id result = nil;
    id object = [[cls alloc] init];
    result = [object mj_setKeyValues:json];
    return result;
}

+ (NSArray *)parseObjectArrays:(NSArray<NSString *> *)jsonArrays targetClass:(Class)cls{
    if (jsonArrays.count == 0){
        return nil;
    }
    return [jsonArrays flatMap:^id _Nonnull(id  _Nonnull item) {
        return [JSONUtil parseObject:item targetClass:cls];
    }];
}

+ (NSDictionary *)jsonStringToDic:(NSString *)jsonStr{
    if (jsonStr.length <= 0) {
        return nil;
    }
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        [LogUtil error:[NSString stringWithFormat:@"JSONObject error: %@", [err localizedDescription]] flag:nil context:self];
        return nil;
    }
    return dic;
}



@end
