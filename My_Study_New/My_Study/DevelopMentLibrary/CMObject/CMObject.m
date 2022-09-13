//
//  CMObject.m
//  DzhIPhone
//
//  Created by Howard Dong on 14-3-14.
//
//

#import "CMObject.h"
#import "CMNetLayerNotificationCenter.h"
#import "NSObject+Customizer.h"
#import "NSObject+MJCoding.h"

@implementation CMObject

+ (void)load
{
    [NSObject swizzledInstanceMethod:[CMObject class] originalSelector:NSSelectorFromString(@"dealloc") swizzledSelector:NSSelectorFromString(@"swizzle_dealloc")];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        
    }
    return self;
}

- (id)init
{
    if(self = [super init])
    {
        [[CMNetLayerNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyNetLayerResponse:) name:[self objectID] object:nil];
    }
    return self;
}

- (void)dealloc
{
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)swizzle_dealloc
{
    [self removeAllObservers];
    [self swizzle_dealloc];
}

/**
 *  对象标识别
 */
- (NSString *)objectID
{
    return self.objectTag;
}

/**
 *  数据刷新处理
 *
 *  @param userInfo 字典数据键值为 kRefreshType, kForceRefresh, kReqPageNo, kReqPos, kReqNum信息
 */
- (void)refreshData:(NSDictionary *)userInfo
{
    
}

/**
 *  网络层数据返回通知处理函数
 *
 *  @param notification 通知参数
 */
- (void)notifyNetLayerResponse:(NSNotification *)notification
{
    
}

/**
 *  清空所有观察者
 */
- (void)removeAllObservers
{
//    [[CMNetLayerNotificationCenter defaultCenter] removeObserver:self];
}

@end
