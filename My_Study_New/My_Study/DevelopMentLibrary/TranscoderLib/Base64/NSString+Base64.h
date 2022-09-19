//
//  NSString+Base64.h
//  Gurpartap Singh
//
//  Created by Gurpartap Singh on 06/05/12.
//  Copyright (c) 2012 Gurpartap Singh. All rights reserved.
//

#import <Foundation/NSString.h>

@interface NSString (Base64Additions)

/**
 *  将二进制数据转换成base64编码字符串
 *
 *  @param data   要进行base64编码的二进制数据
 *  @param length 数据长度
 *
 *  @return 返回base64编码字符串
 */
+ (NSString *)base64StringFromData:(NSData *)data length:(NSInteger)length;

/**
 *  将base64编码字符串解码并生成UTF8格式字符串
 *
 *  @param string base64编码格式字符串
 *
 *  @return 返回base64解码后UTF8字符串
 */
+ (NSString *)stringWithBase64String:(NSString *)string;

/**
 *  生成base64编码字符串
 *
 *  @return 返回base64编码字符串
 */
- (NSString *)base64EncodedString;

/**
 *  base64字符串进行解码处理
 *
 *  @return 返回UTF8编码字符串
 */
- (NSString *)base64DecodedString;

/**
 *  base64编码进行解码处理
 *
 *  @return base64解码的二进制数据
 */
- (NSData *)base64DecodedData;

@end
