//
//  NSString+MD5.h
//  TZYJ_IPhone
//
//  Created by Howard on 15/9/8.
//
//

#import <Foundation/Foundation.h>


@interface NSString (MD5)

/**
 *  生成32位MD5转码小写字符串
 *
 *  @return 返回小写md5字符串
 */
- (NSString *)md5EncodingLowercaseString;

/**
 *  生成32位MD5转码大写字符串
 *
 *  @return 返回大写md字符串
 */
- (NSString *)md5EncodingUppercaseString;

/**
 *  将字符串转换成MD5码并转换UTF8格式
 *
 *  @return 返回UTF8编码格式的MD5码
 */
- (NSString *)md5EncodingUTF8String;

/**
 *  将对应字符串转换成MD5码并转换UTF8格式
 *
 *  @return @return 返回UTF8编码格式的MD5码
 */
- (NSString *)md5EncodingToUTF8String;

/**
 *  将对应字符串转换成MD5码二进制数据
 *
 *  @return 返回二进制格式的MD5码
 */
- (NSData *)md5EncodingToData;


@end
