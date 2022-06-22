//
//  NSMutableData+Safe.m
//  CRM
//
//  Created by 杜文杰 on 2022/5/6.
//  Copyright © 2022 CRM. All rights reserved.
//

#import "NSMutableData+Safe.h"
#import "WMSafeProxy.h"

@implementation NSMutableData (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteMutableData"), @selector(resetBytesInRange:), @selector(hookResetBytesInRange:));
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteMutableData"), @selector(replaceBytesInRange:withBytes:), @selector(hookReplaceBytesInRange:withBytes:));
        swizzleInstanceMethod(NSClassFromString(@"NSConcreteMutableData"), @selector(replaceBytesInRange:withBytes:length:), @selector(hookReplaceBytesInRange:withBytes:length:));
        
        swizzleInstanceMethod(NSClassFromString(@"__NSCFData"), @selector(resetBytesInRange:), @selector(hookResetBytesInRange:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFData"), @selector(replaceBytesInRange:withBytes:), @selector(hookReplaceBytesInRange:withBytes:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFData"), @selector(replaceBytesInRange:withBytes:length:), @selector(hookReplaceBytesInRange:withBytes:length:));
    });
}

- (void)hookResetBytesInRange:(NSRange)range
{
    @synchronized (self) {
        if (NSSafeMaxRange(range) <= self.length){
            [self hookResetBytesInRange:range];
        }else if (range.location < self.length){
            [self hookResetBytesInRange:NSMakeRange(range.location, self.length-range.location)];
        }
    }
}

- (void)hookReplaceBytesInRange:(NSRange)range withBytes:(const void *)bytes
{
    @synchronized (self) {
        if (bytes){
            if (range.location <= self.length) {
                [self hookReplaceBytesInRange:range withBytes:bytes];
            }else {
                SFAssert(NO, @"hookReplaceBytesInRange:withBytes: range.location error");
            }
        }else if (!NSEqualRanges(range, NSMakeRange(0, 0))){
            SFAssert(NO, @"hookReplaceBytesInRange:withBytes: bytes is nil");
        }
    }
}

- (void)hookReplaceBytesInRange:(NSRange)range withBytes:(const void *)bytes length:(NSUInteger)replacementLength
{
    @synchronized (self) {
        if (NSSafeMaxRange(range) <= self.length) {
            [self hookReplaceBytesInRange:range withBytes:bytes length:replacementLength];
        }else if (range.location < self.length){
            [self hookReplaceBytesInRange:NSMakeRange(range.location, self.length - range.location) withBytes:bytes length:replacementLength];
        }
    }
}

@end
