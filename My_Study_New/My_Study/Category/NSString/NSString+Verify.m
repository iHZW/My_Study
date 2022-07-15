//
//  NSString+Verify.m
//  TZYJ_IPhone
//
//  Created by Weirdln on 15/10/29.
//
//

#import "NSString+Verify.h"

/* 正则表达式 */
#define kTIRegexUserCardNums    @"^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}\\w$" // 身份证
#define kTIRegexBankCardNums    @"^[0-9]{8,}$"  // 银行卡
#define kTIRegexPhoneNums       @"^((\\+86)|(86))?(1)\\d{10}$" // 手机号码

#define kTIRegexColorNum        @"^#[0-9a-fA-F]{6}{1}$" //颜色值  十六进制的  #FFFFFF

@implementation NSString (Verify)

- (BOOL)match:(NSString *)regex
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:self];
}

/* 校验身份证，仅18位 */
- (BOOL)checkIdentityCardNo
{
    if (self.length < 18) {
        return NO;
    }
    
    static int weight[] = { 7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2 };
    static int check[] = { 1, 0, 'X', 9, 8, 7, 6, 5, 4, 3, 2 };
    NSString *checkCode = nil;
    
    // 1.S=sum(ai*wi)
    int sum = 0;
    for (int i = 0; i < 17; i ++) {
        NSString* subString = [self substringWithRange:NSMakeRange(i , 1)];
        sum += subString.intValue * weight[i];
    }
    
    // 2.y=mod(s,11)
    int mod = sum % 11;
    checkCode = mod == 2 ? @"X" : [NSString stringWithFormat:@"%d", check[mod]];
    
    NSString *lastCode = [self substringFromIndex:17];
    return [lastCode isEqualToString:checkCode];
}

- (BOOL)checkMobilePhoneNo
{
    return [self match:kTIRegexPhoneNums];
}

- (BOOL)checkColorNo
{
    return [self match:kTIRegexColorNum];
}

/**
 *  校验银行卡luhn算法
 *
 *  @return 是否合法
 *
 *  @see http://www.cocoachina.com/bbs/read.php?tid=112021#780419
 */
- (BOOL)checkBankCardNo
{
    int sum = 0;
    NSUInteger len = [self length];
    int i = 0;
    while (i < len) {
        NSString *tmpString = [self substringWithRange:NSMakeRange(len - 1 - i, 1)];
        int tmpVal = [tmpString intValue];
        if (i % 2 != 0) {
            tmpVal *= 2;
            if (tmpVal >= 10) {
                tmpVal -= 9;
            }
        }
        sum += tmpVal;
        i++;
    }
    if ((sum % 10) == 0) {
        return YES;
    } else {
        return NO;
    }
}

/**
 *  给字符串局部加＊
 *
 *  @param str   处理的字符串
 *  @param xingL 加＊长度
 *  @param lastL 加＊末尾留的长度
 *
 *  @return 新字符串
 */
+(NSString*)getXingString:(NSString*)str  xingLength:(NSInteger)xingL lastLength:(NSInteger)lastL
{
    NSInteger totalL = str.length;
    if (xingL + lastL >= totalL) {
        return str;
    }
    
    NSString *head = [str substringToIndex:totalL - (xingL+lastL)];
    NSString *last = [str substringFromIndex:totalL-lastL];
    
    NSMutableString *strTo = [NSMutableString stringWithString:head];
    for (int i =0 ; i < xingL; i++) {
        [strTo appendString:@"*"];
    }
    [strTo appendString:last];
    
    
    return strTo;
}


@end
