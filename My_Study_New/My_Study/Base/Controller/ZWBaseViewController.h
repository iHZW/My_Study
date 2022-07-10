//
//  BaseViewController.h
//  MainSubControllerDemo
//
//  Created by HZW on 2019/5/22.
//  Copyright © 2019 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+Tools.h"
#import "UITableViewCell+DequeCell.h"

@interface ZWBaseViewController : UIViewController

/** 获取类名  */
+ (NSString *)pageName;

/**
 *  判断该viewcontroller当前是否是可见的，用来在app从后台启前台的时候决定要不要刷新数据或者view
 *
 *  @return 可见YES, 否则NO
 */
- (BOOL)isVisible;

#pragma mark - 加载导航控件
/** 通用返回按钮  */
- (void)initLeftNav;

/** 加载右侧控件  */
- (void)initRightNav;

/**
 *  扩展的初始化数据(子类继承时,子类初始化数据处理可在此函数中进行数据初始化)
 */
- (void)initExtendedData;

/**
 *  界面加载(子类继承时,子类扩展界面加载可在此函数中进行处理)
 */
- (void)loadUIData;

/**
 *  内存告警调用(子类继承时,子类收到内存告警时可在此函数中进行处理)
 */
- (void)receiveLowMemoryWarning;

/**
 *  解析路由参数
 *  在viewDidLoad  里解析的,  loadUIData 前可以得到数据
 *  @param  routerParams   路由参数
 *
 */
- (void)decodeRouterParams:(NSDictionary *)routerParams;

@end

