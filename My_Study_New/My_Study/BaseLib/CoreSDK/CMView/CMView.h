//
//  CMView.h
//  PASecuritiesApp
//
//  Created by Howard on 16/2/3.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PASBaseProtocol.h"

@interface CMView : UIView <PASBaseProtocol>

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, assign) BOOL bolThemeChg;// 6.14vers 代码重用性，标记模块功能是否支持换肤

@end

