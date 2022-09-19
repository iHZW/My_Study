//
//  NSString+MD5.m
//  TZYJ_IPhone
//
//  Created by Howard on 15/9/8.
//
//

#import "NSString+MD5.h"
#import "NSData+MD5.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (MD5)

- (NSString *)md5EncodingString
{
    if(self == nil || [self length] == 0)
        return nil;
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    MD5EnCoding(value, strlen(value), outputBuffer);
    
    NSMutableString *outputString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++) {
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

/**
 *  生成32位MD5转码小写字符串
 *
 *  @return 返回小写md5字符串
 */
- (NSString *)md5EncodingLowercaseString
{
    return [[self md5EncodingString] lowercaseString];
}

/**
 *  生成32位MD5转码大写字符串
 *
 *  @return 返回大写md字符串
 */
- (NSString *)md5EncodingUppercaseString
{
    return [[self md5EncodingString] uppercaseString];
}

/**
 *  将字符串转换成MD5码并转换UTF8格式
 *
 *  @return 返回UTF8编码格式的MD5码
 */
- (NSString *)md5EncodingUTF8String
{
    return [self md5EncodingToUTF8String];
}

/**
 *  将对应字符串转换成MD5码并转换UTF8格式
 *
 *  @return @return 返回UTF8编码格式的MD5码
 */
- (NSString *)md5EncodingToUTF8String
{
    NSData *md5Data = [self md5EncodingToData];
    
    return [NSString stringWithUTF8String:[md5Data bytes]];
}

/**
 *  将对应字符串转换成MD5码二进制数据
 *
 *  @return 返回二进制格式的MD5码
 */
- (NSData *)md5EncodingToData
{
    NSData *md5Data = [NSData md5EncodingToData:[NSData dataWithBytes:[self UTF8String] length:[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding]]];
    
    return md5Data;
}

@end
