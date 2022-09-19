//
// NSData+Base64.h
// base64
//
// Created by Matt Gallagher on 2009/06/03.
// Copyright 2009 Matt Gallagher. All rights reserved.
//
// This software is provided 'as-is', without any express or implied
// warranty. In no event will the authors be held liable for any damages
// arising from the use of this software. Permission is granted to anyone to
// use this software for any purpose, including commercial applications, and to
// alter it and redistribute it freely, subject to the following restrictions:
//
// 1. The origin of this software must not be misrepresented; you must not
// claim that you wrote the original software. If you use this software
// in a product, an acknowledgment in the product documentation would be
// appreciated but is not required.
// 2. Altered source versions must be plainly marked as such, and must not be
// misrepresented as being the original software.
// 3. This notice may not be removed or altered from any source
// distribution.
//

#import <Foundation/Foundation.h>

@interface NSData (Base64)

/**
 *  将base64字符串解码并生成二进制数据
 *
 *  @param aString base64编码字符串
 *
 *  @return base64解码后二进制数据
 */
+ (NSData *)dataFromBase64String:(NSString *)aString;

/**
 *  将base64编码的二进制数据进行解码
 *
 *  @param data base64编码后的二进制数据
 *
 *  @return 进行base64解码处理的二进制数据
 */
+ (NSData *)dataFromBase64Data:(NSData *)data;

/**
 *  将字符串转换base64编码格式的二进制数据
 *
 *  @param aString 要转换的字符串
 *
 *  @return 返回转换后的二进制数据
 */
+ (NSData *)base64DataFromString:(NSString *)string;

/**
 *  将二进制数据转换成base64编码格式字符串
 *
 *  @param data 要转换的二进制数据
 *
 *  @return 返回转换后的二进制
 */
- (NSString *)base64EncodedString;

/**
将图片为禁止数据转换成base64编码格式字符串

 @return 
 */
- (NSString *)pasBase64EncodeStringForImage;


@end
