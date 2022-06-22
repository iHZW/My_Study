//
//  NSNull+Safe.m
//  TestMethod
//
//  Created by js on 15/11/9.
//  Copyright © 2015年 js. All rights reserved.
//

#import "NSNull+Safe.h"
#import <objc/runtime.h>
#import "LogUtil.h"
@implementation NSNull (Safe)

id fun(id self, SEL _cmd){
    [LogUtil error:@"NSNull 不能执行的方法" flag:nil context:[NSNull class]];
    return nil;
}

int fun1(id self, SEL _cmd){
    return -1;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel{
    NSString *selName = NSStringFromSelector(sel);
    if ([selName isEqualToString:@"objectForKey:"] ||
        [selName isEqualToString:@"objectForKeyedSubscript:"]||
        [selName isEqualToString:@"objectAtIndex:"] ||
        [selName isEqualToString:@"objectAtIndexedSubscript:"]) {
        class_addMethod([self class], sel, (IMP)fun, "@@:");
        return YES;
    }
    
    if ([selName isEqualToString:@"intValue"] || [selName isEqualToString:@"integerValue"]){
        class_addMethod([self class], sel, (IMP)fun1, "i@:");
        return YES;
    }
    
    return [super resolveInstanceMethod:sel];
}

@end
