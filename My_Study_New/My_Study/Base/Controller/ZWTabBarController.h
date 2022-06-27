//
//  ZWTabBarController.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/16.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//首页需要单例存储的内容
@interface MainTabSinglelogin : NSObject
/** 路由和页面类的映射*/
@property (nonatomic, strong) NSMutableDictionary *routePageEntityCache;
/** 单利  */
+ (instancetype)shared;

@end


@interface ZWTabBarController : UITabBarController

- (void)build;

@end

NS_ASSUME_NONNULL_END
