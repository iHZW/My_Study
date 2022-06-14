//
//  UINavigationItem+iOS7Style.h
//  PASecuritiesApp
//
//  Created by Howard on 16/5/18.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^NavigationItemActionBlock)(void);

@interface UINavigationItem (iOS7Style)

- (void)addRightBarButtonItemWithTitle:(NSString *)title
                           actionBlock:(NavigationItemActionBlock )actionBlock;

- (void)addLeftBarButtonItemWithTitle:(NSString *)title
                          actionBlock:(NavigationItemActionBlock )actionBlock;

/**
 *  添加leftBarButtonItem
 *
 *  @param leftBarButtonItem UIBarButtonItem信息
 */
- (void)addLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem;

/**
 *  添加leftBarButtonItem
 *
 *  @param rightBarButtonItem UIBarButtonItem信息
 */
- (void)addRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem;

@end
