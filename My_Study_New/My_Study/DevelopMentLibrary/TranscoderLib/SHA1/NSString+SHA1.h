//
//  NSString+SHA1.h
//  TZYJ_IPhone
//
//  Created by Howard on 15/9/8.
//
//

#import <Foundation/Foundation.h>

@interface NSString (SHA1)

/**
 *  生成SHA1编码字符串
 *
 *  @return 返回SHA1编码字符串
 */
- (NSString*)sha1EncodingString;

/**
 *  生成40位SHA1转码小写字符串
 *
 *  @return 返回小写SHA1字符串
 */
- (NSString *)sha1EncodingLowercaseString;

/**
 *  生成40位SHA1转码大写字符串
 *
 *  @return 返回大写SHA1字符串
 */
- (NSString *)sha1EncodingUppercaseString;

@end
