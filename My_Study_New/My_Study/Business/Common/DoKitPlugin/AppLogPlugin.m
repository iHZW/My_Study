#import "Router+CRM.h"
//
//  AppLogPlugin.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/15.
//  Copyright © 2022 HZW. All rights reserved.
//
#if DOKIT

#import "AppLogPlugin.h"
#import <UIKit/UIKit.h>
#import "DoraemonKit.h"
#import "DoraemonHomeWindow.h"
#import "UIApplication+Ext.h"
#import "MDDebugViewController.h"

@implementation AppLogPlugin

- (void)pluginDidLoad{
    [[DoraemonHomeWindow shareInstance] hide];
    [self loadAppLog];
}

- (void)loadAppLog
{
    MDDebugViewController *vc = [[MDDebugViewController alloc] init];
    [Router pushViewController:vc navigationController:[[UIApplication displayViewController] navigationController] animated:YES];
}

- (void)pluginDidLoad:(NSDictionary *)itemData{
    NSLog(@"AppLogPlugin pluginDidLoad:itemData = %@",itemData);
}

@end



#endif
