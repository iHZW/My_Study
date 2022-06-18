//
//  NSArray+Map.h
//  StarterApp
//
//  Created by js on 2019/6/13.
//  Copyright © 2019 js. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Map)
- (NSArray *)flatMap:(nonnull id (^)(id item))block;

//数组压平
- (NSArray *)compactMap:(nonnull id (^)(id item))block;

- (NSArray *)filter:(nonnull BOOL (^)(id item))block;
@end

NS_ASSUME_NONNULL_END
