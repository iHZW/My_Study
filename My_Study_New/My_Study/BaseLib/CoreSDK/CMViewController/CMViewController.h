//
//  CMViewController.h
//  PASecuritiesApp
//
//  Created by Howard on 16/2/3.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PASBaseProtocol.h"
#import "NSObject+Customizer.h"
#import "UIViewController+Gesture.h"


@class TabBarItem;

@interface CMViewController : UIViewController <UINavigationControllerDelegate, PASBaseProtocol>

/**
 *  用于 FMWKTypeSideMenu 类型 (Path界面风格，如果有CMTabBar控件，此属性对应CMTabBar中对应的TabBarItem项)
 */
@property (nonatomic, assign) NSInteger tabBarIndex;

/**
 *  用于 FMWKTypeSideMenu 类型 (Path界面风格，如果resident为YES, 此CMViewController会常驻内存;默认状态为NO,页面移除会释放内存)
 */
@property (nonatomic, assign) BOOL resident;

/**
 *  是否显示TabBar(默认显示NO)
 */
@property (nonatomic, assign) BOOL tabBarStatus;

/**
 *  是否显示导航栏(默认显示YES)
 */
@property (nonatomic, assign) BOOL navigationBarStatus;

/**
 *  是否模态展示
 */
@property (nonatomic, assign) BOOL isModal;

/**
 *  扩展的初始化数据(子类继承时,子类初始化数据处理可在此函数中进行数据初始化)
 */
- (void)initExtendedData;

/**
 *  内存告警调用(子类继承时,子类收到内存告警时可在此函数中进行处理)
 */
- (void)receiveLowMemoryWarning;

/**
 *  判断该viewcontroller当前是否是可见的，用来在app从后台启前台的时候决定要不要刷新数据或者view
 *
 *  @return 可见YES, 否则NO
 */
- (BOOL)isVisible;

@end

