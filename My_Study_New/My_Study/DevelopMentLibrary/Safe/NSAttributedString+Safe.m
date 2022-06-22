//
//  NSAttributedString+Safe.m
//  WMOFoundation
//
//  Created by 杜文杰 on 2022/5/18.
//

#import "NSAttributedString+Safe.h"
#import "WMSafeProxy.h"

@implementation NSAttributedString (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        /* init方法 */
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteAttributedString"), @selector(initWithString:), @selector(hookInitWithString:));
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteAttributedString"), @selector(initWithString:attributes:), @selector(hookInitWithString:attributes:));
        
        /* 普通方法 */
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteAttributedString"), @selector(attributedSubstringFromRange:), @selector(hookAttributedSubstringFromRange:));
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteAttributedString"), @selector(attribute:atIndex:effectiveRange:), @selector(hookAttribute:atIndex:effectiveRange:));
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteAttributedString"), @selector(enumerateAttribute:inRange:options:usingBlock:), @selector(hookEnumerateAttribute:inRange:options:usingBlock:));
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteAttributedString"), @selector(enumerateAttributesInRange:options:usingBlock:), @selector(hookEnumerateAttributesInRange:options:usingBlock:));
        
    });
}
- (id)hookInitWithString:(NSString*)str {
    if (str){
        return [self hookInitWithString:str];
    }
    return nil;
}
- (id)hookInitWithString:(NSString*)str attributes:(nullable NSDictionary*)attributes{
    if (str){
        return [self hookInitWithString:str attributes:attributes];
    }
    return nil;
}
- (id)hookAttribute:(NSAttributedStringKey)attrName atIndex:(NSUInteger)location effectiveRange:(nullable NSRangePointer)range
{
    @synchronized (self) {
        if (location < self.length){
            return [self hookAttribute:attrName atIndex:location effectiveRange:range];
        }else{
            return nil;
        }
    }
}
- (NSAttributedString *)hookAttributedSubstringFromRange:(NSRange)range {
    @synchronized (self) {
        if (NSSafeMaxRange(range) <= self.length) {
            return [self hookAttributedSubstringFromRange:range];
        }else if (range.location < self.length){
            return [self hookAttributedSubstringFromRange:NSMakeRange(range.location, self.length-range.location)];
        }
        return nil;
    }
}
- (void)hookEnumerateAttribute:(NSString *)attrName inRange:(NSRange)range options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(id _Nullable, NSRange, BOOL * _Nonnull))block
{
    @synchronized (self) {
        if (NSSafeMaxRange(range) <= self.length) {
            [self hookEnumerateAttribute:attrName inRange:range options:opts usingBlock:block];
        }else if (range.location < self.length){
            [self hookEnumerateAttribute:attrName inRange:NSMakeRange(range.location, self.length-range.location) options:opts usingBlock:block];
        }
    }
}
- (void)hookEnumerateAttributesInRange:(NSRange)range options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(NSDictionary<NSString*,id> * _Nonnull, NSRange, BOOL * _Nonnull))block
{
    @synchronized (self) {
        if (NSSafeMaxRange(range) <= self.length) {
            [self hookEnumerateAttributesInRange:range options:opts usingBlock:block];
        }else if (range.location < self.length){
            [self hookEnumerateAttributesInRange:NSMakeRange(range.location, self.length-range.location) options:opts usingBlock:block];
        }
    }
}

@end
