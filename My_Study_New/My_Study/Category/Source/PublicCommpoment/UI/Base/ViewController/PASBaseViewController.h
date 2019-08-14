//
//  PASBaseViewController.h
//  PASecuritiesApp
//
//  Created by Howard on 16/2/4.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "CMViewController.h"
#import "PASAppProtocols.h"
#import "UINavigationItem+iOS7Style.h"
//#import "PASSuspensionAdView.h"
#import "MJRefresh.h"
#import "UIAlertUtil.h"
//#import "PASConfigDefine.h"


@interface PASBaseViewController : CMViewController

//@property (nonatomic, assign) KSuspenAdPageType monkeyType;
@property (nonatomic, assign) BOOL bolShowMonkeyAnimation;//是否显示
//@property (nonatomic, strong) PASSuspensionAdView *suspensionAdV;//猴子动画
@property (nonatomic, copy) NSString *app_mc_id;
@property (nonatomic, copy) NSString *sign;   // 6.15 静态化检查,二级跳转native页面静态检查标识
@property (nonatomic, copy) NSString *agreementNo; // 6.15 静态化检查,二级跳转native页面静态检查功能号
/**
 *  界面加载(子类继承时,子类扩展界面加载可在此函数中进行处理)
 */
- (void)loadUIData;

/**
 *  大智慧兼容处理
 */
- (void)updateLayout;

/**
 *  加载扩展工具师徒
 */
- (void)loadExtendToolView;

- (void)setNavigationLeftItem;

/**
 *  Called when the view is about to made visible. Default does nothing(child class override the method)
 *
 *  @param animated 是否显示动画效果
 */
- (void)customViewWillAppear:(BOOL)animated;

/**
 *  Called when the view has been fully transitioned onto the screen. Default does nothing(child class override the method)
 *
 *  @param animated 是否显示动画效果
 */
- (void)customViewDidAppear:(BOOL)animated;

/**
 *  Called when the view is dismissed, covered or otherwise hidden. Default does nothing(child class override the method)
 *
 *  @param animated 是否显示动画效果
 */
- (void)customViewWillDisappear:(BOOL)animated;

/**
 *  Called after the view was dismissed, covered or otherwise hidden. Default does nothing(child class override the method)
 *
 *  @param animated 是否显示动画效果
 */
- (void)customViewDidDisappear:(BOOL)animated;

/**
 *  分享搜索按钮
 */
- (void)setShareAndSearchItem;
- (void)action_share:(id)sender;  /**< 分享 */
- (void)action_search:(id)sender; /**< 搜索 */

/**
 *  无导航栏显示statusbar处理
 */
- (void)showStatusBarWithNoNavigation;

/**
 *  移除无导航栏显示statusbar处理
 */
- (void)removeStatusBarWithNoNavigation;

/**
 *  注册退出登录通知
 */
- (void)registNotificationForLogout;

/**
 *  移除退出登录通知
 */
- (void)removeNotificationForLogout;

/**
 *  退出登录通知方法
 *
 *  @param notification <#notification description#>
 */
- (void)logoutNotification:(NSNotification *)notification;

/**
 *  登录完成通知方法
 *
 *  @param notification <#notification description#>
 */
- (void)loginInNotification:(NSNotification *)notification;

//用于做monkey动画
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
/**
 *  导航栏颜色设置
 */
- (UIImage *)navigationBackgroupImage;

- (void)changeNavigationBarScheme;

@end
