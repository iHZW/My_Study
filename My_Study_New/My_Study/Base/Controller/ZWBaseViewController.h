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
/* 是否是tab控制器, 默认为NO */
@property (nonatomic, assign) BOOL isTabVc;

- (void)initLeftNav;

- (void)initRightNav;


@end

