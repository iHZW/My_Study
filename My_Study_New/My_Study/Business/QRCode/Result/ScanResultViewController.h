//
//  ScanResultViewController.h
//  My_Study
//
//  Created by hzw on 2023/8/29.
//  Copyright © 2023 HZW. All rights reserved.
//
/** 扫描结果页  */
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScanResultViewController : UIViewController

@property (nonatomic, strong) UIImage* imgScan;

@property (nonatomic, copy) NSString* strScan;

@property (nonatomic,copy)NSString *strCodeType;

@end

NS_ASSUME_NONNULL_END
