//
//  NSArray+Map.m
//  StarterApp
//
//  Created by js on 2019/6/13.
//  Copyright © 2019 js. All rights reserved.
//

#import "NSArray+Func.h"

@implementation NSArray (Func)

- (NSArray *)flatMap:(nonnull id (^)(id item))block{
    NSMutableArray *mutArray = [NSMutableArray array];
    for (id item in self){
        id toObject = block(item);
        if (toObject){
            [mutArray addObject:toObject];
        }
    }
    return [mutArray copy];
}

- (NSArray *)compactMap:(nonnull id (^)(id item))block{
    NSMutableArray *mutArray = [NSMutableArray array];
    for (id item in self){
        id toObject = block(item);
        if (toObject){
            if ([toObject isKindOfClass:[NSArray class]]){
                [mutArray addObjectsFromArray:toObject];
            } else {
                [mutArray addObject:toObject];
            }
            
        }
    }
    return [mutArray copy];
}

- (NSArray *)filter:(nonnull BOOL (^)(id item))block{
    NSMutableArray *mutArray = [NSMutableArray array];
    for (id item in self){
        if (block(item)){
            [mutArray addObject:item];
        }
    }
    return [mutArray copy];
}
@end
