//
//  NSString+Safe.m
//  CRM
//
//  Created by 杜文杰 on 2022/5/6.
//  Copyright © 2022 CRM. All rights reserved.
//

#import "NSString+Safe.h"
#import "WMSafeProxy.h"

static NSString *(*originalStringWithUTF8String)(id, SEL, const char *);
static NSString *(*originalStringWithCString)(id, SEL, const char *, NSStringEncoding);

@implementation NSString (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 保存原始实现，避免类簇或其它方法交换让 hook 选择子再次指向自身。
        Class metaClass = object_getClass([NSString class]);
        Method utf8Method = class_getClassMethod([NSString class], @selector(stringWithUTF8String:));
        Method utf8Hook = class_getClassMethod([NSString class], @selector(hookStringWithUTF8String:));
        if (utf8Method && utf8Hook && method_getImplementation(utf8Method) != method_getImplementation(utf8Hook)) {
            originalStringWithUTF8String = (NSString *(*)(id, SEL, const char *))method_getImplementation(utf8Method);
            class_replaceMethod(metaClass, @selector(stringWithUTF8String:), method_getImplementation(utf8Hook), method_getTypeEncoding(utf8Method));
        }
        Method cStringMethod = class_getClassMethod([NSString class], @selector(stringWithCString:encoding:));
        Method cStringHook = class_getClassMethod([NSString class], @selector(hookStringWithCString:encoding:));
        if (cStringMethod && cStringHook && method_getImplementation(cStringMethod) != method_getImplementation(cStringHook)) {
            originalStringWithCString = (NSString *(*)(id, SEL, const char *, NSStringEncoding))method_getImplementation(cStringMethod);
            class_replaceMethod(metaClass, @selector(stringWithCString:encoding:), method_getImplementation(cStringHook), method_getTypeEncoding(cStringMethod));
        }
        
        /* init方法 */
        swizzleInstanceMethod(NSClassFromString(@"NSPlaceholderString"), @selector(initWithString:), @selector(hookInitWithString:));
        swizzleInstanceMethod(NSClassFromString(@"NSPlaceholderString"), @selector(initWithUTF8String:), @selector(hookInitWithUTF8String:));
        swizzleInstanceMethod(NSClassFromString(@"NSPlaceholderString"), @selector(initWithCString:encoding:), @selector(hookInitWithCString:encoding:));
        
        /* _NSCFConstantString */
        swizzleInstanceMethod(NSClassFromString(@"__NSCFConstantString"), @selector(stringByAppendingString:), @selector(hookStringByAppendingString:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFConstantString"), @selector(substringFromIndex:), @selector(hookSubstringFromIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFConstantString"), @selector(substringToIndex:), @selector(hookSubstringToIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFConstantString"), @selector(substringWithRange:), @selector(hookSubstringWithRange:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFConstantString"), @selector(rangeOfString:options:range:locale:), @selector(hookRangeOfString:options:range:locale:));
        
        /* NSTaggedPointerString */
        swizzleInstanceMethod(NSClassFromString(@"NSTaggedPointerString"), @selector(stringByAppendingString:), @selector(hookStringByAppendingString:));
        swizzleInstanceMethod(NSClassFromString(@"NSTaggedPointerString"), @selector(substringFromIndex:), @selector(hookSubstringFromIndex:));
        swizzleInstanceMethod(NSClassFromString(@"NSTaggedPointerString"), @selector(substringToIndex:), @selector(hookSubstringToIndex:));
        swizzleInstanceMethod(NSClassFromString(@"NSTaggedPointerString"), @selector(substringWithRange:), @selector(hookSubstringWithRange:));
        swizzleInstanceMethod(NSClassFromString(@"NSTaggedPointerString"), @selector(rangeOfString:options:range:locale:), @selector(hookRangeOfString:options:range:locale:));
        
    });
}
+ (NSString*) hookStringWithUTF8String:(const char *)nullTerminatedCString
{
    if (NULL != nullTerminatedCString) {
        return originalStringWithUTF8String(self, @selector(stringWithUTF8String:), nullTerminatedCString);
    }
    SFAssert(NO, @"NSString invalid args hookStringWithUTF8String nil cstring");
    return nil;
}
+ (nullable instancetype) hookStringWithCString:(const char *)cString encoding:(NSStringEncoding)enc
{
    if (NULL != cString){
        return originalStringWithCString(self, @selector(stringWithCString:encoding:), cString, enc);
    }
    SFAssert(NO, @"NSString invalid args hookStringWithCString nil cstring");
    return nil;
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
    SFAssert(NO, @"NSString invalid args hookInitWithCString nil cstring");
    return nil;
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
- (NSRange)hookRangeOfString:(NSString *)searchString options:(NSStringCompareOptions)mask range:(NSRange)range locale:(nullable NSLocale *)locale
{
    @synchronized (self) {
        if (searchString){
            if (NSSafeMaxRange(range) <= self.length) {
                return [self hookRangeOfString:searchString options:mask range:range locale:locale];
            }else if (range.location < self.length){
                return [self hookRangeOfString:searchString options:mask range:NSMakeRange(range.location, self.length-range.location) locale:locale];
            }
            return NSMakeRange(NSNotFound, 0);
        }else{
            SFAssert(NO, @"hookRangeOfString:options:range:locale: searchString is nil");
            return NSMakeRange(NSNotFound, 0);
        }
    }
}

long funLongValue(id self, SEL _cmd){
    return 0;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel{
    NSString *selName = NSStringFromSelector(sel);
    if ([selName isEqualToString:@"longValue"]) {
        class_addMethod([self class], sel, (IMP)funLongValue, "i@:");
        return YES;
    }
    
    return [super resolveInstanceMethod:sel];
}

@end
