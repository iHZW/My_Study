//
//  LBXScanBaseViewController.h
//  My_Study
//
//  Created by hzw on 2023/8/29.
//  Copyright © 2023 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <LBXScan/LBXScanNative.h>
#import <LBXScan/LBXScanTypes.h>
#import <LBXScan/LBXScanView.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBXScanBaseViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
#pragma mark---- 需要初始化参数 ------

/**
 @brief 是否需要扫码图像
 */
@property(nonatomic, assign) BOOL isNeedScanImage;

/**
@brief 是否需要连续扫码
*/
@property(nonatomic, assign) BOOL continuous;

/**
 @brief  启动区域识别功能
 */
@property(nonatomic, assign) BOOL isOpenInterestRect;

/**
 相机启动提示,如 相机启动中...
 */
@property(nonatomic, copy) NSString *cameraInvokeMsg;

// 相机预览
@property(nonatomic, strong) UIView *cameraPreView;

/**
 *  界面效果参数
 */
@property(nonatomic, strong) LBXScanViewStyle *style;

// default  AVCaptureVideoOrientationPortrait
@property(nonatomic, assign) AVCaptureVideoOrientation orientation;

/**
 @brief  扫码区域视图,二维码一般都是框
 */
@property(nonatomic, strong) LBXScanView *qRScanView;

/// 首次加载
@property(nonatomic, assign) BOOL firstLoad;

// 条码识别位置标示
@property(nonatomic, strong) UIView * _Nullable codeFlagView;

@property(nonatomic, strong) NSArray<CALayer *> * _Nullable layers;

/**
 @brief  扫码存储的当前图片
 */
@property(nonatomic, strong) UIImage *scanImage;

/**
 @brief  闪关灯开启状态记录
 */
@property(nonatomic, assign) BOOL isOpenFlash;

// 继承者实现
- (void)reStartDevice;

/// 扫描结果
/// - Parameter array: 扫描结果数据
- (void)scanResultWithArray:(NSArray<LBXScanResult *> *)array;

- (void)resetCodeFlagView;

/// 截取UIImage指定区域图片
- (UIImage *)imageByCroppingWithSrcImage:(UIImage *)srcImg cropRect:(CGRect)cropRect;

/// 请求相机权限
- (void)requestCameraPemissionWithResult:(void (^)(BOOL granted))completion;
/// 授权相册权限
+ (void)authorizePhotoPermissionWithCompletion:(void (^)(BOOL granted, BOOL firstTime))completion;

- (BOOL)isLandScape;

- (AVCaptureVideoOrientation)videoOrientation;

@end

NS_ASSUME_NONNULL_END
