//
//  ZWViewControllerAdapter.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/29.
//  Copyright © 2022 HZW. All rights reserved.
//

#ifndef ZWViewControllerAdapter_h
#define ZWViewControllerAdapter_h

@protocol ZWViewControllerAdapter <NSObject>

@optional
- (void)viewDidLoad;
- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;
- (void)pullRefresh;  //下拉刷新
- (void)loginNotification;   //登录完成通知
- (void)logoutNotification;  //登出通知
- (void)themeChangeNotification; //主题色变更通知

@end


#endif /* ZWViewControllerAdapter_h */
