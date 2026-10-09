//
//  SettingViewController.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/30.
//  Copyright © 2022 HZW. All rights reserved.
//
/** 设置界面  */
#import "ZWBaseTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SettingViewController : ZWBaseTableViewController

/// 创建未来提醒页面，供“我的”等快捷入口复用。
+ (UIViewController *)futureReminderViewController;

@end

NS_ASSUME_NONNULL_END
