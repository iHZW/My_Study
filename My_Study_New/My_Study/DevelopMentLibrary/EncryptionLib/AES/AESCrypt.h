//
//  AESCrypt.h
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

#import <Foundation/Foundation.h>


@interface AESCrypt : NSObject

+ (NSData *)encryptDataWithByteKey:(NSData *)message password:(const void *)password;

/**
 *  对NSData类型明文,使用二进制密钥进行AES 128位加密处理
 *
 *  @param message  NSData类型明文
 *  @param password NSData类型密钥匙
 *
 *  @return 返回NSData类型AES 128位密文
 */
+ (NSData *)encryptDataWithKey:(NSData *)message password:(NSData *)password;

/**
 *  对NSString类型明文,使用NSData密钥进行AES 128位加密处理
 *
 *  @param message  NSString类型明文
 *  @param password NSData类型密钥匙
 *
 *  @return 返回NSData类型AES 128位密文
 */
+ (NSData *)encryptData:(NSString *)message password:(NSData *)password;

/**
 *  对NSString类型明文,使用NSData密钥进行AES 128位加密处理
 *
 *  @param message  NSString类型明文
 *  @param password NSData类型密钥匙
 *
 *  @return 返回BASE64位转码处理后的AES 128位密文
 */
+ (NSString *)encryptWithKeyToBase64:(NSString *)message password:(NSData *)password;

/**
 *  对NSString类型明文,使用NSData密钥进行AES 128位加密处理
 *
 *  @param message  NSString类型明文
 *  @param password 二进制类型密钥匙
 *
 *  @return 返回BASE64位转码处理后的AES 128位密文
 */
+ (NSString *)encryptWithByteKeyToBase64:(NSString *)message password:(const void *)password;


/**
 *  对NSData密文,使用二进制密钥进行AES 128位解密处理
 *
 *  @param data     NSData类型密文
 *  @param password 二进制类型密钥匙
 *
 *  @return 返回NSData类型解密后明文
 */
+ (NSData *)decryptDataWithByteKey:(NSData *)data password:(const void *)password;

/**
 *  对NSData密文,使用NSData类型密钥进行AES 128位解密处理
 *
 *  @param data     NSData类型密文
 *  @param password NSData类型密钥匙
 *
 *  @return 返回NSData类型解密后明文
 */
+ (NSData *)decryptDataWithKey:(NSData *)data password:(NSData *)password;

/**
 *  对NSData密文,使用二进制密钥进行AES 128位解密处理
 *
 *  @param data     NSData类型密文
 *  @param password 二进制类型密钥匙
 *
 *  @return 返回解密UTF8字符串
 */
+ (NSString *)decryptStringWithByteKey:(NSData *)data password:(const void *)password;

/**
 *  对NSData密文,使用NSData类型密钥进行AES 128位解密处理
 *
 *  @param base64EncodedString     base64类型密文
 *  @param password NSData类型密钥匙
 *
 *  @return 返回NSString(UTF8编码)类型解密后明文
 */
+ (NSString *)decryptWithKey:(NSString *)base64EncodedString password:(NSData *)password;

/**
 *  对NSData密文,使用二进制类型密钥进行AES 128位解密处理
 *
 *  @param base64EncodedString     base64类型密文
 *  @param password 二进制类型密钥匙
 *
 *  @return 返回NSString(UTF8编码)类型解密后明文
 */
+ (NSString *)decryptWithByteKey:(NSString *)base64EncodedString password:(const void *)password;


/**
 *  aes加密
 */
+ (NSData *)AES256EncryptWithKey:(NSString *)key datain:(NSData*)datain;
/**
 *  aes解密
 */
+ (NSData *)AES256DecryptWithKey:(NSString *)key datain:(NSData*)datain;

@end
