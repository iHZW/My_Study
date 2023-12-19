//
//  SingletonTemplate.h
//  JCYProduct
//
//  Created by Howard on 15/9/23.
//  Copyright © 2015年 Howard. All rights reserved.
//
/* 单利宏 */

#ifndef SINGLETONTEMPLATE_H
#define SINGLETONTEMPLATE_H

#define DEFINE_SINGLETON_T_FOR_HEADER(className) \
\
+ (className *)shared##className;

#if !__has_feature(objc_arc)
#define DEFINE_SINGLETON_T_FOR_CLASS(className) \
\
+ (className *)shared##className { \
static className *shared##className = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
shared##className = [NSAllocateObject(self, 0, NULL) init]; \
}); \
return shared##className; \
}\
\
- (id)copyWithZone:(NSZone *)zone{\
return self;\
}\
\
- (id)mutableCopyWithZone:(NSZone *)zone{\
return [self copyWithZone:zone];\
}\
\
- (id)retain{\
return self;\
}\
\
- (NSUInteger)retainCount{\
return NSUIntegerMax;\
}\
\
- (id)autorelease{\
return self;\
}\
\
- (oneway void)release{\
}
#else
#define DEFINE_SINGLETON_T_FOR_CLASS(className) \
\
static className *_shared##className = nil;\
+ (className *)shared##className { \
if (_shared##className) {\
    return _shared##className;\
}\
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_shared##className = [[[self class] alloc] init]; \
}); \
return _shared##className; \
}\
+ (instancetype)allocWithZone:(struct _NSZone *)zone {\
    if (_shared##className) {\
        return _shared##className;\
    }\
    return [super allocWithZone:zone];\
}\
\
- (instancetype)copy {\
    return self;\
}\
\
- (instancetype)mutableCopy {\
    return self;\
}
#endif

#endif /* SINGLETONTEMPLATE_H */
