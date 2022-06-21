//
//  DataFormatterFunc+JSON.h
//  TZYJ_IPhone
//
//  Created by Howard on 15/8/6.
//
//

#import "DataFormatterFunc.h"

@interface DataFormatterFunc(JSON)

/**
 *  从对应字典数据中，获取指定键值的NSString类型数据
 *
 *  @param key  字段键值名称
 *  @param dict 对应字典数据
 *
 *  @return 返回指定键值的NSString类型的数据(如果数据非法返回 @"")
 */
+ (NSString *)strValueForKey:(id)key ofDict:(NSDictionary *)dict;

/**
 *  从对应字典数据中，获取指定键值的NSNumber类型数据
 *
 *  @param key  字段键值名称
 *  @param dict 对应字典数据
 *
 *  @return 返回指定键值的NSNumber类型数据(如果数据非法返回 @(0))
 */
+ (NSNumber *)numberValueForKey:(id)key ofDict:(NSDictionary *)dict;

/**
 *  从对应字典数据中，获取指定键值的NSArray类型数据
 *
 *  @param key  字段键值名称
 *  @param dict 对应字典数据
 *
 *  @return 返回指定键值的NSArray类型数据(如果数据非法返回 @[])
 */
+ (NSArray *)arrayValueForKey:(id)key ofDict:(NSDictionary *)dict;

/**
 *  从对应字典数据中，获取指定键值的NSDictionary类型数据
 *
 *  @param key  字段键值名称
 *  @param dict 对应字典数据
 *
 *  @return 返回指定键值的NSDictionary类型数据(如果数据非法返回 @{})
 */
+ (NSDictionary *)dictionaryValueForKey:(id)key ofDict:(NSDictionary *)dict;

/**
 *  将JSON对象转换为NSDictionary对象
 *
 *  @param jsonObj JSON数据对象
 *
 *  @return 返回转换后字典对象(如果JSON对象非字典类型，则返回nil)
 */
+ (NSDictionary *)convertDictionary:(id)jsonObj;

/**
 *  将JSON对象转换为NSArray对象
 *
 *  @param jsonObj JSON数据对象
 *
 *  @return 返回转换数组对象(如果JSON对象非数组类型，则返回nil)
 */
+ (NSArray *)convertArray:(id)jsonObj;

/**
 *  从网络地址把JSON数据解释成对象
 *
 *  @param urlStr 链接地址
 *  @param error  错误信息
 *
 *  @return JSON对象
 */
+ (id)jsonObjectFromUrl:(NSString *)urlStr error:(NSError **)error;

/**
 *  从文件路径提取JSON数据并解析成JSON对象
 *
 *  @param filePath 文件路径
 *  @param error    错误信息
 *
 *  @return JSON对象
 */
+ (id)jsonObjectFromFilePath:(NSString *)filePath error:(NSError **)error;

/**
 *  将JSON对象序列化二进制数据
 *
 *  @param obj JSON对象
 *  @param err NSError错误信息
 *
 *  @return 返回二进制数据
 */
+ (NSData *)dataFromJSONObject:(id)obj error:(NSError **)err;

/**
 *  将JSON对象序列化二进制数据
 *
 *  @param obj    JSON对象
 *  @param option NSJSONWritingOptions
 *  @param err    NSError错误信息
 *
 *  @return 返回二进制数据
 */
+ (NSData *)dataFromJSONObjectWithOption:(id)obj options:(NSJSONWritingOptions)option error:(NSError **)err;

/**
 *  将JSON对象序列化二UTF8String
 *
 *  @param obj JSON对象
 *  @param err NSError错误信息
 *
 *  @return 返回UTF8String
 */
+ (NSString *)stringFromJSONObject:(id)obj error:(NSError **)err;
/**
 *  将JSON对象序列化二UTF8String
 *
 *  @param obj    JSON对象
 *  @param option NSJSONWritingOptions
 *  @param err    NSError错误信息
 *
 *  @return 返回UTF8String
 */
+ (NSString *)stringFromJSONObjectWithOption:(id)obj options:(NSJSONWritingOptions)option error:(NSError **)err;

/**
 *  根据二进制数据生成JSON对象
 *
 *  @param data 二进制数据
 *  @param err  NSError错误信息
 *
 *  @return JSON对象
 */
+ (id)jsonObjectFromData:(NSData *)data error:(NSError **)err;

/**
 *  根据二进制数据生成JSON对象
 *
 *  @param data   二进制数据
 *  @param option NSJSONReadingOptions
 *  @param err    NSError错误信息
 *
 *  @return JSON对象
 */
+ (id)jsonObjectFromDataWithOption:(NSData *)data options:(NSJSONReadingOptions)option error:(NSError **)err;

/**
 *  根据字符串信息返回JSON对象
 *
 *  @param str JSON字符串信息
 *  @param err NSError错误信息
 *
 *  @return JSON对象
 */
+ (id)jsonObjectFromString:(NSString *)str error:(NSError **)err;

/**
 *  根据字符串信息返回JSON对象
 *
 *  @param str    JSON字符串信息
 *  @param option NSJSONReadingOptions
 *  @param err    NSError错误信息
 *
 *  @return JSON对象
 */
+ (id)jsonObjectFromStringWithOption:(NSString *)str options:(NSJSONReadingOptions)option error:(NSError **)err;

/**
 *  将字典格式化成JSON字符串
 *
 *  @param dict 字典数据
 *
 *  @return JSON字符串
 */
+ (NSString *)formatJsonStrWithDictionary:(NSDictionary *)dict;

/**
 *  将数组格式化成JSON字符串
 *
 *  @param array 数组数据
 *
 *  @return JSON字符串
 */
+ (NSString *)formatJsonStrWithArray:(NSArray *)array;

/**
 *  将JSON字符串解析为字典数据
 *
 *  @param jsonStr JSON字符串
 *
 *  @return 字典数据
 */
+ (NSDictionary *)parseToDict:(NSString *)jsonStr;

/**
 *  将JSON二进制数据解析为字典数据
 *
 *  @param jsonData JSON二进制数据
 *
 *  @return 字典数据
 */
+ (NSDictionary *)parseDataToDict:(NSData *)jsonData;

/**
 *  将JSON字符串解析为数组数据
 *
 *  @param jsonStr JSON字符串
 *
 *  @return 数组数据
 */
+ (NSArray *)parseToArray:(NSString *)jsonStr;

/**
 *  将JSON二进制数据解析为数组数据
 *
 *  @param jsonData JSON二进制数据
 *
 *  @return 数组数据
 */
+ (NSArray *)parseDataToArray:(NSData *)jsonData;

@end


#pragma mark - Deserializing methods

@interface NSString (JSONDeserializing)

- (id)objectByJSONString;
- (id)objectByJSONStringWithParseOptions:(NSJSONReadingOptions)option error:(NSError **)err;

@end

@interface NSData (JSONDeserializing)

// The NSData MUST be UTF8 encoded JSON.
- (id)objectByJSONData;
- (id)objectByJSONDataWithParseOptions:(NSJSONReadingOptions)option error:(NSError **)err;

@end


#pragma mark - Serializing methods

@interface NSString (JSONKitSerializing)
// Convenience methods for those that need to serialize the receiving NSString (i.e., instead of having to serialize a NSArray with a single NSString, you can "serialize to JSON" just the NSString).
// Normally, a string that is serialized to JSON has quotation marks surrounding it, which you may or may not want when serializing a single string, and can be controlled with includeQuotes:
// includeQuotes:YES `a "test"...` -> `"a \"test\"..."`
// includeQuotes:NO  `a "test"...` -> `a \"test\"...`
- (NSData *)toJSONData;     // Invokes JSONDataWithOptions:kNilOptions
- (NSData *)toJSONDataWithOptions:(NSJSONWritingOptions)opiton error:(NSError **)err;
- (NSString *)toJSONString; // Invokes JSONStringWithOptions:kNilOptions
- (NSString *)toJSONStringWithOptions:(NSJSONWritingOptions)opiton error:(NSError **)err;

@end

@interface NSArray (JSONKSerializing)

- (NSData *)toJSONData;
- (NSData *)toJSONDataWithOptions:(NSJSONWritingOptions)opiton error:(NSError **)err;
- (NSString *)toJSONString;
- (NSString *)toJSONStringWithOptions:(NSJSONWritingOptions)opiton error:(NSError **)err;

@end


@interface NSDictionary (JSONKitSerializing)

- (NSData *)toJSONData;
- (NSData *)toJSONDataWithOptions:(NSJSONWritingOptions)opiton error:(NSError **)err;
- (NSString *)toJSONString;
- (NSString *)toJSONStringWithOptions:(NSJSONWritingOptions)opiton error:(NSError **)err;

@end

