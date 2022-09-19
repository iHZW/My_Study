//
//  NSString+Extension.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/8/3.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Extension)

/**
 *  获取链接后缀名
 */
- (NSString *)urlExtension;

/**
 *  判断链接的后缀名 是否 后缀名数组中
 *
 *  @param extensions    扩展字段数组
 */
- (BOOL)isURLMatchExtensions:(NSArray *)extensions;

/**
 *  url中占位符替换
 *  例如: @"https://m-qa.xiaoke.cn/callcenter/record/detail?logid=1010&pid=%@&recordId=%@&userWid=%@"
 *
 *  @param url    带有站位符的url
 *  @param  params    需要替换的参数数组
 */
+ (NSString *)getFormatterUrl:(NSString *)url params:(NSArray *)params;


@end

NS_ASSUME_NONNULL_END
