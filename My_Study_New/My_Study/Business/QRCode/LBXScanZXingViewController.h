//
//  LBXScanZXingViewController.h
//  My_Study
//
//  Created by hzw on 2023/8/29.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "LBXScanBaseViewController.h"
#import <LBXScan/ZXingWrapper.h>


NS_ASSUME_NONNULL_BEGIN

@interface LBXScanZXingViewController : LBXScanBaseViewController

#pragma mark ---- 需要初始化参数 ------
/**
 ZXing扫码对象
 */
@property (nonatomic, strong) ZXingWrapper *zxingObj;

//打开相册
- (void)openLocalPhoto:(BOOL)allowsEditing;

//开关闪光灯
- (void)openOrCloseFlash;

//启动扫描
- (void)reStartDevice;

//关闭扫描
- (void)stopScan;

@end

NS_ASSUME_NONNULL_END
