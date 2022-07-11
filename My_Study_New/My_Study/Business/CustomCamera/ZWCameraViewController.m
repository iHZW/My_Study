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


@end
