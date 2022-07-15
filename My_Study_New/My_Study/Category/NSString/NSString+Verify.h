//
//  NSString+Verify.h
//  TZYJ_IPhone
//
//  Created by Weirdln on 15/10/29.
//
//

#import <Foundation/Foundation.h>

@interface NSString (Verify)

/* 判断是否匹配正则表达式 */
- (BOOL)match:(NSString *)regex;

/* 校验身份证，仅18位 */
- (BOOL)checkIdentityCardNo;

/* 校验手机号码 */
- (BOOL)checkMobilePhoneNo;

/* 校验银行卡号 */
- (BOOL)checkBankCardNo;

/** 验证十六进制颜色值  */
- (BOOL)checkColorNo;

/**
 *  给字符串局部加＊
 *
 *  @param str   处理的字符串
 *  @param xingL 加＊长度
 *  @param lastL 加＊末尾留的长度
 *
 *  @return 新字符串
 */
+(NSString*)getXingString:(NSString*)str  xingLength:(NSInteger)xingL lastLength:(NSInteger)lastL;

@end
