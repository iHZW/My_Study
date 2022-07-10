//
//  UIApplication+Ext.m
//  StarterApp
//
//  Created by Zhiwei Han on 2022/4/22.
//  Copyright © 2022 Zhiwei Han. All rights reserved.
//

#import "UIApplication+Ext.h"
#import "UIViewController+Child.h"
#import "AppDelegate.h"
#import "ZWBaseViewController.h"
#import "ZWCommonWebPage.h"

@implementation UIApplication (Ext)

+ (UIViewController *)displayViewController{
    return [self displayViewController:[self displayWindow].rootViewController ignorePresent:NO];
}

+ (UIViewController *)displayViewController:(id)currentViewController ignorePresent:(BOOL)ignorePresent{
    if ([currentViewController isKindOfClass:[UINavigationController class]]){
        return [self displayViewController:[[currentViewController viewControllers] lastObject] ignorePresent:ignorePresent];
    }else if ([currentViewController isKindOfClass:[UITabBarController class]]){
        return [self displayViewController:[currentViewController selectedViewController] ignorePresent:ignorePresent];
    }else if ([currentViewController isKindOfClass:[UIViewController class]]) {
        UIViewController *presentedViewController = [currentViewController presentedViewController];
        if (ignorePresent == NO && presentedViewController && [[self blackListForDisplayPresentViewController] containsObject:NSStringFromClass([presentedViewController class])] == NO) {
            return [self displayViewController:[currentViewController presentedViewController] ignorePresent:ignorePresent];
        }else{
            UIViewController *displayChild = [(UIViewController *)currentViewController displayChildViewController];
            if (displayChild){
                if ([displayChild isKindOfClass:[UINavigationController class]] || [displayChild isKindOfClass:[UITabBarController class]]){
                    return [self displayViewController:displayChild ignorePresent:ignorePresent];
                } else {
                    return displayChild;
                }
            }
                
            return currentViewController;
        }
    }else{
        return nil;
    }
}

+ (NSString *)displayPageName{
    UIViewController *vc = [UIApplication displayViewController];
    SEL selector = NSSelectorFromString(@"pageName");
    if ([[vc class]respondsToSelector:selector]) {
        NSString *pageName = ((NSString * (*)(id, SEL))[[vc class] methodForSelector:selector])([vc class], selector);
        return pageName;
    }else{
        return NSStringFromClass([vc class]);
    }
}

+ (NSArray *)blackListForDisplayPresentViewController{
    static NSArray *whiteList = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        whiteList = @[
                      @"RCTModalHostViewController",
                      ];
    });
    
    return whiteList;
}

+ (UIWindow *)displayWindow{
    __block UIWindow *window = nil;
    [[UIApplication sharedApplication].windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIWindow class]]) {
            window = obj;
        }
    }];
    return window;
}

+ (UIViewController *)topOfRootViewController{
    return [self displayViewController:[self displayWindow].rootViewController ignorePresent:YES];
}

// add   不忽略模态化
+ (UIViewController *)topViewController{
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}


+ (NSString *)currentPageName{
    UIViewController *vc = [self displayViewController];
    if ([vc isKindOfClass:[ZWBaseViewController class]]){
        return [[vc class] pageName];
    }
    return @"";
}

+ (void)asyncGetCurrentPageName:(void (^ _Nullable)( NSString * _Nullable ))completionHandler{
    UIViewController *vc = [self displayViewController];
    if ([vc isKindOfClass:ZWCommonWebPage.class]){
        ZWCommonWebPage *webVC = (ZWCommonWebPage *)vc;
//        [webVC getCurrRoutePathCompletionHandler:^(id value, NSError * _Nullable error) {
//            if ([value isKindOfClass:NSString.class]){
//                BlockSafeRun(completionHandler,[value stringByReplacingOccurrencesOfString:@"/" withString:@"-"]);
//            } else {
//                BlockSafeRun(completionHandler,@"HybridWebViewController");
//            }
//        }];
    } else if ([vc isKindOfClass:[ZWBaseViewController class]]){
        NSString *clsName = NSStringFromClass(vc.class);
        for (RouterPageItem *item in ZWM.router.routerConfigs){
            if ([item.clsName isEqualToString:clsName]){
                BlockSafeRun(completionHandler,[item.url stringByReplacingOccurrencesOfString:@"/" withString:@"-"]);
                return;
            }
        }
        BlockSafeRun(completionHandler,clsName);
    }
}

+ (LaunchViewController *)rootViewController{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *vc = appDelegate.window.rootViewController;
    if ([vc isKindOfClass:[LaunchViewController class]]){
        return (LaunchViewController *)vc;
    }
    return nil;
}

+ (NSString *)getCurrentPageRoute{
    UIViewController *vc = [self displayViewController];
    if ([vc isKindOfClass:[ZWBaseViewController class]]){
        NSString *clsName = NSStringFromClass(vc.class);
        for (RouterPageItem *item in ZWM.router.routerConfigs){
            if ([item.clsName isEqualToString:clsName]){
                return item.url;
            }
        }
    }
    return NSStringFromClass(vc.class);
}


@end
