//
//  AESCrypt.m
//  Gurpartap Singh
//
//  Created by Gurpartap Singh on 06/05/12.
//  Copyright (c) 2012 Gurpartap Singh
// 
// 	MIT License
// 
// 	Permission is hereby granted, free of charge, to any person obtaining
// 	a copy of this software and associated documentation files (the
// 	"Software"), to deal in the Software without restriction, including
// 	without limitation the rights to use, copy, modify, merge, publish,
// 	distribute, sublicense, and/or sell copies of the Software, and to
// 	permit persons to whom the Software is furnished to do so, subject to
// 	the following conditions:
// 
// 	The above copyright notice and this permission notice shall be
// 	included in all copies or substantial portions of the Software.
// 
// 	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// 	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// 	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// 	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// 	LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// 	OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// 	WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "AESCrypt.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import <CommonCrypto/CommonCrypto.h>
#import "CommonFileFunc.h"

@implementation AESCrypt

+ (NSData *)encryptDataWithByteKey:(NSData *)message password:(const void *)password
{
    NSData *encryptedData = nil;
    //对于块加密算法，输出大小总是等于或小于输入大小加上一个块的大小
    //所以在下边需要再加上一个块的大小
    NSData *noEncryptedData = message;
    NSUInteger dataLength = [noEncryptedData length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding/*这里就是刚才说到的PKCS7Padding填充了*/ | kCCOptionECBMode,
                                          password, kCCKeySizeAES128,
                                          NULL,/* 初始化向量(可选) */
                                          [noEncryptedData bytes], dataLength,/*输入*/
                                          buffer, bufferSize,/* 输出 */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess)
    {
        encryptedData = [NSData dataWithBytes:buffer length:numBytesEncrypted];
    }
    free(buffer);//释放buffer
    return encryptedData;
}

/**
 *  对NSData类型明文,使用二进制密钥进行AES 128位加密处理
 *
 *  @param message  NSData类型明文
 *  @param password NSData类型密钥匙
 *
 *  @return 返回NSData类型AES 128位密文
 */
+ (NSData *)encryptDataWithKey:(NSData *)message password:(NSData *)password
{
    return [[self class] encryptDataWithByteKey:message password:[password bytes]];
}

/**
 *  对NSString类型明文,使用NSData密钥进行AES 128位加密处理
 *
 *  @param message  NSString类型明文
 *  @param password NSData类型密钥匙
 *
 *  @return 返回NSData类型AES 128位密文
 */
+ (NSData *)encryptData:(NSString *)message password:(NSData *)password
{
    NSData *encryptedData = [[self class] encryptDataWithByteKey:[message dataUsingEncoding:NSUTF8StringEncoding] password:[password bytes]];
    //    NSData *encryptedData = [[message dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptedDataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    
    return encryptedData;
}

/**
 *  对NSString类型明文,使用NSData密钥进行AES 128位加密处理
 *
 *  @param message  NSString类型明文
 *  @param password NSData类型密钥匙
 *
 *  @return 返回BASE64位转码处理后的AES 128位密文
 */
+ (NSString *)encryptWithKeyToBase64:(NSString *)message password:(NSData *)password
{
    NSData *encryptedData = [[self class] encryptData:message password:password];
    NSString *base64EncodedString = [NSString base64StringFromData:encryptedData length:[encryptedData length]];
    return base64EncodedString;
}

/**
 *  对NSString类型明文,使用NSData密钥进行AES 128位加密处理
 *
 *  @param message  NSString类型明文
 *  @param password 二进制类型密钥匙
 *
 *  @return 返回BASE64位转码处理后的AES 128位密文
 */
+ (NSString *)encryptWithByteKeyToBase64:(NSString *)message password:(const void *)password
{
    NSData *encryptedData = [[self class] encryptDataWithByteKey:[message dataUsingEncoding:NSUTF8StringEncoding] password:password];
    NSString *base64EncodedString = [NSString base64StringFromData:encryptedData length:[encryptedData length]];
    return base64EncodedString;
}

/**
 *  对NSData密文,使用二进制密钥进行AES 128位解密处理
 *
 *  @param data     NSData类型密文
 *  @param password 二进制类型密钥匙
 *
 *  @return 返回NSData类型解密后明文
 */
+ (NSData *)decryptDataWithByteKey:(NSData *)data password:(const void *)password
{
    NSData *decryptData = nil;
    //同理，解密中，密钥也是32位的
    //对于块加密算法，输出大小总是等于或小于输入大小加上一个块的大小
    //所以在下边需要再加上一个块的大小
    if (password)
    {
        NSUInteger dataLength = [data length];
        size_t bufferSize = dataLength + kCCBlockSizeAES128;
        void *buffer = malloc(bufferSize);
        
        size_t numBytesDecrypted = 0;
        CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                              kCCOptionPKCS7Padding/*这里就是刚才说到的PKCS7Padding填充了*/ | kCCOptionECBMode,
                                              password, kCCKeySizeAES128,
                                              NULL,/* 初始化向量(可选) */
                                              [data bytes], dataLength,/* 输入 */
                                              buffer, bufferSize,/* 输出 */
                                              &numBytesDecrypted);
        if (cryptStatus == kCCSuccess) {
            decryptData = [NSData dataWithBytes:buffer length:numBytesDecrypted];
        }
        free(buffer);
    }
    return decryptData;
}

/**
 *  对NSData密文,使用NSData类型密钥进行AES 128位解密处理
 *
 *  @param data     NSData类型密文
 *  @param password NSData类型密钥匙
 *
 *  @return 返回NSData类型解密后明文
 */
+ (NSData *)decryptDataWithKey:(NSData *)data password:(NSData *)password
{
    return [[self class] decryptDataWithByteKey:data password:[password bytes]];
}

/**
 *  对NSData密文,使用二进制密钥进行AES 128位解密处理
 *
 *  @param data     NSData类型密文
 *  @param password 二进制类型密钥匙
 *
 *  @return 返回解密UTF8字符串
 */
+ (NSString *)decryptStringWithByteKey:(NSData *)data password:(const void *)password
{
    NSData *decryptData = [[self class] decryptDataWithByteKey:data password:password];
#if !__has_feature(objc_arc)
    return [[[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding] autorelease];
#else
    return [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
#endif
}

/**
 *  对BASE64密文,使用NSData类型密钥进行AES 128位解密处理
 *
 *  @param base64EncodedString     base64类型密文
 *  @param password NSData类型密钥匙
 *
 *  @return 返回NSString(UTF8编码)类型解密后明文
 */
+ (NSString *)decryptWithKey:(NSString *)base64EncodedString password:(NSData *)password
{
  NSData *encryptedData = [NSData dataFromBase64String:base64EncodedString];
  NSData *decryptedData = [[self class] decryptDataWithKey:encryptedData password:password];
#if !__has_feature(objc_arc)
    return [[[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding] autorelease];
#else
    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
#endif
}

/**
 *  对BASE64密文,使用二进制类型密钥进行AES 128位解密处理
 *
 *  @param base64EncodedString     base64类型密文
 *  @param password 二进制类型密钥匙
 *
 *  @return 返回NSString(UTF8编码)类型解密后明文
 */
+ (NSString *)decryptWithByteKey:(NSString *)base64EncodedString password:(const void *)password
{
    NSData *encryptedData = [NSData dataFromBase64String:base64EncodedString];
    NSData *decryptedData = [[self class] decryptDataWithByteKey:encryptedData password:password];
#if !__has_feature(objc_arc)
    return [[[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding] autorelease];
#else
    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
#endif
}



/**
 *  aes加密
 */
+ (NSData *)AES256EncryptWithKey:(NSString *)key datain:(NSData*)datain
{
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [datain length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [datain bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

/**
 *  aes解密
 */
+ (NSData *)AES256DecryptWithKey:(NSString *)key datain:(NSData*)datain
{
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [datain length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [datain bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

@end
