//
//  VersionUpgradeViewController.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/15.
//  Copyright © 2022 HZW. All rights reserved.
//
/* 版本升级引导页 */
#import "BaseViewController.h"
#import "DHGuidePageHUD.h"


NS_ASSUME_NONNULL_BEGIN

@interface VersionUpgradeViewController : BaseViewController

@property (nonatomic, copy) GuideCompleteBlock guideCompleteBlock;

//@property (nonatomic, copy) dispatch_block_t loadLoginBlock;

/* 判断是否第一次启动app  加载引导页 */
+ (BOOL)isFirstStartApp;

@end

NS_ASSUME_NONNULL_END
