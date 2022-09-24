//
//  NSObject+UUID.m
//  TZYJ_IPhone
//
//  Created by Weirdln on 15/10/27.
//
//

#import "NSObject+UUID.h"
#import <objc/runtime.h>

#pragma mark - 方案一
//static const char *uuidTagKey = "uuidTag";

#pragma mark - 方案二
//static const char uuidTagKey;

#pragma mark - 方案三 (可以被全局引用获取到)
static const void *uuidTagKey = &uuidTagKey;

@implementation NSObject (UUID)

#pragma mark - 方案一/方案三
//- (void)setUuidTag:(NSString *)uuidTag
//{
//    objc_setAssociatedObject(self, uuidTagKey, uuidTag, OBJC_ASSOCIATION_COPY_NONATOMIC);
//}
//
//- (NSString *)uuidTag
//{
//    NSString *uuid = objc_getAssociatedObject(self, uuidTagKey);
//    if (!uuid) // 如果没有则生成一个
//    {
//        uuid = [NSObject uuidString];
//        self.uuidTag = uuid;
//    }
//    return uuid;
//}

#pragma mark - 方案二
//- (void)setUuidTag:(NSString *)uuidTag
//{
//    objc_setAssociatedObject(self, &uuidTagKey, uuidTag, OBJC_ASSOCIATION_COPY_NONATOMIC);
//}
//
//- (NSString *)uuidTag
//{
//    NSString *uuid = objc_getAssociatedObject(self, &uuidTagKey);
//    if (!uuid) // 如果没有则生成一个
//    {
//        uuid = [NSObject uuidString];
//        self.uuidTag = uuid;
//    }
//    return uuid;
//}

#pragma mark - 方案四 (使用  @selector(uuidTag)  作为key)
//- (void)setUuidTag:(NSString *)uuidTag
//{
//    objc_setAssociatedObject(self, @selector(uuidTag), uuidTag, OBJC_ASSOCIATION_COPY_NONATOMIC);
//}
//
//- (NSString *)uuidTag
//{
//    NSString *uuid = objc_getAssociatedObject(self, @selector(uuidTag));
//    if (!uuid) // 如果没有则生成一个
//    {
//        uuid = [NSObject uuidString];
//        self.uuidTag = uuid;
//    }
//    return uuid;
//}

#pragma mark - 方案五 (使用  @selector(uuidTag) 作为key  getter 方法可以使用_cmd)
- (void)setUuidTag:(NSString *)uuidTag
{
    objc_setAssociatedObject(self, @selector(uuidTag), uuidTag, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)uuidTag
{
    NSString *uuid = objc_getAssociatedObject(self, _cmd);
    if (!uuid) // 如果没有则生成一个
    {
        uuid = [NSObject uuidString];
        self.uuidTag = uuid;
    }
    return uuid;
    
    /** 将关联对象的值置为 nil  就意味着移除了该关联对象的属性  */
    /** 移除所有的关联对象  */
//    objc_removeAssociatedObjects(self);
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
