//
//  UITabBar+Ext.m
//  CRM
//
//  Created by zhangya on 2019/10/29.
//  Copyright © 2019 js. All rights reserved.
//
//#define TabbarItemNums 5.0    //tabbar的数量

#import "UITabBar+Ext.h"
#import "UIColor+Ext.h"

@implementation UITabBar (Ext)

- (void)showBadgeOnItemIndex:(NSInteger)index{
    
    //移除之前的小红点
    [self removeBadgeOnItemIndex:index];
    
    //新建小红点
    UIView *badgeView = [[UIView alloc]init];
    badgeView.tag = 888 + index;
    badgeView.layer.cornerRadius = 4;
    badgeView.backgroundColor = [UIColor colorFromHexCode:@"#FF5050"];
    CGRect tabFrame = self.frame;
    
    NSInteger tabCount = self.items.count;
    if (tabCount > 0){
        //确定小红点的位置
        float percentX = (index +0.6) / tabCount;
        CGFloat x = ceilf(percentX * tabFrame.size.width);
        CGFloat y = 2;
        badgeView.frame = CGRectMake(x, y, 8, 8);
        [self addSubview:badgeView];
    }
}

- (void)hideBadgeOnItemIndex:(NSInteger)index{
    
    //移除小红点
    [self removeBadgeOnItemIndex:index];
    
}

- (void)removeBadgeOnItemIndex:(NSInteger)index{
    
    //按照tag值进行移除
    for (UIView *subView in self.subviews) {
        
        if (subView.tag == 888+index) {
            
            [subView removeFromSuperview];
            
        }
    }
}

@end
