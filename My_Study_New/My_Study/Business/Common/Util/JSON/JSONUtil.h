//
//  JSONUtil.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/18.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSONUtil : NSObject

#pragma mark - Apple JSON <-> Id
/**
 * 字典，数组转成字符串
 */
+ (NSString *)jsonString:(id)object;

+ (NSString *)jsonString:(id)object options:(NSUInteger)options;

+ (id)jsonObject:(NSString *)json;

#pragma mark - MJExtension JSON <-> Model

/**
 * model转成json字符串
 */
+ (NSDictionary *)modelToJSONObject:(NSObject *)model;
/**
 * model转成json字符串
 */
+ (NSString *)modelToJSONString:(NSObject *)model;

/**
 * models 转成json字符串数组
 */
+ (NSString *)modelArraysToJSONString:(NSArray *)models;

/**
 * 字符串转成对象model
 * @param json 字符串，data，字典类型
 */
+ (id)parseObject:(id)json targetClass:(Class)cls;

/**
 *json字符串数组转成 对象model数组
 */
+ (NSArray *)parseObjectArrays:(NSArray<NSString *> *)jsonArrays targetClass:(Class)cls;

/**
*json字符串数组转成 字典*/
+ (NSDictionary *)jsonStringToDic:(NSString *)jsonStr;

+ (NSArray *)modelArraysToJSONObject:(NSArray *)models;

@end

NS_ASSUME_NONNULL_END
