//
//  NSMutableAttributedString+Safe.m
//  CRM
//
//  Created by 杜文杰 on 2022/5/6.
//  Copyright © 2022 CRM. All rights reserved.
//

#import "NSMutableAttributedString+Safe.h"
#import "WMSafeProxy.h"

@implementation NSMutableAttributedString (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        /* init方法 */
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteMutableAttributedString"), @selector(initWithString:), @selector(hookInitWithString:));
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteMutableAttributedString"), @selector(initWithString:attributes:), @selector(hookInitWithString:attributes:));
        
        /* 普通方法 */
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteMutableAttributedString"),
                              @selector(attributedSubstringFromRange:), @selector(hookAttributedSubstringFromRange:));
        
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteMutableAttributedString"),
                              @selector(attribute:atIndex:effectiveRange:), @selector(hookAttribute:atIndex:effectiveRange:));
        
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteMutableAttributedString"),
                              @selector(addAttribute:value:range:), @selector(hookAddAttribute:value:range:));
        
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteMutableAttributedString"),
                              @selector(addAttributes:range:), @selector(hookAddAttributes:range:));
        
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteMutableAttributedString"),
                              @selector(addAttributes:range:), @selector(hookAddAttributes:range:));
        
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteMutableAttributedString"),
                              @selector(setAttributes:range:), @selector(hookSetAttributes:range:));
        
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteMutableAttributedString"),
                              @selector(removeAttribute:range:), @selector(hookRemoveAttribute:range:));
        
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteMutableAttributedString"),
                              @selector(deleteCharactersInRange:), @selector(hookDeleteCharactersInRange:));
        
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteMutableAttributedString"),
                              @selector(replaceCharactersInRange:withString:), @selector(hookReplaceCharactersInRange:withString:));
        
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteMutableAttributedString"),
                              @selector(replaceCharactersInRange:withAttributedString:), @selector(hookReplaceCharactersInRange:withAttributedString:));
        
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteMutableAttributedString"),
                              @selector(enumerateAttribute:inRange:options:usingBlock:), @selector(hookEnumerateAttribute:inRange:options:usingBlock:));
        
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteMutableAttributedString"),
                              @selector(enumerateAttributesInRange:options:usingBlock:), @selector(hookEnumerateAttributesInRange:options:usingBlock:));
        
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
- (void)hookAddAttribute:(id)name value:(id)value range:(NSRange)range {
    @synchronized (self) {
        if (!range.length) {
            [self hookAddAttribute:name value:value range:range];
        }else if (value){
            if (NSSafeMaxRange(range) <= self.length) {
                [self hookAddAttribute:name value:value range:range];
            }else if (range.location < self.length){
                [self hookAddAttribute:name value:value range:NSMakeRange(range.location, self.length-range.location)];
            }
        }else {
            SFAssert(NO, @"hookAddAttribute:value:range: value is nil");
        }
    }
}
- (void)hookAddAttributes:(NSDictionary<NSString *,id> *)attrs range:(NSRange)range {
    @synchronized (self) {
        if (!range.length) {
            [self hookAddAttributes:attrs range:range];
        }else if (attrs){
            if (NSSafeMaxRange(range) <= self.length) {
                [self hookAddAttributes:attrs range:range];
            }else if (range.location < self.length){
                [self hookAddAttributes:attrs range:NSMakeRange(range.location, self.length-range.location)];
            }
        }else{
            SFAssert(NO, @"hookAddAttributes:range: attrs is nil");
        }
    }
}
- (void)hookSetAttributes:(NSDictionary<NSString *,id> *)attrs range:(NSRange)range {
    @synchronized (self) {
        if (!range.length) {
            [self hookSetAttributes:attrs range:range];
        }else if (attrs){
            if (NSSafeMaxRange(range) <= self.length) {
                [self hookSetAttributes:attrs range:range];
            }else if (range.location < self.length){
                [self hookSetAttributes:attrs range:NSMakeRange(range.location, self.length-range.location)];
            }
        }else{
            SFAssert(NO, @"hookSetAttributes:range:  attrs is nil");
        }
    }
}
- (void)hookRemoveAttribute:(id)name range:(NSRange)range {
    @synchronized (self) {
        if (!range.length) {
            [self hookRemoveAttribute:name range:range];
        }else if (name){
            if (NSSafeMaxRange(range) <= self.length) {
                [self hookRemoveAttribute:name range:range];
            }else if (range.location < self.length) {
                [self hookRemoveAttribute:name range:NSMakeRange(range.location, self.length-range.location)];
            }
        }else{
            SFAssert(NO, @"hookRemoveAttribute:range:  name is nil");
        }
    }
}
- (void)hookDeleteCharactersInRange:(NSRange)range {
    @synchronized (self) {
        if (NSSafeMaxRange(range) <= self.length) {
            [self hookDeleteCharactersInRange:range];
        }else if (range.location < self.length) {
            [self hookDeleteCharactersInRange:NSMakeRange(range.location, self.length-range.location)];
        }
    }
}
- (void)hookReplaceCharactersInRange:(NSRange)range withString:(NSString *)str {
    @synchronized (self) {
        if (str){
            if (NSSafeMaxRange(range) <= self.length) {
                [self hookReplaceCharactersInRange:range withString:str];
            }else if (range.location < self.length) {
                [self hookReplaceCharactersInRange:NSMakeRange(range.location, self.length-range.location) withString:str];
            }
        }else{
            SFAssert(NO, @"hookReplaceCharactersInRange:withString:  str is nil");
        }
    }
}
- (void)hookReplaceCharactersInRange:(NSRange)range withAttributedString:(NSString *)str {
    @synchronized (self) {
        if (str){
            if (NSSafeMaxRange(range) <= self.length) {
                [self hookReplaceCharactersInRange:range withAttributedString:str];
            }else if (range.location < self.length) {
                [self hookReplaceCharactersInRange:NSMakeRange(range.location, self.length-range.location) withAttributedString:str];
            }
        }else{
            SFAssert(NO, @"hookReplaceCharactersInRange:withString:  str is nil");
        }
    }
}
- (void)hookEnumerateAttribute:(NSString*)attrName inRange:(NSRange)range options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(id _Nullable, NSRange, BOOL * _Nonnull))block
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
