//
//  UIApplication+Ext.h
//  StarterApp
//
//  Created by js on 2019/6/17.
//  Copyright © 2019 js. All rights reserved.
//

#import <UIKit/UIKit.h>

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

@end

NS_ASSUME_NONNULL_END
