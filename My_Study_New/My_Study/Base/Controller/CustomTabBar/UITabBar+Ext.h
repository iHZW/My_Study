//
//  UITabBar+Ext.h
//  CRM
//
//  Created by zhangya on 2019/10/29.
//  Copyright © 2019 js. All rights reserved.
//

#import <UIKit/UIKit.h>

/** tabBar 上显示红点使用  */

NS_ASSUME_NONNULL_BEGIN

@interface UITabBar (Ext)
- (void)showBadgeOnItemIndex:(NSInteger)index;   //显示小红点

- (void)hideBadgeOnItemIndex:(NSInteger)index; //隐藏小红点
@end

NS_ASSUME_NONNULL_END
