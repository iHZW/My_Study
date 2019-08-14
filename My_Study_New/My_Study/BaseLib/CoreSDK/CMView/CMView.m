//
//  CMView.m
//  PASecuritiesApp
//
//  Created by Howard on 16/2/3.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "CMView.h"
#import "CMNotificationCenter.h"
#import "CMNetLayerNotificationCenter.h"
#import "NSObject+Customizer.h"


@implementation CMView

+ (void)load
{
    [NSObject swizzledInstanceMethod:[CMView class] originalSelector:NSSelectorFromString(@"dealloc") swizzledSelector:NSSelectorFromString(@"swizzle_dealloc")];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [[CMNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyThemeChange:) name:kThemeChangeNotification object:nil];
        [[CMNetLayerNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyNetLayerResponse:) name:[self objectID] object:nil];
        [self setClearsContextBeforeDrawing:YES];
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
 6.14 当模块控件，重用在其他模块显示时，赋值是否换肤，重调用换肤通知方法；实现相同控件，不同模块换肤功能不一致

 @param bolThemeChg
 */
- (void)setBolThemeChg:(BOOL)bolThemeChg
{
    _bolThemeChg = bolThemeChg;
    [self notifyThemeChange:nil];
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

/**
 *  清空所有观察者
 */
- (void)removeAllObservers
{
    [[CMNotificationCenter defaultCenter] removeObserver:self];
    [[CMNetLayerNotificationCenter defaultCenter] removeObserver:self];
}

@end


