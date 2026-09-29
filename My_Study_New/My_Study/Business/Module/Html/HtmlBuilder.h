//
//  HtmlBuilder.h
//  My_Study
//
//  Created by hzw on 2022/11/16.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HtmlBuilder : NSObject

+ (instancetype)instance;

- (instancetype)start;
/**
 *  添加 <${tag}
 */
- (instancetype)beginTag:(NSString *)tag;

/**
*  添加 </${tag}>
*/
- (instancetype)endTag:(NSString *)tag;

/**
*  添加 key=value
*/
- (instancetype)attachProperty:(NSString *)value forKey:(NSString *)key;

/**
*  添加 >text
*/
- (instancetype)setInnerText:(NSString *)text;

/**
 * 直接追加字符串
 */
- (instancetype)appendText:(NSString *)text;

/**
 *生成html 字符串
 */
- (NSString *)build;

@end

NS_ASSUME_NONNULL_END
