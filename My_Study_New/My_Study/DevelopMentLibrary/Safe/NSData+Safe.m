//
//  NSData+Safe.m
//  CRM
//
//  Created by 杜文杰 on 2022/5/6.
//  Copyright © 2022 CRM. All rights reserved.
//

#import "NSData+Safe.h"
#import "WMSafeProxy.h"

@implementation NSData (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteData"), @selector(subdataWithRange:), @selector(hookSubdataWithRange:));
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteData"), @selector(rangeOfData:options:range:), @selector(hookRangeOfData:options:range:));
        
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteMutableData"), @selector(subdataWithRange:), @selector(hookSubdataWithRange:));
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteMutableData"), @selector(rangeOfData:options:range:), @selector(hookRangeOfData:options:range:));
        
        swizzleInstanceMethod(NSClassFromString(@"_NSZeroData"), @selector(subdataWithRange:), @selector(hookSubdataWithRange:));
        swizzleInstanceMethod(NSClassFromString(@"_NSZeroData"), @selector(rangeOfData:options:range:), @selector(hookRangeOfData:options:range:));
        
        swizzleInstanceMethod(NSClassFromString(@"_NSInlineData"), @selector(subdataWithRange:), @selector(hookSubdataWithRange:));
        swizzleInstanceMethod(NSClassFromString(@"_NSInlineData"), @selector(rangeOfData:options:range:), @selector(hookRangeOfData:options:range:));
        
        swizzleInstanceMethod(NSClassFromString(@"__NSCFData"), @selector(subdataWithRange:), @selector(hookSubdataWithRange:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFData"), @selector(rangeOfData:options:range:), @selector(hookRangeOfData:options:range:));
        
    });
}
- (NSData*)hookSubdataWithRange:(NSRange)range
{
    @synchronized (self) {
        if (NSSafeMaxRange(range) <= self.length){
            return [self hookSubdataWithRange:range];
        }else if (range.location < self.length){
            return [self hookSubdataWithRange:NSMakeRange(range.location, self.length-range.location)];
        }
        return nil;
    }
}

- (NSRange)hookRangeOfData:(NSData *)dataToFind options:(NSDataSearchOptions)mask range:(NSRange)range
{
    @synchronized (self) {
        if (dataToFind){
            if (NSSafeMaxRange(range) <= self.length) {
                return [self hookRangeOfData:dataToFind options:mask range:range];
            }else if (range.location < self.length){
                return [self hookRangeOfData:dataToFind options:mask range:NSMakeRange(range.location, self.length - range.location) ];
            }
            return NSMakeRange(NSNotFound, 0);
        }else{
            SFAssert(NO, @"hookRangeOfData:options:range: dataToFind is nil");
            return NSMakeRange(NSNotFound, 0);
        }
    }
}

@end
