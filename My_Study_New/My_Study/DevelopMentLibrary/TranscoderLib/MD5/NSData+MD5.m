//
//  NSData+MD5.m
//  TZYJ_IPhone
//
//  Created by Howard on 15/9/8.
//
//

#import "NSData+MD5.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSData (MD5)

/**
 *  md5码转换处理
 *
 *  @param data 二进制数据指针
 *  @param len  转换的数据长度
 *  @param md   输出的指针地址
 *
 *  @return 返回转换后的数据长度
 */
unsigned char *MD5EnCoding(const void *data, NSUInteger len, unsigned char *md)
{
    return CC_MD5(data, (CC_LONG)len, md);
}

/**
 *  将字符串转换成md5码，并输出二进制数据
 *
 *  @param source 要转换的为md5码的字符串
 *  @param output 生成md5码的unsigned char*数据
 */
+ (void)md5Encoding:(NSString *)source output:(unsigned char *)output
{
    const char *cStr = [source UTF8String];
    MD5EnCoding(cStr, [source lengthOfBytesUsingEncoding:NSUTF8StringEncoding], output);
}

/**
 *  将二进制数据进行md5码处理
 *
 *  @param data 要转换的二进制数据
 *
 *  @return 返回进行md5码转换后的二进制数据
 */
+ (NSData *)md5EncodingToData:(NSData *)data
{
    unsigned char *cStr = (unsigned char *)[data bytes];
    unsigned char result[CC_MD5_DIGEST_LENGTH];//开辟一个16字节（128位：md5加密出来就是128位/bit）的空间（一个字节=8字位=8个二进制数）
    
    MD5EnCoding(cStr, [data length], result);
    return [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
}

/**
 *  md5转码处理
 *
 *  @return 返回md5转码后的二进制数据
 */
- (NSData *)md5EncodeingData
{
    return [[self class] md5EncodingToData:self];
}

/**
 *  md5转码处理
 *
 *  @return 下面是Byte 转换为16进制输出
 */
- (NSString *)md5EncodeingString
{
    NSData *data = [[self class] md5EncodingToData:self];
    Byte *bytes = (Byte *)[data bytes];
    
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr]; 
    } 
    return hexStr;
}


@end
