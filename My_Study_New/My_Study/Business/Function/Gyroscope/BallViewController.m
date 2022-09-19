//
//  BallViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/14.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "BallViewController.h"
#import "ZWBallView.h"

@interface BallViewController ()

@property(strong,nonatomic)CMMotionManager *manager;

@property(strong,nonatomic)ZWBallView *ballView;

@end


@implementation BallViewController

- (void)initExtendedData
{
    [super initExtendedData];
    
    self.title = @"陀螺仪 ~ 球";
    
}

- (void)loadUIData
{
    [super loadUIData];
    
    [self loadSubViews];
    [self initCloseBtn];
    [self playBall];
    
//    [self useGyroPush];
}

- (void)loadSubViews
{
    self.ballView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.ballView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    
    [self.manager stopDeviceMotionUpdates];
    [self.manager stopGyroUpdates];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self useGyroPull];
    if (self.manager.deviceMotionActive) {
        [self.manager stopDeviceMotionUpdates];
        NSLog(@"关闭啦");
    }else{
        [self playBall];
    }

//    if (self.manager.gyroActive) {
//        [self.manager stopGyroUpdates];
//    } else {
//        [self useGyroPull];
//    }
    
}

//开启小球的游戏
- (void)playBall{
 
    if (![self.manager isDeviceMotionActive] && [self.manager isDeviceMotionAvailable]) {
        @pas_weakify_self
        [self.manager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            @pas_strongify_self
            self.ballView.acceleration = motion.gravity;
            //    开启主队列异步线程，更新球的位置。
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.ballView updateLocation];
            });
        }];
    }
}

#pragma mark - 陀螺仪的两种获取数据方法PUSH & PULL

- (void)useGyroPull{
    //判断陀螺仪可不可用
    if (self.manager.gyroAvailable){
        //设置陀螺仪多久采样一次
        self.manager.gyroUpdateInterval = 0.1;
        //开始更新，后台线程开始运行。这是Pull方式。
        [self.manager startGyroUpdates];
    }
    //获取并处理陀螺仪数据。这里我们就只是简单的做了打印。
    NSLog(@"X = %f,Y = %f,Z = %f",self.manager.gyroData.rotationRate.x,self.manager.gyroData.rotationRate.y,self.manager.gyroData.rotationRate.z);
}

//在需要的时候获取值
- (void)getGyroData
{
    CMRotationRate rotationRate = self.manager.gyroData.rotationRate;
    NSLog(@"加速度 == x:%f, y:%f, z:%f", rotationRate.x, rotationRate.y, rotationRate.z);
}


- (void)useGyroPush{
    
    //判断陀螺仪可不可用
    if (self.manager.gyroAvailable){
        //设置陀螺仪多久采样一次
        self.manager.gyroUpdateInterval = 0.1;
        //Push方式获取和处理数据，这里我们一样只是做了简单的打印。把采样的工作放在了主线程中。
        @pas_weakify_self
        [self.manager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error)
         {
            @pas_strongify_self
            NSLog(@"X = %f,Y = %f,Z = %f",self.manager.gyroData.rotationRate.x,self.manager.gyroData.rotationRate.y,self.manager.gyroData.rotationRate.z);
            
            CMAcceleration actin = {self.manager.gyroData.rotationRate.x, self.manager.gyroData.rotationRate.y, self.manager.gyroData.rotationRate.z};
            self.ballView.acceleration = actin;
            
            /** 开启主队列异步线程，更新球的位置。  */
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.ballView updateLocation];
            });
        }];

    } else{
        NSLog(@"不可用");
    }
}

- (void)gyroPush
{
    // 1.初始化运动管理对象
//    self.motionManager = [[CMMotionManager alloc] init];
    // 2.判断陀螺仪是否可用
    if (![self.manager isGyroAvailable]) {
        NSLog(@"陀螺仪不可用");
        return;
    }
    // 3.设置陀螺仪更新频率，以秒为单位
    self.manager.gyroUpdateInterval = 0.1;
    // 4.开始实时获取
    [self.manager startGyroUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
        //获取陀螺仪数据
        CMRotationRate rotationRate = gyroData.rotationRate;
        NSLog(@"加速度 == x:%f, y:%f, z:%f", rotationRate.x, rotationRate.y, rotationRate.z);
    }];
}



#pragma mark - lazyLoad

- (CMMotionManager *)manager
{
    if (!_manager) {
        _manager = [[CMMotionManager alloc] init];
        _manager.deviceMotionUpdateInterval = 1 /60;
    }
    return _manager;
}

- (ZWBallView *)ballView
{
    if (!_ballView) {
        _ballView = [[ZWBallView alloc] initWithFrame:self.view.bounds];
    }
    return _ballView;
}


+ (NSDictionary *)ss_constantParams{
    return @{
             @"pageName":[self pageName],
             @"animated":@(YES),
             @"navbarStyle":@(NavbarStyleNone),
             @"hideNavigationBar":@(YES)
    };
}

@end
