//
//  NSObject+UUID.h
//  TZYJ_IPhone
//
//  Created by Weirdln on 15/10/27.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (UUID)

 /** NSObject的唯一标志，如果没有设置会调用uuidString方法生成一个 */
@property (nonatomic, copy) NSString *uuidTag;

/**
 *  生成一个NSObject的uuid标志
 */
+ (NSString *)uuidString;

/**
 *  生成去掉“-”后UUID标记
 */
+ (NSString *)shortUUIDString;

@end
