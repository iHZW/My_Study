//
//  NSData+SHA1.m
//  TZYJ_IPhone
//
//  Created by Howard on 15/9/8.
//
//

#import "NSData+SHA1.h"
#import "NSData+MD5.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSData (SHA1)

/**
 *  sha1码转换处理
 *
 *  @param data 二进制数据指针
 *  @param len  转换的数据长度
 *  @param md   输出的指针地址
 *
 *  @return 返回转换后的数据长度
 */
unsigned char *SHA1Encoding(const void *data, NSUInteger len, unsigned char *md)
{
    return CC_SHA1(data, (CC_LONG)len, md);
}

/**
 *  将字符串转换成sha1码，并输出二进制数据
 *
 *  @param source 要转换的为sha1码的字符串
 *  @param output 生成sha1码的unsigned char*数据
 */
+ (void)sha1Encoding:(NSString *)source output:(unsigned char *)output
{
    const char *cStr = [source UTF8String];
    SHA1Encoding(cStr, [source lengthOfBytesUsingEncoding:NSUTF8StringEncoding], output);
}

/**
 *  将二进制数据进行sha1码处理
 *
 *  @param data 要转换的二进制数据
 *
 *  @return 返回进行sha1码转换后的二进制数据
 */
+ (NSData *)sha1EncodingToData:(NSData *)data
{    
    unsigned char *cStr = (unsigned char *)[data bytes];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];//开辟一个20字节
    
    SHA1Encoding(cStr, [data length], result);
    return [NSData dataWithBytes:result length:CC_SHA1_DIGEST_LENGTH];
}

/**
 *  sha1转码处理
 *
 *  @return 返回sha1转码后的二进制数据
 */
- (NSData *)sha1EncodeingData
{
    return [[self class] sha1EncodingToData:self];
}

@end
