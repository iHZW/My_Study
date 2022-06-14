//
//  CMTableViewCell.m
//  PASecuritiesApp
//
//  Created by Howard on 16/8/31.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "CMTableViewCell.h"
#import "CMNotificationCenter.h"
#import "NSObject+Customizer.h"


@implementation CMTableViewCell

+ (void)load
{
    [NSObject swizzledInstanceMethod:[CMTableViewCell class] originalSelector:NSSelectorFromString(@"dealloc") swizzledSelector:NSSelectorFromString(@"swizzle_dealloc")];
}

- (void)initializeData
{
    [[CMNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyThemeChange:) name:kThemeChangeNotification object:nil];
}

/**
 *  清空所有观察者
 */
- (void)removeAllObservers
{
    [[CMNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeData];
    }
    
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initializeData];
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
 *  换肤通知处理函数
 *
 *  @param notification 通知参数
 */
- (void)notifyThemeChange:(NSNotification *)notification
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
 *  StatusBarFrameChange
 *
 *  @param notification 通知参数
 */
- (void)notifyStatusBarFrameChange:(NSNotification *)notification
{
    
}

@end
