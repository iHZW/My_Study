//
//  NSString+SHA1.m
//  TZYJ_IPhone
//
//  Created by Howard on 15/9/8.
//
//

#import "NSString+SHA1.h"
#import "NSData+SHA1.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (SHA1)

/**
 *  生成SHA1编码字符串
 *
 *  @return 返回SHA1编码字符串
 */
- (NSString*)sha1EncodingString
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    SHA1Encoding(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

/**
 *  生成40位SHA1转码小写字符串
 *
 *  @return 返回小写SHA1字符串
 */
- (NSString *)sha1EncodingLowercaseString
{
    return [[self sha1EncodingString] lowercaseString];
}

/**
 *  生成40位SHA1转码大写字符串
 *
 *  @return 返回大写SHA1字符串
 */
- (NSString *)sha1EncodingUppercaseString
{
    return [[self sha1EncodingString] uppercaseString];
}

@end
