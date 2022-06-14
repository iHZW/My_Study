//
//  UINavigationItem+iOS7Style.m
//  PASecuritiesApp
//
//  Created by Howard on 16/5/18.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "UINavigationItem+iOS7Style.h"
#import "UIButton+Block.h"
#import "ZWSDK.h"
#import "PASUIDefine.h"


@implementation UINavigationItem (iOS7Style)

- (void)addLeftBarButtonItemWithTitle:(NSString *)title
                          actionBlock:(NavigationItemActionBlock )actionBlock{

    [self addLeftBarButtonItem:[self creatBarButtonItemWithTitle:title actionBlock:actionBlock]];
}

- (void)addRightBarButtonItemWithTitle:(NSString *)title
                           actionBlock:(NavigationItemActionBlock )actionBlock{
    
    [self addRightBarButtonItem:[self creatBarButtonItemWithTitle:title actionBlock:actionBlock]];
}

- (UIBarButtonItem *)creatBarButtonItemWithTitle:(NSString *)title
                                     actionBlock:(NavigationItemActionBlock)actionBlock{
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 50, 30);
    [rightBtn setTitle:title forState:UIControlStateNormal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    [rightBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        if (actionBlock) {
            actionBlock();
        }
    }];
    rightBtn.titleLabel.font = title.length>2?PASFont(15):PASFont(16);
    [rightBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [rightBtn setTitleColor:UIColorFromRGB(0xcf7f82) forState:UIControlStateDisabled];
    return item;
}

- (void)addLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem
{
    self.leftBarButtonItem = nil;
    BOOL isIOS7 = ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0);
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11")){
        [self setLeftBarButtonItems:[NSArray arrayWithObjects: leftBarButtonItem, nil]];
  
    } else {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = (isIOS7? -8: -6);//ios11后无效
        [self setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, leftBarButtonItem, nil]];
    }

    

}

- (void)addRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem
{
    self.rightBarButtonItem = nil;
    BOOL isIOS7 = ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0);
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11")){
        
        UIButton *rightBtn = rightBarButtonItem.customView;

        if ([rightBtn isKindOfClass:[UIButton class]]) {
//            [rightBtn setContentEdgeInsets:UIEdgeInsetsMake(0, KLeftNavbarSpace, 0, -KLeftNavbarSpace)];
        } else {
            
            CGRect tempBounds = rightBtn.bounds;
            tempBounds.origin.x = -KLeftNavbarSpace;
            rightBtn.bounds = tempBounds;
        }
    } else {
        negativeSpacer.width = (isIOS7 ? -8: -6);
    }
    [self setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, rightBarButtonItem, nil]];
}


@end
