//
//  NSString+Number.m
//  DzhProjectiPhone
//
//  Created by Duanwwu on 14-9-30.
//  Copyright (c) 2014年 gw. All rights reserved.
//

#import "NSString+NumberFormat.h"

#define kTecIndexNoValue -999999999            //指标值不存在时，设置的默认值

@implementation NSString (NumberFormat)

#pragma mark - Private's
+ (NSString *)formatValueToString:(id)value
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

#pragma mark - Public's
+ (_int64)convertVal:(int)Val
{
    //    _int64 ov = -(BOOL)(Val >> 29 & 1);
    //    return ((ov == 0) ? Val & 0x3FFFFFFF : (Val | 0xC0000000) & ov) << ABS((Val >> 30) * 4);
    
    int sVal        = (Val & 0x20000000);
    _int64 tmpVal   = sVal != 0 ? ~((0xFFFFFFFF << 31) | 0xC0000000 | (Val & 0x3FFFFFFF)) + 1 : Val & 0x1FFFFFFF;
    return (sVal != 0 ? (tmpVal << (ABS(Val >> 30) * 4)) * -1 : (tmpVal << (ABS(Val >> 30) * 4)));
}

+ (NSString *)format_reviseString:(NSString *)string
{
    /* 直接传入精度丢失有问题的Double类型*/
    double conversionValue        = (double)[string floatValue];
    NSString *doubleString        = [NSString stringWithFormat:@"%lf", conversionValue];
    NSDecimalNumber *decNumber    = [NSDecimalNumber decimalNumberWithString:doubleString];
    return [decNumber stringValue];
}

+ (NSString *)format_stringNoZeroWithFloatValue:(float)value precision:(int)precision
{
    if (value == 0 || isinf(value))
        return @"--";
    
    NSString *base          = [NSString stringWithFormat:@"%%.%df",precision];
    return [NSString stringWithFormat:base, value];
}

/**
 * 对字符串进行长度截取
 */
+ (NSString *)format_stringWithString:(NSString *)str length:(int)len
{
    NSRange rang = [str rangeOfString:@"."];
    NSInteger ln = rang.location;
    NSInteger rn = [str length] - ln - 1;
	
	if (rang.location != NSNotFound)//有小数点，需进行字符串长度处理
	{
		NSRange range;
		range.location      = 0;
		range.length        = MAX(ln, 0);
		NSString *leftstr 	= [str substringWithRange:range];//整数部分
		
        range.location     = ln + 1;
        range.length       = MAX(rn, 0);
        NSString *rightstr = [str substringWithRange:range];//小数部分
        NSInteger over     = [str length] - len;
		
		if (over > 0)//字符串长度超出需要的长度，需进行截取
		{
			range.location 	= 0;
			range.length 	= MIN([rightstr length] - over, [rightstr length]);
			rightstr        = [rightstr substringWithRange:range];
		}
		
		if ([rightstr length] > 0 && [leftstr length] < len)
			return [NSString stringWithFormat:@"%@.%@", leftstr, rightstr];
		else
			return leftstr;
	}
	else//无小数点，直接返回
		return str;
}

+ (NSString *)format_stringNoZeroWithFloatValue:(float)value length:(int)len precision:(int)precision
{
	return [self format_stringWithString:[self format_stringNoZeroWithFloatValue:value precision:precision] length:len];
}

+ (NSString *)format_stringWithFloatValue:(float)value precision:(int)precision
{
    if (value == kTecIndexNoValue || isinf(value))
        return @"--";
    
    NSString *base          = [NSString stringWithFormat:@"%%.%df",precision];
    return [NSString stringWithFormat:base, value];
}

+ (NSString *)format_stringWithFloatValue:(float)value length:(int)len precision:(int)precision
{
    return [self format_stringWithString:[self format_stringWithFloatValue:value precision:precision] length:len];
}

+ (NSString *)format_stringForIntWithFloatValue:(float)value length:(int)len
{
    return value <= 0 ? @"--" : [self format_stringWithFloatValue:(int)(value + .5f) length:len precision:0];
}

+ (NSString *)format_stringNoUnitWithVolume:(_int64)volume
{
    return volume == 0 ? @"--" : [NSString stringWithFormat:@"%lli", volume];
}

+ (NSString *)format_stringWithVolume:(_int64)volume
{
    return [self format_stringWithVolume:volume precision:2];
}

+ (NSString *)format_stringWithVolume:(_int64)volume precision:(int)precision
{
    if (volume <= 0)
        return @"--";
    else if (volume < 10000)
        return [NSString stringWithFormat:@"%lli", volume];
    else if (volume < 100000000)
        return [NSString stringWithFormat:@"%@万", [self format_stringNoZeroWithFloatValue:volume * .0001f length:5 precision:precision]];
    else
        return [NSString stringWithFormat:@"%@亿", [self format_stringNoZeroWithFloatValue:volume * .00000001f length:5 precision:precision]];
}

+ (NSString *)format_stringWithDecimalVolume:(_int64)volume precision:(int)precision
{
    if (volume <= 0)
        return @"--";
    else if (volume < 10000)
        return [NSString stringWithFormat:@"%@", [self format_stringNoZeroWithFloatValue:volume  precision:precision]];
    else if (volume < 100000000)
        return [NSString stringWithFormat:@"%@万", [self format_stringNoZeroWithFloatValue:volume * .0001f precision:precision]];
    else
        return [NSString stringWithFormat:@"%@亿",[self format_stringNoZeroWithFloatValue:volume * .00000001f precision:precision]];
}

+ (NSString *)format_stringWithIndexVolume:(_int64)volume
{
    if (volume <= 0)
        return @"--";
    else if (volume < 10000)
        return [NSString stringWithFormat:@"%lli亿", volume];
    else
        return [NSString stringWithFormat:@"%@万亿", [self format_stringNoZeroWithFloatValue:volume * .0001f length:5 precision:2]];
}

+ (NSString *)format_stringWithPrice:(_int64)price length:(int)len precision:(int)precision
{
    if (price == 0)
        return @"--";
    else
    {
        double fprice       = (double)price * pow(.1, precision);
		return [self format_stringNoZeroWithFloatValue:fprice length:len precision:precision];
    }
}

+ (NSString *)format_stringWithAmount:(_int64)amount
{
    if (amount <= 0)
        return @"--";
    else if (amount < 10000)
        return [NSString stringWithFormat:@"%lli万", amount];
    else if (amount < 100000000)
        return [NSString stringWithFormat:@"%@亿", [self format_stringNoZeroWithFloatValue:amount * .0001f length:5 precision:2]];
    else
        return [NSString stringWithFormat:@"%@万亿", [self format_stringNoZeroWithFloatValue:amount * .00000001f length:5 precision:2]];
}

+ (NSString *)format_stringForPriceChangeSignWithPrice:(float)price lastClose:(float)lastClose length:(int)len precision:(int)precision
{
    if (price == 0 || lastClose == 0)
        return @"--";
    else if (price == lastClose)
        return @"0.00";
    else if (price > lastClose)
        return [NSString stringWithFormat:@"+%@", [self format_stringWithFloatValue:price - lastClose length:len precision:precision]];
    else
        return [self format_stringWithFloatValue:price - lastClose length:len precision:precision];
}

+ (NSString *)format_stringForPriceChangeWithPrice:(float)price lastClose:(float)lastClose length:(int)len precision:(int)precision
{
    if (price == 0)
        return @"--";
    else if (price == lastClose)
        return @"0.00";
    else
        return [self format_stringWithFloatValue:price - lastClose length:len precision:precision];
}

+ (NSString *)format_stringForPriceChangePercentWithPrice:(float)price lastClose:(float)lastClose length:(int)len precision:(int)precision
{
    if (price == 0)
        return @"--";
    else if (price == lastClose)
        return @"0.00%";
    else if (lastClose == 0)
        return @"--";
    else
        return [NSString stringWithFormat:@"%@%%", [self format_stringWithFloatValue:(price - lastClose) * 100.f / lastClose length:len precision:precision]];
}

+ (NSString *)format_stringForPriceChangePercentSignWithPrice:(float)price lastClose:(float)lastClose length:(int)len precision:(int)precision
{
    if (price == 0 || lastClose == 0)
        return @"--";
    else if (price == lastClose)
        return @"0.00%";
    else
    {
        float v         = (price - lastClose) * 100.f / lastClose;
        if (isinf(v))
            return @"--";
        if (price > lastClose)
            return [NSString stringWithFormat:@"+%@%%", [self format_stringWithFloatValue:v length:len precision:precision]];
        else
            return [NSString stringWithFormat:@"%@%%", [self format_stringWithFloatValue:v length:len precision:precision]];
    }
}

+ (NSString *)format_stringForExchangeWithVolume:(_int64)volume circulation:(_int64)circulation
{
    if (volume <= 0 || circulation == 0)
        return @"--";
    else
        return [NSString stringWithFormat:@"%.2f", volume * 100.f / circulation];
}

+ (NSString *)format_stringForAmplitudeWithHigh:(float)high low:(float)low lastClose:(float)lastClose
{
    float amplitude     = high <= 0 || lastClose == 0 ? 0. : fabsf(high - low) * 100.f / lastClose;
    return [NSString stringWithFormat:@"%@%%",[self format_stringNoZeroWithFloatValue:amplitude precision:2]];
}

+ (NSString *)format_stringForMaWithValue:(float)value length:(int)len precision:(int)precision
{
    if (value <= 0)
        return @"--";
    else if (value >= 1000.)
        return [NSString stringWithFormat:@"%d",(int)value];
    else
        return [self format_stringWithFloatValue:value length:len precision:precision];
}

+ (NSString *)format_stringForString:(NSString *)tempString
{
    NSString *formatString = [[self class] formatValueToString:tempString];
    
    if ([formatString floatValue] > 0)
    {
        formatString = [NSString stringWithFormat:@"+%@",formatString];
    }
    return formatString;
}

+ (NSString *)format_stringForPercent:(NSString *)tempString precision:(int)precision
{
    int index = 2;
    if (precision>=0) {
        index = precision;
    }
    NSString *formatString = [self format_stringWithFloatValue:[tempString floatValue] precision:index];
    return [NSString stringWithFormat:@"%@%%",formatString];
}

+ (NSString *)format_stringForPercent:(NSString *)tempString
{
    return [self format_stringForPercent:tempString precision:2];
}

@end
