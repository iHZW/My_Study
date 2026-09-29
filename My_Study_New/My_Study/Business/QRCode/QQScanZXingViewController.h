//
//  QQScanZXingViewController.h
//  My_Study
//
//  Created by hzw on 2023/8/29.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "LBXScanZXingViewController.h"
#import "UIAlertUtil.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark -模仿qq界面
@interface QQScanZXingViewController : LBXScanZXingViewController

/**
 @brief  扫码区域上方提示文字
 */
@property(nonatomic, strong) UILabel *topTitle;

#pragma mark - 底部几个功能：开启闪光灯、相册、我的二维码
// 底部显示的功能项
@property(nonatomic, strong) UIView *bottomItemsView;
// 相册
@property(nonatomic, strong) UIButton *btnPhoto;
// 闪光灯
@property(nonatomic, strong) UIButton *btnFlash;
// 我的二维码
@property(nonatomic, strong) UIButton *btnMyQR;

@end

NS_ASSUME_NONNULL_END
