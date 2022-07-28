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

/** OC正则暂时没找到  */
#define kTIRegexColorNum        @"^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$" //颜色值  十六进制的  #FFFFFF

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
    return YES;
//    return [self match:kTIRegexColorNum];
}

/** 有效的邮箱 */
- (BOOL)isValidEmail{
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    return [self match:regex];
}

/** 有效的手机号 */
- (BOOL)isValidPhone{
    NSString *regex = @"1([38][0-9]|4[579]|5[0-3,5-9]|6[6]|7[0135678]|9[89])\\d{8}";
    return [self match:regex];
}
/** 有效的URL */
- (BOOL)isValidUrl{
    NSString *regex = @"http(s)?:\\/\\/([\\w-]+\\.)+[\\w-]+(\\/[\\w- .\\/?%&=]*)?";
    return [self match:regex];
}
/** 有效的URL(忽略http://) */
- (BOOL)isValidUrlIgnoreHttp{
    NSString *regex = @"^www[.]+([\\w\\-\\.,@?^=%&:/~\\+#]*[\\w\\-\\@?^=%&/~\\+#])?";
    return [self match:regex];
}
/** 有效的验证码 (4位数字) */
- (BOOL)isValidCode{
    NSString *regex = @"(\\d{4})";
    return [self match:regex];
}
/** 有效密码  */
- (BOOL)isValidPassword{
    NSString *regex = @"(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,16}";
    return [self match:regex];
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
