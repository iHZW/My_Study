//
//  ZWCameraViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PHAssetModel.h"
#import "ZWCameraPreViewController.h"
#import "ZWCameraManager.h"
#import "ZWAlbumCropViewController.h"
#import "ZWAlbumManager.h"
#import "DateUtil.h"

@interface ZWCameraViewController () <AVCaptureMetadataOutputObjectsDelegate>

//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property (nonatomic, strong) AVCaptureDevice *device;

//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property (nonatomic, strong) AVCaptureDeviceInput *input;

@property (nonatomic, strong) AVCaptureMetadataOutput *output;
/** 输出图片  */
@property (nonatomic ,strong) AVCaptureStillImageOutput *imageOutput;

//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property (nonatomic, strong) AVCaptureSession *session;

//图像预览层，实时显示捕获的图像
@property (nonatomic ,strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic ,strong) UIView *focusView;

// 0 关 1开 2自动
@property (nonatomic ,assign) NSInteger flashLampType;

@property (nonatomic ,strong) UIButton * flashLampbButton;

@property (nonatomic, strong) UILabel *logLabel;

@end

@implementation ZWCameraViewController

- (void)dealloc{
    NSLog(@"拍照页面释放");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.flashLampType = 2;
    [self initCameraConfig];
    [self initViews];
    [self subscribeSingle];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)subscribeSingle{
//    [[FvAlbumManager manager] setSelectImageComplete:^(NSArray<PHAssetModel *> * _Nonnull obj, BOOL isOriginal) {
//        BlockSafeRun([FvCameraManager manager].cameraCompleteHander,obj,FvCameraStylePhoto);
//    }];
}

- (UILabel *)logLabel
{
    if (!_logLabel) {
        _logLabel = [UILabel labelWithFrame:CGRectMake(0, 0, 100, 45) text:@"古天乐" textColor:UIColorFromRGB(0x1E90FF)];
        _logLabel.font = PASFont(16);
        _logLabel.backgroundColor = UIColorFromRGB(0xD3D3D3);
        _logLabel.userInteractionEnabled = YES;
    }
    return _logLabel;
}

- (void)panLogAction:(UIPanGestureRecognizer *)sender
{
    //1、获得拖动位移
    CGPoint offsetPoint = [sender translationInView:sender.view];
    //2、清空拖动位移
    [sender setTranslation:CGPointZero inView:sender.view];
    //3、重新设置控件位置
    UIView *panView = sender.view;
    CGFloat newX = panView.centerX+offsetPoint.x;
    CGFloat newY = panView.centerY+offsetPoint.y;
   
    CGPoint centerPoint = CGPointMake(newX, newY);
    panView.center = centerPoint;
}

- (void)initViews{
    _focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    _focusView.layer.borderWidth = 1.0;
    _focusView.layer.borderColor =[UIColor greenColor].CGColor;
    _focusView.backgroundColor = [UIColor clearColor];
    _focusView.hidden = YES;
    [self.view addSubview:_focusView];
    
    UIButton * cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(20, kMainScreenHeight - SafeAreaBottomAreaHeight - 100, 60, 60);
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    // Icon_PhotoNormal
    // Icon_PhotoNormal
    UIButton * photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    photoButton.frame = CGRectMake((kMainScreenWidth - 60) / 2, kMainScreenHeight - SafeAreaBottomAreaHeight - 100, 60, 60);
    [photoButton setImage:[UIImage imageNamed:@"Icon_PhotoNormal"] forState:UIControlStateNormal];
    [photoButton setImage:[UIImage imageNamed:@"Icon_PhotoSelect"] forState:UIControlStateSelected];
    [photoButton addTarget:self action:@selector(photoAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:photoButton];
    
    UIButton * changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    changeButton.frame = CGRectMake(kMainScreenWidth - 20 - 60, kMainScreenHeight - SafeAreaBottomAreaHeight - 100, 60, 60);
    [changeButton setTitle:@"切换" forState:UIControlStateNormal];
    changeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [changeButton addTarget:self action:@selector(changeCameraAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeButton];
    
    _flashLampbButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _flashLampbButton.frame = CGRectMake(20, kSysStatusBarHeight + 20, 100, 30);
    _flashLampbButton.titleLabel.font = PASFont(14);
    if (self.flashLampType == 0) {
        [_flashLampbButton setTitle:@"闪光灯:关" forState:UIControlStateNormal];
    }else if (self.flashLampType == 1){
        [_flashLampbButton setTitle:@"闪光灯:开" forState:UIControlStateNormal];
    }else if (self.flashLampType == 2){
        [_flashLampbButton setTitle:@"闪光灯:自动" forState:UIControlStateNormal];
    }
    [_flashLampbButton addTarget:self action:@selector(flashLampbAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flashLampbButton];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    
    [self.view addSubview:self.logLabel];
    self.logLabel.center = self.view.center;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panLogAction:)];
    [self.logLabel addGestureRecognizer:pan];
    
    
}

- (void)initCameraConfig{
    //使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
       
    //使用设备初始化输入
    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
       
    //生成输出对象
    self.output = [[AVCaptureMetadataOutput alloc]init];
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    //生成会话，用来结合输入输出
    self.session = [[AVCaptureSession alloc]init];
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        self.session.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.imageOutput]) {
        [self.session addOutput:self.imageOutput];
    }
    
    //使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];
    
    //开始启动
    [self.session startRunning];
    if ([_device lockForConfiguration:nil]) {
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices ){
        if ( device.position == position ){
            return device;
        }
    }
    return nil;
}

#pragma mark action

- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}

- (void)focusAtPoint:(CGPoint)point{
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
        _focusView.center = point;
        _focusView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self.focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.focusView.hidden = YES;
            }];
        }];
    }
}

- (void)cancelAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoAction{
    AVCaptureConnection * videoConnection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
     if (videoConnection ==  nil) {
         return;
     }
     
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == nil) {
            return;
        }
        NSData *imageData =  [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage * image = [UIImage imageWithData:imageData];
        
        image = [self fixOrientation:image];
        
        PHAssetModel * data = [[PHAssetModel alloc]init];
//        image = [self watermarkImage:image withName:@"娃哈哈"];
//        image = [self watermarkImage:image withName:self.logLabel.text waterReact:self.logLabel.frame];
        image = [self watermarkImageNew:image withName:self.logLabel.text waterReact:self.logLabel.frame];

        data.originalImage = image;
        
        if ([ZWAlbumManager manager].isCrop) {
            ZWAlbumCropViewController * vc = [[ZWAlbumCropViewController alloc]init];
            vc.data = data;
            [self.navigationController pushViewController:vc animated:NO];
        }else{
            ZWCameraPreViewController * vc = [[ZWCameraPreViewController alloc]init];
            [vc setCompleteHander:^(NSArray<PHAssetModel *> * _Nonnull array) {
                BlockSafeRun([ZWCameraManager sharedZWCameraManager].cameraCompleteHander,array,ZWCameraStylePhoto);
            }];

            vc.data = data;
            [self.navigationController pushViewController:vc animated:NO];
        }
     }];
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
      
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
      
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
      
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
              
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
              
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
      
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
              
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
      
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
              
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
      
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (void)changeCameraAction{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        
        CATransition *animation = [CATransition animation];
        
        animation.duration = .5f;
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        animation.type = @"oglFlip";
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[_input device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;
        }
        else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;
        }
        
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:_input];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.input = newInput;
                
            } else {
                [self.session addInput:self.input];
            }
            
            [self.session commitConfiguration];
            
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }
}

- (void)flashLampbAction{
    NSError *error = [[NSError alloc] initWithDomain:@"test"
                                                code:-1
                                            userInfo:@{NSLocalizedDescriptionKey: @"123"}];
    if ([_device lockForConfiguration:&error]) {
        if (self.flashLampType == 0) {
            if ([_device isFlashModeSupported:AVCaptureFlashModeOn]) {
                [_device setFlashMode:AVCaptureFlashModeOn];
            }
            self.flashLampType = 1;
            [self.flashLampbButton setTitle:@"闪光灯:开" forState:UIControlStateNormal];
        }else if (self.flashLampType == 1){
            if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
                [_device setFlashMode:AVCaptureFlashModeAuto];
            }
            self.flashLampType = 2;
            [self.flashLampbButton setTitle:@"闪光灯:自动" forState:UIControlStateNormal];
        }else if (self.flashLampType == 2){
            if ([_device isFlashModeSupported:AVCaptureFlashModeOff]) {
                [_device setFlashMode:AVCaptureFlashModeOff];
            }
            self.flashLampType = 0;
            [self.flashLampbButton setTitle:@"闪光灯:关" forState:UIControlStateNormal];
        }
    }
}




/**
 *  图片添加水印  名称
 */
- (UIImage *)watermarkImage:(UIImage *)img withName:(NSString *)name
{
   NSString* mark = name;
 
   int w = img.size.width;
 
   int h = img.size.height;
 
   UIGraphicsBeginImageContext(img.size);
 
   [img drawInRect:CGRectMake(0, 0, w, h)];
 
   NSDictionary *attr = @{
       NSFontAttributeName: [UIFont boldSystemFontOfSize:16],  //设置字体
       NSForegroundColorAttributeName : UIColorFromRGB(0x1E90FF)   //设置字体颜色
   };
    
    CGFloat justSpae = 20;
    CGFloat tempWidth = 60;
    CGFloat tempHeight = 45;
 
   [mark drawInRect:CGRectMake(0, 0, tempWidth, tempHeight) withAttributes:attr];         //左上角
    [mark drawInRect:CGRectMake(0, h - tempHeight, tempWidth, tempHeight) withAttributes:attr];    //左下角
   [mark drawInRect:CGRectMake(w - justSpae, 0, tempWidth, tempHeight) withAttributes:attr];      //右上角
   [mark drawInRect:CGRectMake(w - justSpae, h - tempHeight , tempWidth, tempHeight) withAttributes:attr];  //右下角
   UIImage *aimg = UIGraphicsGetImageFromCurrentImageContext();
   UIGraphicsEndImageContext();
   
    return aimg;
}

/**
 *  图片添加水印  名称
 */
- (UIImage *)watermarkImage:(UIImage *)img withName:(NSString *)name waterReact:(CGRect)waterReact
{
   NSString* mark = name;
 
   int w = img.size.width;
 
   int h = img.size.height;
 
   UIGraphicsBeginImageContext(img.size);
 
   [img drawInRect:CGRectMake(0, 0, w, h)];
 
    NSDictionary *attr = @{
        NSFontAttributeName: PASFont(32),  //设置字体
        NSForegroundColorAttributeName : UIColorFromRGB(0x1E90FF)   //设置字体颜色
    };
    
    CGFloat justSpae = 20;
    CGFloat tempWidth = waterReact.size.width;
    CGFloat tempHeight = waterReact.size.height;
    CGFloat tempX = waterReact.origin.x * (w/CGRectGetWidth(self.view.frame));
    CGFloat tempY = waterReact.origin.y * (h/CGRectGetHeight(self.view.frame));
    /** 水印位置  */
    [mark drawInRect:CGRectMake(tempX, tempY, tempWidth, tempHeight) withAttributes:attr];

//   [mark drawInRect:CGRectMake(0, 0, tempWidth, tempHeight) withAttributes:attr];         //左上角
//    [mark drawInRect:CGRectMake(0, h - tempHeight, tempWidth, tempHeight) withAttributes:attr];    //左下角
//   [mark drawInRect:CGRectMake(w - justSpae, 0, tempWidth, tempHeight) withAttributes:attr];      //右上角
//   [mark drawInRect:CGRectMake(w - justSpae, h - tempHeight , tempWidth, tempHeight) withAttributes:attr];  //右下角
   UIImage *aimg = UIGraphicsGetImageFromCurrentImageContext();
   UIGraphicsEndImageContext();
   
    return aimg;
}

/**
 *  图片添加水印  名称
 */
- (UIImage *)watermarkImageNew:(UIImage *)img withName:(NSString *)name waterReact:(CGRect)waterReact
{
    NSString* mark = name;
    int w = img.size.width;
    int h = img.size.height;
    UIGraphicsBeginImageContext(img.size);
    [img drawInRect:CGRectMake(0, 0, w, h)];
    
    CGFloat adjust_X = w/CGRectGetWidth(self.view.frame);
    CGFloat adjust_Y = h/CGRectGetHeight(self.view.frame);
    
    NSInteger colorInteger = 0xFFFFFF;//0x1E90FF;
    NSDictionary *attr = @{
        NSFontAttributeName: PASFont(24*adjust_X),  //设置字体
        NSForegroundColorAttributeName : UIColorFromRGB(colorInteger)   //设置字体颜色
    };
         
    CGFloat justSpae = 20;
    CGFloat tempWidth = 100*adjust_X;//waterReact.size.width;
    CGFloat tempHeight = 26*adjust_X;//waterReact.size.height;
    CGFloat tempX = waterReact.origin.x * adjust_X;
    CGFloat tempY = waterReact.origin.y * adjust_Y;
    /** 水印位置  */
    CGRect markRect = CGRectMake(tempX, tempY, tempWidth, tempHeight);
    [mark drawInRect:markRect withAttributes:attr];
    
    /** 绘制球  */
    UIImage *ballIcon = [UIImage imageNamed:@"icon_ball"];
    CGRect ballIconRect = CGRectMake(CGRectGetMaxX(markRect) + 10*adjust_X, CGRectGetMidY(markRect) - 20*adjust_X, 40*adjust_X, 40*adjust_X);
    [ballIcon drawInRect:ballIconRect];
    
    UIImage *footIcon = [UIImage imageNamed:@"foot"];
    [footIcon drawInRect:CGRectMake(CGRectGetMaxX(ballIconRect) + 10*adjust_X, CGRectGetMidY(markRect) - 45*adjust_X, 80*adjust_X, 80*adjust_X)];
    

    /** 左侧图标  */
    UIImage *leftIcon = [UIImage imageNamed:@"mask_left_icon"];
    UIImage *locationIcon = [UIImage imageNamed:@"mask_location_icon"];
    /** 绘制左侧竖线  */
    CGRect leftIconRect = CGRectMake(tempX, CGRectGetMaxY(markRect) + 5*adjust_X, 1*adjust_X, 65*adjust_X);
    [leftIcon drawInRect:leftIconRect];
    
    /** 绘制时时分秒  */
    NSString *timeStr = [DateUtil getCurrentDateWithFormat:DATE_FORMAT_TIME];
    NSDictionary *timeAttr = @{
        NSFontAttributeName: PASBFont(24*adjust_X),  //设置字体
        NSForegroundColorAttributeName : UIColorFromRGB(colorInteger)   //设置字体颜色
    };
    CGRect timeStrRect = CGRectMake(tempX + 10*adjust_X, CGRectGetMinY(leftIconRect), 97*adjust_X, 24*adjust_X);
    [timeStr drawInRect:timeStrRect withAttributes:timeAttr];
    
    /** 绘制年月日  */
    NSString *yearStr = [DateUtil getCurrentDateWithFormat:DATE_FORMAT_YEAR];
    NSDictionary *yearAttr = @{
        NSFontAttributeName: PASFont(13*adjust_X),  //设置字体
        NSForegroundColorAttributeName : UIColorFromRGB(colorInteger)   //设置字体颜色
    };
    [yearStr drawInRect:CGRectMake(CGRectGetMaxX(timeStrRect) + 10*adjust_X, CGRectGetMinY(timeStrRect) + 11*adjust_X, 66*adjust_X, 13*adjust_X) withAttributes:yearAttr];
    
    /** 绘制定位icon  */
    CGRect locationRect = CGRectMake(CGRectGetMinX(timeStrRect), CGRectGetMaxY(timeStrRect) + 10*adjust_X, 9.6*adjust_X, 12*adjust_X);
    [locationIcon drawInRect:locationRect];
    
    /** 绘制定位信息  */
    NSString *locationStr = @"上海市宝山区长江路258号中成智谷上海市宝山区长江路258号中成智谷上海市宝山区长江路258号中成智谷";
    NSDictionary *locationAttr = @{
        NSFontAttributeName: PASFont(12*adjust_X),  //设置字体
        NSForegroundColorAttributeName : UIColorFromRGB(colorInteger)   //设置字体颜色
    };
    [locationStr drawInRect:CGRectMake(CGRectGetMaxX(locationRect) + 10*adjust_X, CGRectGetMinY(locationRect), 296*adjust_X, 32*adjust_X) withAttributes:locationAttr];

    
//   [mark drawInRect:CGRectMake(0, 0, tempWidth, tempHeight) withAttributes:attr];         //左上角
//    [mark drawInRect:CGRectMake(0, h - tempHeight, tempWidth, tempHeight) withAttributes:attr];    //左下角
//   [mark drawInRect:CGRectMake(w - justSpae, 0, tempWidth, tempHeight) withAttributes:attr];      //右上角
//   [mark drawInRect:CGRectMake(w - justSpae, h - tempHeight , tempWidth, tempHeight) withAttributes:attr];  //右下角
   UIImage *aimg = UIGraphicsGetImageFromCurrentImageContext();
   UIGraphicsEndImageContext();
   
    return aimg;
}

- (CGFloat)getAdjustSapce:(CGFloat)imageSpace
               totalSpace:(CGFloat)totalSpace
              adjustSpace:(CGFloat)adjustSpace

{
    CGFloat resultSpace = adjustSpace * (imageSpace / totalSpace);
    return resultSpace;
}


// 画水印
- (UIImage *) imageWithWaterMask:(UIImage*)mask inRect:(CGRect)rect
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
 if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
 {
// UIGraphicsBeginImageContextWithOptions([self size], NO, 0.0); // 0.0 for scale means "scale for device's main screen".
 }
#else
 if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0)
 {
 UIGraphicsBeginImageContext([self size]);
 }
#endif
 //原图
// [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
 //水印图
 [mask drawInRect:rect];
 UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 return newPic;
}


@end
