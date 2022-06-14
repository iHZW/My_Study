//
//  NSObject+UUID.m
//  TZYJ_IPhone
//
//  Created by Weirdln on 15/10/27.
//
//

#import "NSObject+UUID.h"
#import <objc/runtime.h>

static const char *uuidTagKey = "uuidTag";

@implementation NSObject (UUID)

- (void)setUuidTag:(NSString *)uuidTag
{
    objc_setAssociatedObject(self, uuidTagKey, uuidTag, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)uuidTag
{
    NSString *uuid = objc_getAssociatedObject(self, uuidTagKey);
    if (!uuid) // 如果没有则生成一个
    {
        uuid = [NSObject uuidString];
        self.uuidTag = uuid;
    }
    return uuid;
}

+ (NSString *)uuidString
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    CFRelease(uuid_string_ref);
    return uuid;
}

+ (NSString *)shortUUIDString
{
    return [[[self class] uuidString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}


@end
