//
//  ZWColorPickInfoWindow.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/13.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZWColorPickInfoWindow : UIWindow

+ (instancetype)shareInstance;


- (void)showView;

- (void)hiddenView;

@end

NS_ASSUME_NONNULL_END
