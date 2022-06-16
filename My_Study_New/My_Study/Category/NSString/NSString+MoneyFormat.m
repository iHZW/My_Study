//
//  NSString+MoneyFormat.m
//  PASecuritiesApp
//
//  Created by Weirdln on 16/6/1.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "NSString+MoneyFormat.h"
#import "DataFormatter.h"
#import "NSString+NumberFormat.h"

static NSNumberFormatter *numberFormatter;
static BOOL isHaveDian;

@implementation NSString (MoneyFormat)

+ (NSNumberFormatter *)sharedNumberFormatter
{
    if (!numberFormatter)
    {
        numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    }
    return numberFormatter;
}

- (NSString *)formatToDecimalString
{
    return [self formatToNumberStyle:NSNumberFormatterDecimalStyle];
}

- (NSString *)formatToNumberStyle:(NSNumberFormatterStyle)numberStyle
{
    [[self class] sharedNumberFormatter].numberStyle = numberStyle;
    NSString *string = [[[self class] sharedNumberFormatter] stringFromNumber:@(self.doubleValue)];
    return string;
}

- (NSInteger)getNumberOfDecimalPoint
{
    NSArray *tmpArr = [self componentsSeparatedByString:@"."];
    NSInteger num = [tmpArr count] > 1 ? [tmpArr[1] length] : 0;
    return num;
}

+ (NSString *)convertCharacterMoneyToDigital:(NSString *)characterMoney
{
    double digitalMoney = characterMoney.doubleValue;
    NSInteger pointNumber = MAX(2, [characterMoney getNumberOfDecimalPoint]);
    // 累计相乘，兼容所有数字
    if ([characterMoney rangeOfString:@"十"].location != NSNotFound)
    {
        digitalMoney *= 10.0;
    }
    if ([characterMoney rangeOfString:@"百"].location != NSNotFound)
    {
        digitalMoney *= 100.0;
    }
    if ([characterMoney rangeOfString:@"千"].location != NSNotFound)
    {
        digitalMoney *= 1000.0;
    }
    if ([characterMoney rangeOfString:@"万"].location != NSNotFound)
    {
        digitalMoney *= 10000.0;
    }
    if ([characterMoney rangeOfString:@"亿"].location != NSNotFound)
    {
        digitalMoney *= 100000000.0;
    }
    return [DataFormatterFunc formatDStr:digitalMoney len:20 dig:pointNumber];
}

- (NSString *)convertCharacterMoneyToDigital
{
    return [[self class] convertCharacterMoneyToDigital:self];
}

- (NSString *)formatToMoneyStyle
{
    return [self formatToMoneyStyleSpecialRoundingWithDecimalPoint:[self getNumberOfDecimalPoint]];
}

- (NSString *)formatToMoneyStyleWithDecimalPoint:(NSInteger)decimalPoint
{
    return  [[self class] formatValue:self.doubleValue decimalPoint:decimalPoint];
}

- (NSString *)formatToMoneyStyleWithNoPoint
{
    return [self formatToMoneyStyleWithDecimalPoint:0];
}
/**
 *  按照传入的小数点位数将自己格式化成金额格式,并金额超过一个亿截取时，不遵从四舍五入规则
 */
- (NSString *)formatToMoneyStyleSpecialRoundingWithDecimalPoint:(NSInteger)decimalPoint
{
    if ([self isEqualToString:@"--"]) {
        return self;
    }
    double value = self.doubleValue;
    long valueLint = 0;
    [[self class] sharedNumberFormatter].numberStyle = NSNumberFormatterNoStyle;
    NSMutableString *formatStr = [NSMutableString stringWithString:@"###,##0"]; //默认不显示小数点
    if (value < 100000000 && value > -100000000) // 大于100000000不显示小数点，按照默认格式
    {
        if (decimalPoint > 0)
            [formatStr appendString:@"."];
        for (NSInteger i = 0; i < decimalPoint; i++)
        {
            [formatStr appendString:@"0"];
        }
        if (decimalPoint > 0)
            [formatStr appendString:@";"];
    }else{
        valueLint = floor(value);
        if (value <= -100000000) {
            valueLint = floor(value*(-1));
            valueLint = valueLint *(-1);
        }
    }
    if (valueLint != 0) {
        [[[self class] sharedNumberFormatter] setPositiveFormat:formatStr];
        NSString *string = [[[self class] sharedNumberFormatter] stringFromNumber:@(valueLint)];
        return string;
    }
    [[[self class] sharedNumberFormatter] setPositiveFormat:formatStr];
    NSString *string = [[[self class] sharedNumberFormatter] stringFromNumber:@(value)];
    return string;
    
}
+ (NSString *)formatValue:(CGFloat)value decimalPoint:(NSInteger)decimalPoint
{
    [[self class] sharedNumberFormatter].numberStyle = NSNumberFormatterNoStyle;
    NSMutableString *formatStr = [NSMutableString stringWithString:@"###,##0"]; //默认不显示小数点
    if (value < 100000000) // 大于100000000不显示小数点，按照默认格式
    {
        if (decimalPoint > 0)
            [formatStr appendString:@"."];
        for (NSInteger i = 0; i < decimalPoint; i++)
        {
            [formatStr appendString:@"0"];
        }
        if (decimalPoint > 0)
            [formatStr appendString:@";"];
    }
    [[[self class] sharedNumberFormatter] setPositiveFormat:formatStr];
    NSString *string = [[[self class] sharedNumberFormatter] stringFromNumber:@(value)];
    return string;
}

+ (NSString *)formatToMoneyStyle:(NSString *)moneyString placeIfNull:(NSString *)place
{
    if (!moneyString || [moneyString length] == 0)
    {
        return place;
    }
    return [moneyString formatToMoneyStyle];
}

/**
 *  判断输入的字符是不是数字和.
 *
 *  @param str 输入字符串
 *
 *  @return
 */
+ (BOOL)isNumber:(NSString *)str
{
    NSString *mask = @"0123456789.\n";
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:mask] invertedSet];
    NSString *filtered = [[str componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basicTest = [str isEqualToString:filtered];
    return  basicTest;
}

/**
 *  判断输入的字符串是不是纯数字
 *
 *  @param string 输入字符串
 *
 *  @return
 */
+ (BOOL)isPureInt:(NSString *)string
{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

/**
 *  是否是金额整数倍
 *  @param string 金额字符串
 *  @param multiple ：倍数
 *  @return YES 是整数倍
 */
+ (BOOL)isFormatMoney:(NSString *)money multiple:(NSInteger)multiple
{
    if (multiple > 0) {
        
        CGFloat moneyF = [money floatValue];
        NSInteger moneyI = [money integerValue];
        
        if (ABS(moneyF - moneyI) < 0.00001) {//没有浮点数值
            
            if (moneyI > 0 &&  moneyI % multiple == 0) {
                return YES;
            }
            
        }
        
    }
    
    return NO;
}

/**
 *  判断输入的字符串是否是 money类型的, 1:只有一个.  2:不以.开头  3:小数.后的位数可控
 *
 *  @param content 输入的内容
 *  @param count   小数点后可输入的位数
 *  @param string  当前输入的内容
 *  @param tf      当前的textField
 *
 *  @return
 */
+ (BOOL)isMoneyType:(NSString *)content count:(NSInteger)count replacementString:(NSString *)string textField:(UITextField *)tf
{
    NSString *contentStr = [NSString stringWithFormat:@"%@%@",content,string];
    if ([contentStr rangeOfString:@"."].location == NSNotFound) {
        isHaveDian = NO;
    }
    if ([string length] > 0) {
        unichar single = [string characterAtIndex:0];//当前输入的字符
        if ((single >= '0' && single <= '9') || single == '.') {//数据格式正确
            //首字母不能为小数点
            if([content length] == 0){
                if(single == '.') {
                    return NO;
                }
            }
            //输入的字符是否是小数点
            if (single == '.') {
                if(!isHaveDian)//text中还没有小数点
                {
                    isHaveDian = YES;
                    return YES;
                }else{
                    return NO;
                }
            }else{
                if (isHaveDian) {//存在小数点
                    //判断小数点的位数
                    NSRange ran = [contentStr rangeOfString:@"."];
                    // 当前光标的位置
                    NSUInteger targetCursorPosition = [tf offsetFromPosition:tf.beginningOfDocument toPosition:tf.selectedTextRange.start];
                    if (contentStr.length - ran.location <= count+1 || targetCursorPosition <= ran.location) {
                        return YES;
                    }else{
                        return NO;
                    }
                }else{
                    return YES;
                }
            }
        }else{//输入的数据格式不正确
            return NO;
        }
    }
    else
    {
        return YES;
    }
}

/**
 *  判断输入的是不是 空格
 *
 *  @param string 正在输入的字符
 *
 *  @return
 */
+ (BOOL)isSpaceStr:(NSString *)string
{
    NSString *tem = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]componentsJoinedByString:@""];
    if (![string isEqualToString:tem]) {
        return NO;
    }
    return YES;
}

+ (NSString *)formatMoneyToSubtract:(int)firstV secondV:(int)secondV precision:(int)precision
{
    NSString *resultStr = @"";
    NSString *minus = @"";
    _int64 firstValue = [[self class] convertVal:firstV];
    _int64 secondValue = [[self class] convertVal:secondV];
    _int64 result = firstValue - secondValue;
    if (result == 0) {
        resultStr = [NSString format_stringWithFloatValue:result precision:precision];
    }else{
        if (result < 0) {
            minus = @"-";
            result = secondValue - firstValue;
        }
        resultStr = [NSString stringWithFormat:@"%@%@",minus,[NSString format_stringWithDecimalVolume:result precision:precision]];
    }
    return resultStr;
}

/*
 * 对金额截断
 * doubleValue ： 多少位数  例如100000000
 */
+ (NSString *)truncationMoneyStringformat:(NSString *)value doubleValue:(double)doubleValue
{
    if (value.doubleValue > doubleValue) { //大于100000000不显示小数点，按照默认格式
        if ([value rangeOfString:@"."].location != NSNotFound) {//包含小数点
            
            NSArray *array = [value componentsSeparatedByString:@"."];
            if (array) {
                value = array[0];
            }
        }
    }
    return [value formatToMoneyStyle];
}

@end
