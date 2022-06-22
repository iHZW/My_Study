//
//  NSMutableString+Safe.m
//  CRM
//
//  Created by 杜文杰 on 2022/5/6.
//  Copyright © 2022 CRM. All rights reserved.
//

#import "NSMutableString+Safe.h"
#import "WMSafeProxy.h"

@implementation NSMutableString (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        /* init方法 */
        swizzleInstanceMethod(NSClassFromString(@"NSPlaceholderMutableString"), @selector(initWithString:), @selector(hookInitWithString:));
        swizzleInstanceMethod(NSClassFromString(@"NSPlaceholderMutableString"), @selector(initWithUTF8String:), @selector(hookInitWithUTF8String:));
        swizzleInstanceMethod(NSClassFromString(@"NSPlaceholderMutableString"), @selector(initWithCString:encoding:), @selector(hookInitWithCString:encoding:));
        
        swizzleInstanceMethod(NSClassFromString(@"__NSCFString"), @selector(appendString:), @selector(hookAppendString:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFString"), @selector(insertString:atIndex:), @selector(hookInsertString:atIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFString"), @selector(deleteCharactersInRange:), @selector(hookDeleteCharactersInRange:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFString"), @selector(stringByAppendingString:), @selector(hookStringByAppendingString:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFString"), @selector(substringFromIndex:), @selector(hookSubstringFromIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFString"), @selector(substringToIndex:), @selector(hookSubstringToIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFString"), @selector(substringWithRange:), @selector(hookSubstringWithRange:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFString"), @selector(rangeOfString:options:range:locale:), @selector(hookRangeOfString:options:range:locale:));
    });
    
}
- (nullable instancetype) hookInitWithString:(NSString *)aString
{
    if (aString){
        return [self hookInitWithString:aString];
    }
    SFAssert(NO, @"NSString invalid args hookInitWithString nil aString");
    return nil;
}
- (nullable instancetype) hookInitWithUTF8String:(const char *)nullTerminatedCString
{
    if (NULL != nullTerminatedCString) {
        return [self hookInitWithUTF8String:nullTerminatedCString];
    }
    SFAssert(NO, @"NSString invalid args hookInitWithUTF8String nil aString");
    return nil;
}
- (nullable instancetype) hookInitWithCString:(const char *)nullTerminatedCString encoding:(NSStringEncoding)encoding
{
    if (NULL != nullTerminatedCString){
        return [self hookInitWithCString:nullTerminatedCString encoding:encoding];
    }
    SFAssert(NO, @"NSMutableString invalid args hookInitWithCString nil cstring");
    return nil;
}
- (void) hookAppendString:(NSString *)aString
{
    @synchronized (self) {
        if (aString){
            [self hookAppendString:aString];
        }else{
            SFAssert(NO, @"NSMutableString invalid args hookAppendString:[%@]", aString);
        }
    }
}
- (void) hookInsertString:(NSString *)aString atIndex:(NSUInteger)loc
{
    @synchronized (self) {
        if (aString && loc <= self.length) {
            [self hookInsertString:aString atIndex:loc];
        }else{
            SFAssert(NO, @"NSMutableString invalid args hookInsertString:[%@] atIndex:[%@]", aString, @(loc));
        }
    }
}
- (void) hookDeleteCharactersInRange:(NSRange)range
{
    @synchronized (self) {
        if (NSSafeMaxRange(range) <= self.length){
            [self hookDeleteCharactersInRange:range];
        }else{
            SFAssert(NO, @"NSMutableString invalid args hookDeleteCharactersInRange:[%@]", NSStringFromRange(range));
        }
    }
}
- (NSString *)hookStringByAppendingString:(NSString *)aString
{
    @synchronized (self) {
        if (aString){
            return [self hookStringByAppendingString:aString];
        }
        return self;
    }
}
- (NSString *)hookSubstringFromIndex:(NSUInteger)from
{
    @synchronized (self) {
        if (from <= self.length) {
            return [self hookSubstringFromIndex:from];
        }
        return nil;
    }
}
- (NSString *)hookSubstringToIndex:(NSUInteger)to
{
    @synchronized (self) {
        if (to <= self.length) {
            return [self hookSubstringToIndex:to];
        }
        return self;
    }
}
- (NSString *)hookSubstringWithRange:(NSRange)range
{
    @synchronized (self) {
        if (NSSafeMaxRange(range) <= self.length) {
            return [self hookSubstringWithRange:range];
        }else if (range.location < self.length){
            return [self hookSubstringWithRange:NSMakeRange(range.location, self.length-range.location)];
        }
        return nil;
    }
}
@end
