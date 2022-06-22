//
//  DataFormatterFunc.h
//  TZYJ_IPhone
//
//  Created by Howard on 15/8/6.
//
//

#import <Foundation/Foundation.h>

#define kNumbers     @"0123456789"
#define kNumbersPeriod  @"0123456789."

#define PASArrayAtIndex(array,i) [DataFormatterFunc checkArray:array index:i]

#define TransToString(s)  [DataFormatterFunc validStringValue:s]

#define TransToArray(s)  [DataFormatterFunc validArrayValue:s]

#define TransToDictionary(s) [DataFormatterFunc validDictionaryValue:s]

/* 根据规则过滤文本 */
#define TransFilterString(s, f) [DataFormatterFunc filterWithString:s formatType:f]

#define ValidString(s) [DataFormatterFunc bolString:s]

#define ValidArray(s) [DataFormatterFunc isValidArray:s]

#define ValidDictionary(s) [DataFormatterFunc isValidDictionary:s]


/**
 *  除法返回float精度问题 A/B
 *
 *  @param v   A
 *  @param d   B
 *
 *  @return 返回float
 */
#define TransToFloat(v,d) [DataFormatterFunc decimalNumberForFloat:v decimal:d]
@interface DataFormatterFunc : NSObject

/**
 *  将数值型转换字符串
 *
 *  @param v   转换数值
 *  @param len 最后字符串显示长度(如果数据总长度大于len,则从前往后截取位数, len数值保留足够大位数)
 *  @param dig 小数位数
 *
 *  @return 返回转换后字符串
 */
+ (NSString *)formatDStr:(double)v len:(NSInteger)len dig:(NSInteger)dig;

+ (BOOL)isPureInt:(NSString *)string;

+ (BOOL)isPureFloat:(NSString *)string;

+ (BOOL)isPureAlpha:(NSString *)string;

+ (BOOL)isPureAlphaNumber:(NSString *)string;

+ (BOOL)isPureNumber:(NSString *)string;

// 根据过滤规则 过滤文本
+ (NSString *)filterWithString:(NSString *)str formatType:(NSString *)formatType;

/**
 判断对象是否是nil或者null

 @param object 传入对象
 @return YES:为nil或null，否则为NO
 */
+ (BOOL)bolNull:(NSObject *)object;

/**
 *  是否是长度大于0的字符串
 *
 *  @param string 字符串
 *
 *  @return 返回结果
 */
+ (BOOL)bolString:(NSString *)string;

+ (BOOL)isValidArray:(id)value;

+ (BOOL)isValidDictionary:(id)value;

/**
 *  格式化json字段的值
 *
 *  @param value json
 *
 *  @return 返回NSString类型数据
 对应键值数据转换做如下处理
 1.[NSNull null]     ==>  @""
 2. NSString         ==> 直接返回
 3. NSNumber         ==> 转换NSString类型后返回
 4. NSArray          ==> 将数组元素用 @"," 拼接后返回
 */
+ (NSString *)formatJsonValue:(id)value;

/**
 *  检测string的有效性
 *
 *  @param string 字符串对象
 *
 *  @return 返回非nil,非[NSNull null] 字符串
 */
+ (NSString *)validStringValue:(NSString *)string;

/**
 *  检测字典的有效性
 *
 *  @param dictionary 字典对象
 *
 *  @return 返回非nil的字典对象
 */
+ (NSDictionary *)validDictionaryValue:(NSDictionary *)dictionary;

/**
 * 检测数组有效性
 *
 *  @param array 数组对象
 *
 *  @return 非空数组对象
 */
+ (NSArray *)validArrayValue:(NSArray *)array;

/**
 防止数组越界
 
 @param array 数组对象
 @param index 下标
 @return 检索对象，查不到返回nil
 */
+ (id)checkArray:(NSArray *)array index:(NSUInteger)index;

/**
 解决float 除法精度问题  A/B
 
 @param value A
 @param decimal B
 @return 结果
 */
+ (float)decimalNumberForFloat:(float)value decimal:(float)decimal;

/**
 将字典转化为get请求url字符串

 @param dict 传入字典参数
 @return 返回拼接后的字符串
 */
+ (NSString *)parseDictionaryToUrlStr:(NSDictionary *)dict;

/**
 乘法
 */
+ (NSString *)decimalNumberWithMultiplyingBy:(NSString *)decimal1 by:(NSString *)decimal2;

/**
 加法
 */
+ (NSString *)decimalNumberWithAddBy:(NSString *)decimal1 by:(NSString *)decimal2;

@end
