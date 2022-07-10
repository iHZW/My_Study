//
//  UIApplication+Ext.h
//  StarterApp
//
//  Created by Zhiwei Han on 2022/4/22.
//  Copyright © 2022 Zhiwei Han. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LaunchViewController.h"


NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (Ext)


/**
 当前正在显示的 viewController， 忽略模态弹出
 
 @return viewController
 */
+ (UIViewController *)displayViewController;

/**
 当前正在显示的 window
 
 @return window
 */
+ (UIWindow *)displayWindow;

/**
 当前处在最顶层的 viewController
 
 @return viewController
 */
+ (UIViewController *)topOfRootViewController;


/**
 当前正在显示的 viewController 的名字
 
 @return viewController 的名字
 */
+ (NSString *)displayPageName;


/**
当前正在显示的 viewController， 不忽略模态弹出

@return viewController
*/
+ (UIViewController *)topViewController;


//当前正在显示的页面的名字
+ (NSString *)currentPageName;

//1.当前页面路由 2.不存在返回pageName
+ (void)asyncGetCurrentPageName:(void (^ _Nullable)( NSString * _Nullable ))completionHandler;

+ (LaunchViewController *)rootViewController;

+ (NSString *)getCurrentPageRoute;

@end

NS_ASSUME_NONNULL_END
