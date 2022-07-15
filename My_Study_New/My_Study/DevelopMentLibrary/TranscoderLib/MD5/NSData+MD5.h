//
//  NSData+MD5.h
//  TZYJ_IPhone
//
//  Created by Howard on 15/9/8.
//
//

#import <Foundation/Foundation.h>


@interface NSData (MD5)

/**
 *  md5码转换处理
 *
 *  @param data 二进制数据指针
 *  @param len  转换的数据长度
 *  @param md   输出的指针地址
 *
 *  @return 返回转换后的数据长度
 */
unsigned char *MD5EnCoding(const void *data, NSUInteger len, unsigned char *md);

/**
 *  将二进制数据进行md5码处理
 *
 *  @param data 要转换的二进制数据
 *
 *  @return 返回进行md5码转换后的二进制数据
 */
+ (NSData *)md5EncodingToData:(NSData *)data;

/**
 *  md5转码处理
 *
 *  @return 返回md5转码后的二进制数据
 */
- (NSData *)md5EncodeingData;

/**
 *  md5转码处理
 *
 *  @return 下面是Byte 转换为16进制输出
 */
- (NSString *)md5EncodeingString;

@end
