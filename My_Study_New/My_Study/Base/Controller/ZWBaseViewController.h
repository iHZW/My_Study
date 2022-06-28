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


#pragma mark - 加载导航控件
/** 通用返回按钮  */
- (void)initLeftNav;

/** 加载右侧控件  */
- (void)initRightNav;





@end

