//
//  StoreUtil.h
//  CRM
//
//  Created by js on 2020/4/21.
//  Copyright © 2020 js. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StoreUtil : NSObject
+ (void)setString:(NSString *)object forKey:(NSString *)key isPermanent:(BOOL)isPermanent;
+ (void)removeForKey:(NSString *)key isPermanent:(BOOL)isPermanent;
+ (NSString *)stringForKey:(NSString *)key isPermanent:(BOOL)isPermanent;
@end

NS_ASSUME_NONNULL_END
