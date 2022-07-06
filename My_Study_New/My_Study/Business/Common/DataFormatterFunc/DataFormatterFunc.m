//
//  DataFormatterFunc.m
//  TZYJ_IPhone
//
//  Created by Howard on 15/8/6.
//
//

#import "DataFormatterFunc.h"

#define kAlphaNum  @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
#define kAlpha      @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "


@implementation DataFormatterFunc

#pragma mark - private's method
/**
 *  数值转换城字符串
 *
 *  @param val 数值类型
 *  @param str 转换字符串数据
 *
 *  @return 转换字符串数据
 */
+ (char *)itoa:(NSInteger)val str:(char *)str
{
    NSInteger i = 0, sign;
    
    if((sign = val) < 0) {
        val = -val;
    }
    
    do
    {
        str[i++] = val % 10 + '0';
    }while ((val /= 10) > 0 && i < val);
    
    if(sign < 0)
        str[i++] = '-';
    str[i] = '\0';
    
    return str;
}

+ (BOOL)checkInputWithType:(NSString *)string formatType:(NSString *)formatType
{
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:formatType] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basic = [string isEqualToString:filtered];
    
    return basic;
}

// 根据过滤规则 过滤文本
+ (NSString *)filterWithString:(NSString *)str formatType:(NSString *)formatType
{
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:formatType];
    NSCharacterSet *specCharacterSet = [characterSet invertedSet];
    NSString *string = str;
    NSArray *strArr = [string componentsSeparatedByCharactersInSet:specCharacterSet];
    return [strArr componentsJoinedByString:@""];
}

#pragma mark - public's method
/**
 *  将数值型转换字符串
 *
 *  @param v   转换数值
 *  @param len 最后字符串显示长度(如果数据总长度大于len,则从前往后截取位数, len数值保留足够大位数)
 *  @param dig 小数位数
 *
 *  @return 返回转换后字符串
 */
+ (NSString *)formatDStr:(double)v len:(NSInteger)len dig:(NSInteger)dig
{
    NSInteger ln, rn, tmpsz = MAX(len,sizeof(double));
    char floatstr[tmpsz], temp[LDBL_DIG], formatStr[10], formatStr2[10] = {'%'};
    
    memset(floatstr, 0, sizeof(floatstr));
    memset(temp, 0, sizeof(temp));
    memset(formatStr, 0, sizeof(formatStr));
    
    [[self class] itoa:MIN(MAX(dig, 0), LDBL_DIG) str:temp];
    sprintf(formatStr, ".%sf", temp);
    strcat(formatStr2, formatStr);
    sprintf(floatstr, formatStr2, v);
    
    NSString * vv = [NSString stringWithUTF8String:floatstr];
    NSString *strRetVal = nil;
    
    NSRange rang     = [vv rangeOfString:@"."];
    ln                 = rang.location;
    rn                 = [vv length] - ln - 1;
    
    if (rang.location != NSNotFound)
    {
        NSRange subrangL, subrangR;
        NSString *rightstr;
        subrangL.location     = 0;
        subrangL.length     = MAX(ln, 0);
        NSString *leftstr     = [vv substringWithRange:subrangL];
        subrangR.location     = ln + 1;
        subrangR.length     = MAX(rn, 0);
        NSString *rightstrO = [vv substringWithRange:subrangR];
        NSInteger over         = [vv length] - len;
        
        if (over > 0)
        {
            NSRange r;
            r.location     = 0;
            r.length     = MIN([rightstrO length] - over, [rightstrO length]);
            rightstr     = [rightstrO substringWithRange:r];
        }
        else
            rightstr = rightstrO;
        
        if ([rightstr length] > 0 && [leftstr length] < len)
            strRetVal = [NSString stringWithFormat:@"%@.%@", leftstr, rightstr];
        else
            strRetVal = leftstr;
    }
    else
        strRetVal = vv;
    
    return strRetVal;
}

+ (BOOL)isPureInt:(NSString *)string
{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

+ (BOOL)isPureFloat:(NSString *)string
{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

+ (BOOL)isPureAlpha:(NSString *)string
{
    return [[self class] checkInputWithType:string formatType:kAlpha];
}

+ (BOOL)isPureAlphaNumber:(NSString *)string
{
    return [[self class] checkInputWithType:string formatType:kAlphaNum];
}

+ (BOOL)isPureNumber:(NSString *)string
{
    return [[self class] checkInputWithType:string formatType:kNumbers];
}

+ (BOOL)bolNull:(NSObject *)object
{
    BOOL result = NO;
    if ((object == [NSNull null])||object == nil) {
        result = YES;
    }
    return result;
}

+ (BOOL)bolString:(NSString *)string
{
    BOOL result = ![DataFormatterFunc bolNull:string];
    if (result) {
        if ([string isKindOfClass:[NSString class]]) {
            result = string.length;
        } else {
            result = NO;
        }
    }
    return result;
}

+ (BOOL)isValidArray:(id)value
{
    if (value) {
        if ([value isKindOfClass:[NSArray class]]) {
            return [(NSArray*)value count] > 0;
        }
    }
    
    return NO;
}

+ (BOOL)isValidDictionary:(id)value
{
    if (value) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            return [(NSDictionary*)value count]>0;
        }
    }
    return NO;
}

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
+ (NSString *)formatJsonValue:(id)value
{
    if (value == [NSNull null])
        return @"";
    else if ([value isKindOfClass:[NSString class]])
        return value;
    else if ([value isKindOfClass:[NSNumber class]])
        return [(NSNumber *)value stringValue];
    else if ([value isKindOfClass:[NSArray class]])
        return [(NSArray *)value componentsJoinedByString:@","];
    
    return @"";
}

/**
 *  检测string的有效性
 *
 *  @param string 字符串对象
 *
 *  @return 返回非nil,非[NSNull null] 字符串
 */
+ (NSString *)validStringValue:(NSString *)string
{
    NSString *retVal = !string ? @"" : [DataFormatterFunc formatJsonValue:string];
    return retVal;
}

+ (NSDictionary *)validDictionaryValue:(NSDictionary *)dictionary
{
    NSDictionary *dict = [dictionary isKindOfClass:[NSDictionary class]] ? dictionary : [NSDictionary dictionary];
    return dict;
}

+ (NSArray *)validArrayValue:(NSArray *)array
{
    NSArray *resultArr = [array isKindOfClass:[NSArray class]] ? array : [NSArray array];
    return resultArr;
}

+ (id)checkArray:(NSArray *)array index:(NSUInteger)index
{
    if (index >= [array count]) {
        return nil;
    }
    
    id value = [array objectAtIndex:index];
    if (value == [NSNull null]) {
        return nil;
    }
    return value;
}

/**
 解决float 除法精度问题  A/B
 
 @param value A
 @param decimal B
 @return 结果
 */
+ (float)decimalNumberForFloat:(float)value decimal:(float)decimal
{
    NSDecimalNumber* n1 = [NSDecimalNumber       decimalNumberWithString:[NSString    stringWithFormat:@"%f",value]];
    NSDecimalNumber* n2 = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",decimal]];
    // 6.17优化 防止除数为0引起crash
    NSDecimalNumber* n3 = n2.floatValue == 0 ? 0 :[n1 decimalNumberByDividingBy:n2];
    return [n3 floatValue];
}

+ (NSString *)decimalNumberWithMultiplyingBy:(NSString *)decimal1 by:(NSString *)decimal2
{
    
    NSDecimalNumber* n1 = [NSDecimalNumber       decimalNumberWithString:decimal1];
    NSDecimalNumber* n2 = [NSDecimalNumber decimalNumberWithString:decimal2];
    if (n1 == [NSDecimalNumber notANumber]) {
        n1 = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    if (n2 == [NSDecimalNumber notANumber]) {
        n2 = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    NSDecimalNumber* n3 = [n1 decimalNumberByMultiplyingBy:n2];
    return [n3 stringValue];
}

+ (NSString *)decimalNumberWithAddBy:(NSString *)decimal1 by:(NSString *)decimal2
{
    NSDecimalNumber* n1 = [NSDecimalNumber       decimalNumberWithString:decimal1];
    NSDecimalNumber* n2 = [NSDecimalNumber decimalNumberWithString:decimal2];
    if (n1 == [NSDecimalNumber notANumber]) {
        n1 = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    if (n2 == [NSDecimalNumber notANumber]) {
        n2 = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    
    NSDecimalNumber* n3 = [n1 decimalNumberByAdding:n2];
    return [n3 stringValue];
}

/**12
 将字典转化为get请求url字符串
 
 @param dict 参数
 @return url 字符串
 */
+ (NSString *)parseDictionaryToUrlStr:(NSDictionary *)dict{
    NSArray *keys;
    NSUInteger i, count;
    NSString *key = @"";
    NSString *value = @"";
    NSMutableString *url = [NSMutableString stringWithString:@"?"];
    keys = [dict allKeys];
    count = [keys count];
    for (i = 0; i < count; i++)
    {
        key = [keys objectAtIndex: i];
        value = [dict objectForKey: key];
        NSLog (@"Key: %@ for value: %@", key, value);
        [url appendString:key];
        [url appendString:@"="];
        [url appendString:value];
        if (i != count-1) {
            [url appendString:@"&"];
        }
    }
    return url;
}

@end
