//
//  CRMViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/3/8.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CRMViewController.h"
#import "WXApi.h"
#import <QMUIKit/QMUIKit.h>

#define kSize 100

typedef void (^HandleBlock)(id);

@interface ZWRotatingBallView : UIView

@property (nonatomic, assign) CGFloat rotationX;
@property (nonatomic, assign) CGFloat rotationY;

- (void)updateRotationX:(CGFloat)rotationX rotationY:(CGFloat)rotationY;

@end

@implementation ZWRotatingBallView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.opaque = NO;
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (void)updateRotationX:(CGFloat)rotationX rotationY:(CGFloat)rotationY {
    self.rotationX = rotationX;
    self.rotationY = rotationY;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) {
        return;
    }

    CGFloat radius = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) * 0.5 - 4;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGRect ballRect = CGRectMake(center.x - radius, center.y - radius, radius * 2, radius * 2);

    CGContextSaveGState(context);
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithOvalInRect:ballRect];
    [clipPath addClip];

    [self drawBaseSphereInContext:context center:center radius:radius];
    [self drawSurfaceMarksInContext:context center:center radius:radius];
    [self drawGridInContext:context center:center radius:radius];
    [self drawSphereShadingInContext:context center:center radius:radius];

    CGContextRestoreGState(context);

    [[UIColor colorWithWhite:1 alpha:0.55] setStroke];
    clipPath.lineWidth = 1.5;
    [clipPath stroke];
}

- (void)drawBaseSphereInContext:(CGContextRef)context center:(CGPoint)center radius:(CGFloat)radius {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSArray *colors = @[
        (__bridge id)[UIColor colorWithRed:0.20 green:0.78 blue:1.00 alpha:1].CGColor,
        (__bridge id)[UIColor colorWithRed:0.05 green:0.24 blue:0.68 alpha:1].CGColor,
        (__bridge id)[UIColor colorWithRed:0.02 green:0.08 blue:0.25 alpha:1].CGColor
    ];
    CGFloat locations[] = {0, 0.62, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
    CGPoint lightCenter = CGPointMake(center.x - radius * 0.32, center.y - radius * 0.42);
    CGContextDrawRadialGradient(context, gradient, lightCenter, radius * 0.08, center, radius * 1.15, 0);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

- (void)drawGridInContext:(CGContextRef)context center:(CGPoint)center radius:(CGFloat)radius {
    [[UIColor colorWithWhite:1 alpha:0.32] setStroke];

    for (NSInteger index = -2; index <= 2; index++) {
        CGFloat latitude = index * M_PI / 8.0;
        [self drawLatitude:latitude context:context center:center radius:radius];
    }

    for (NSInteger index = 0; index < 12; index++) {
        CGFloat longitude = index * M_PI / 6.0;
        [self drawLongitude:longitude context:context center:center radius:radius];
    }
}

- (void)drawLatitude:(CGFloat)latitude context:(CGContextRef)context center:(CGPoint)center radius:(CGFloat)radius {
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 0.8;

    BOOL drawing = NO;
    for (NSInteger index = 0; index <= 144; index++) {
        CGFloat longitude = -M_PI + 2 * M_PI * index / 144.0;
        CGFloat z = 0;
        CGPoint point = [self projectLatitude:latitude longitude:longitude center:center radius:radius z:&z];
        if (z > -radius * 0.05) {
            if (!drawing) {
                [path moveToPoint:point];
                drawing = YES;
            } else {
                [path addLineToPoint:point];
            }
        } else {
            drawing = NO;
        }
    }
    [path stroke];
}

- (void)drawLongitude:(CGFloat)longitude context:(CGContextRef)context center:(CGPoint)center radius:(CGFloat)radius {
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 0.8;

    BOOL drawing = NO;
    for (NSInteger index = 0; index <= 96; index++) {
        CGFloat latitude = -M_PI_2 + M_PI * index / 96.0;
        CGFloat z = 0;
        CGPoint point = [self projectLatitude:latitude longitude:longitude center:center radius:radius z:&z];
        if (z > -radius * 0.05) {
            if (!drawing) {
                [path moveToPoint:point];
                drawing = YES;
            } else {
                [path addLineToPoint:point];
            }
        } else {
            drawing = NO;
        }
    }
    [path stroke];
}

- (void)drawSurfaceMarksInContext:(CGContextRef)context center:(CGPoint)center radius:(CGFloat)radius {
    NSArray<NSDictionary *> *marks = @[
        @{@"lat": @(-0.32), @"lon": @(-0.65), @"size": @(22), @"color": [UIColor colorWithRed:0.06 green:0.83 blue:0.68 alpha:0.95]},
        @{@"lat": @(0.18), @"lon": @(0.18), @"size": @(18), @"color": [UIColor colorWithRed:1.00 green:0.65 blue:0.15 alpha:0.95]},
        @{@"lat": @(0.48), @"lon": @(0.88), @"size": @(16), @"color": [UIColor colorWithRed:0.96 green:0.22 blue:0.42 alpha:0.95]},
        @{@"lat": @(-0.06), @"lon": @(1.55), @"size": @(14), @"color": [UIColor colorWithRed:0.58 green:0.36 blue:1.00 alpha:0.95]}
    ];

    for (NSDictionary *mark in marks) {
        CGFloat z = 0;
        CGPoint point = [self projectLatitude:[mark[@"lat"] doubleValue]
                                    longitude:[mark[@"lon"] doubleValue]
                                       center:center
                                       radius:radius
                                            z:&z];
        if (z <= -radius * 0.1) {
            continue;
        }

        CGFloat frontRatio = MAX(0.25, (z / radius + 1) * 0.5);
        CGFloat size = [mark[@"size"] doubleValue] * frontRatio;
        UIColor *color = mark[@"color"];
        [color setFill];
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x - size, point.y - size * 0.65, size * 2, size * 1.3)];
        [path fill];
    }
}

- (void)drawSphereShadingInContext:(CGContextRef)context center:(CGPoint)center radius:(CGFloat)radius {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSArray *shadowColors = @[
        (__bridge id)[UIColor colorWithWhite:0 alpha:0].CGColor,
        (__bridge id)[UIColor colorWithWhite:0 alpha:0.45].CGColor
    ];
    CGFloat shadowLocations[] = {0.45, 1};
    CGGradientRef shadowGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)shadowColors, shadowLocations);
    CGContextDrawRadialGradient(context, shadowGradient, CGPointMake(center.x - radius * 0.25, center.y - radius * 0.35), radius * 0.1, center, radius, 0);
    CGGradientRelease(shadowGradient);

    [[UIColor colorWithWhite:1 alpha:0.42] setFill];
    UIBezierPath *highlight = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(center.x - radius * 0.48, center.y - radius * 0.56, radius * 0.48, radius * 0.24)];
    [highlight fill];

    CGColorSpaceRelease(colorSpace);
}

- (CGPoint)projectLatitude:(CGFloat)latitude
                 longitude:(CGFloat)longitude
                    center:(CGPoint)center
                    radius:(CGFloat)radius
                         z:(CGFloat *)zValue {
    CGFloat cosLatitude = cos(latitude);
    CGFloat x = radius * cosLatitude * sin(longitude);
    CGFloat y = radius * sin(latitude);
    CGFloat z = radius * cosLatitude * cos(longitude);

    CGFloat cosY = cos(self.rotationY);
    CGFloat sinY = sin(self.rotationY);
    CGFloat rotatedX = x * cosY + z * sinY;
    CGFloat rotatedZ = -x * sinY + z * cosY;

    CGFloat cosX = cos(self.rotationX);
    CGFloat sinX = sin(self.rotationX);
    CGFloat rotatedY = y * cosX - rotatedZ * sinX;
    CGFloat finalZ = y * sinX + rotatedZ * cosX;

    if (zValue) {
        *zValue = finalZ;
    }
    return CGPointMake(center.x + rotatedX, center.y - rotatedY);
}

@end

@interface CRMViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@property (nonatomic, copy) NSString *reportInfo;

@property (nonatomic, copy) HandleBlock handler;

@property (nonatomic, assign) BOOL cancelled;

@property (nonatomic, strong) UIView *ballView;

@property (nonatomic, assign) CGPoint ballRotation;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) CGFloat scale;

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGFloat heightTag;

/**底部容器*/
@property (nonatomic, strong) CATransformLayer *contentLayer;
/** 底部立方体容器 */
@property (nonatomic, strong) UIView *cubeView;
/**上面*/
@property (nonatomic, strong) CALayer *topLayer;
/**下面*/
@property (nonatomic, strong) CALayer *bottomLayer;
/**左面*/
@property (nonatomic, strong) CALayer *leftLayer;
/**右面*/
@property (nonatomic, strong) CALayer *rightLayer;
/**前面*/
@property (nonatomic, strong) CALayer *frontLayer;
/**后面*/
@property (nonatomic, strong) CALayer *backLayer;
/**底部容器*/
@property (nonatomic, strong) CATransformLayer *imageContentLayer;

@property (nonatomic, assign) CGPoint endPoint;

@property (nonatomic, assign) CGPoint cubePoint;

@property (nonatomic, strong) UIImageView *iconImage;

// 绘制正方体
@property (nonatomic, strong) UIView *reactView;
@property (nonatomic, strong) CATransformLayer *reactContentLayer;
@property (nonatomic, assign) CGPoint reactPoint;

@end

@implementation CRMViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"CRM";
    //    self.view.backgroundColor = [UIColor cyanColor];

    self.scale     = 0;
    self.height    = 100;
    self.semaphore = dispatch_semaphore_create(1);

    /** 加载球类运动  */
    [self loadBallView];

    [self loadSubViews];

    /** 绘制正方体  */
    [self createReact];
    [self.view bringSubviewToFront:self.ballView];

    //    [self loadTime];

    //    [self loadIconImage];
}

- (void)loadBallView {
    ZWRotatingBallView *ballView = [[ZWRotatingBallView alloc] initWithFrame:CGRectMake(100, 110, 130, 130)];
    [ballView updateRotationX:-0.25 rotationY:0.45];
    self.ballRotation = CGPointMake(0.45, -0.25);
    ballView.layer.shadowColor = UIColor.blackColor.CGColor;
    ballView.layer.shadowOpacity = 0.18;
    ballView.layer.shadowRadius = 10;
    ballView.layer.shadowOffset = CGSizeMake(0, 8);
    self.ballView = ballView;
    [self.view addSubview:self.ballView];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.objectTag = @"ball";
    [self.ballView addGestureRecognizer:pan];

    [self.view bringSubviewToFront:self.ballView];
}

- (void)createReact {
    self.reactView = [[UIView alloc] initWithFrame:CGRectMake(100, 300, 100, 100)];
    [self.view addSubview:self.reactView];

    // 创建CATransformLayer对象
    self.reactContentLayer       = [CATransformLayer layer];
    self.reactContentLayer.frame = self.reactView.layer.bounds;
    [self.reactView.layer addSublayer:self.reactContentLayer];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.objectTag               = @"3";
    [self.reactView addGestureRecognizer:pan];

    // 前
    [self createLayerX:0 y:0 z:kSize / 2 transform:CATransform3DIdentity];
    // 后
    [self createLayerX:0 y:0 z:-kSize / 2 transform:CATransform3DIdentity];
    // 左
    [self createLayerX:-kSize / 2 y:0 z:0 transform:CATransform3DMakeRotation(M_PI_2, 0, 1, 0)];
    // 右
    [self createLayerX:kSize / 2 y:0 z:0 transform:CATransform3DMakeRotation(M_PI_2, 0, 1, 0)];
    // 上
    [self createLayerX:0 y:-kSize / 2 z:0 transform:CATransform3DMakeRotation(M_PI_2, 1, 0, 0)];
    // 下
    [self createLayerX:0 y:kSize / 2 z:0 transform:CATransform3DMakeRotation(M_PI_2, 1, 0, 0)];
}

- (void)createLayerX:(CGFloat)x
                   y:(CGFloat)y
                   z:(CGFloat)z
           transform:(CATransform3D)transform {
    CALayer *layer        = [CALayer layer];
    layer.backgroundColor = [[self class] randomColor].CGColor;
    layer.bounds          = CGRectMake(0, 0, 100, 100);
    layer.position        = CGPointMake(x, y);
    layer.zPosition       = z;
    layer.transform       = transform;
    [self.reactContentLayer addSublayer:layer];
}

- (void)loadIconImage {
    self.iconImage                        = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_ball_001"]];
    self.iconImage.frame                  = CGRectMake(100, 300, 100, 100);
    self.iconImage.userInteractionEnabled = YES;
    [self.view addSubview:self.iconImage];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleIconTap:)];
    [self.iconImage addGestureRecognizer:tap];
}

- (void)handleIconTap:(UIGestureRecognizer *)sender {
    //    [UIView animateWithDuration:1.0 animations:^{
    //        self.iconImage.layer.transform = CATransform3DMakeRotation(M_PI_2, 1, 0, 0);
    //    } completion:^(BOOL finished) {
    //        [UIView animateWithDuration:1.0 animations:^{
    //            self.iconImage.layer.transform = CATransform3DMakeRotation(M_PI, 1, 0, 0);
    //        }];
    //    }];
}

- (void)loadTime {
    @pas_weakify_self
        self.timer = [[NSTimer alloc] initWithFireDate:[NSDate distantPast]
                                              interval:1
                                               repeats:YES
                                                 block:^(NSTimer *_Nonnull timer) {
                                                     @pas_strongify_self
                                                         self.scale -= 1;
                                                     self.height -= 10;
                                                     self.heightTag = 50 - self.height;
                                                     if (self.scale <= -40000) {
                                                         self.scale  = 0;
                                                         self.height = 100;
                                                     }
                                                     [self update];
                                                 }];
    [NSRunLoop.mainRunLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)loadSubViews {
    self.cubeView = [[UIView alloc] initWithFrame:CGRectMake(150, 430, 180, 180)];
    [self.view addSubview:self.cubeView];

    // 创建CATransformLayer对象
    CATransformLayer *contentLayer = [CATransformLayer layer];
    contentLayer.frame             = self.cubeView.layer.bounds;
    CGSize size                    = contentLayer.bounds.size;
    contentLayer.transform         = CATransform3DMakeTranslation(size.width / 2, size.height / 2, 0);
    self.contentLayer              = contentLayer;
    [self.cubeView.layer addSublayer:contentLayer];

    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = -1.0 / 500.0;
    self.cubeView.layer.sublayerTransform = perspective;

    // 初始化六个图层
    // 顶部与底部的沿着x轴旋转90度
    self.topLayer = [self layerAtX:0 y:-kSize / 2 z:0 color:[UIColor redColor] transform:CATransform3DMakeRotation(M_PI_2, 1, 0, 0)];

    self.bottomLayer = [self layerAtX:0 y:kSize / 2 z:0 color:[UIColor greenColor] transform:CATransform3DMakeRotation(M_PI_2, 1, 0, 0)];
    // 左边与右边的沿着y轴旋转90度
    self.leftLayer = [self layerAtX:-kSize / 2 y:0 z:0 color:[UIColor blueColor] transform:CATransform3DMakeRotation(M_PI_2, 0, 1, 0)];

    self.rightLayer = [self layerAtX:kSize / 2 y:0 z:0 color:[UIColor blackColor] transform:CATransform3DMakeRotation(M_PI_2, 0, 1, 0)];

    // 前面与后面的不需要变化,所以使用CATransform3DIdentity
    self.frontLayer = [self layerAtX:0 y:0 z:kSize / 2 color:[UIColor brownColor] transform:CATransform3DIdentity];

    self.backLayer = [self layerAtX:0 y:0 z:-kSize / 2 color:[UIColor brownColor] transform:CATransform3DIdentity];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.objectTag               = @"2";
    [self.cubeView addGestureRecognizer:pan];
}

- (void)pan:(UIPanGestureRecognizer *)recognizer {
    NSString *objectTag = recognizer.objectTag;

    if ([objectTag isEqualToString:@"2"]) {
        // 获取到的是手指移动后，在相对坐标中的偏移量(以手指接触屏幕的第一个点为坐标原点)
        CGPoint translation = [recognizer translationInView:self.cubeView];
        translation.x += self.cubePoint.x;
        translation.y += self.cubePoint.y;

        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1.0 / 500.0;
        transform = CATransform3DRotate(transform, translation.x * 0.01, 0, 1, 0);
        transform = CATransform3DRotate(transform, translation.y * 0.01, 1, 0, 0);
        self.cubeView.layer.sublayerTransform = transform;

        if (recognizer.state == UIGestureRecognizerStateEnded ||
            recognizer.state == UIGestureRecognizerStateCancelled ||
            recognizer.state == UIGestureRecognizerStateFailed) {
            self.cubePoint = translation;
        }
    } else if ([objectTag isEqualToString:@"3"]) {
        CGPoint translation = [recognizer translationInView:self.view];
        translation.x += self.reactPoint.x;
        translation.y += self.reactPoint.y;
        CATransform3D transform                = CATransform3DIdentity;
        transform                              = CATransform3DRotate(transform, translation.x * 0.01, 0, 1, 0);
        transform                              = CATransform3DRotate(transform, translation.y * -0.01, 1, 0, 0);
        self.reactView.layer.sublayerTransform = transform;
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            self.reactPoint = translation;
        }
    } else if ([objectTag isEqualToString:@"ball"]) {
        CGPoint translation = [recognizer translationInView:self.ballView];
        CGFloat rotateY = self.ballRotation.x + translation.x * 0.01;
        CGFloat rotateX = self.ballRotation.y + translation.y * 0.01;

        ZWRotatingBallView *ballView = (ZWRotatingBallView *)self.ballView;
        [ballView updateRotationX:rotateX rotationY:rotateY];

        if (recognizer.state == UIGestureRecognizerStateEnded ||
            recognizer.state == UIGestureRecognizerStateCancelled ||
            recognizer.state == UIGestureRecognizerStateFailed) {
            self.ballRotation = CGPointMake(rotateY, rotateX);
        }
    } else {
        // 获取到的是手指移动后，在相对坐标中的偏移量(以手指接触屏幕的第一个点为坐标原点)

        CGPoint translation = [recognizer translationInView:self.ballView];
        translation.x += self.endPoint.x;
        translation.y += self.endPoint.y;
        CATransform3D transform               = CATransform3DIdentity;
        transform                             = CATransform3DRotate(transform, translation.x * 1 / 100, 0, 1, 0);
        transform                             = CATransform3DRotate(transform, translation.y * -1 / 100, 1, 0, 0);
        self.ballView.layer.sublayerTransform = transform;

        if (recognizer.state == UIGestureRecognizerStateEnded) {
            self.endPoint = translation;
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer.view == self.view) {
        UIView *touchView = touch.view;
        if ([touchView isDescendantOfView:self.ballView] ||
            [touchView isDescendantOfView:self.reactView]) {
            return NO;
        }
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesBegan ----");

//    [self testQMUI];
}

/**
 * 分享文件
 */
- (void)shareFile {
    WXMediaMessage *message = [WXMediaMessage message];
    message.title           = @"App消息";
    message.description     = @"这种消息只有App自己才能理解，由App指定打开方式！";
    [message setThumbImage:[UIImage imageNamed:@"res2.jpg"]];

    WXAppExtendObject *ext = [WXAppExtendObject object];
    ext.extInfo            = @"<xml>extend info</xml>";
    ext.url                = @"http://www.qq.com";

    //      Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
    //      memset(pBuffer, 0, BUFFER_SIZE);
    //      NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
    //      free(pBuffer);

    ext.fileData        = [NSData data];
    message.mediaObject = ext;

    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText               = NO;
    req.message             = message;
    req.scene               = WXSceneSession;

    [WXApi sendReq:req
        completion:^(BOOL success){

        }];
}

- (void)update {
    CATransform3D trans3d = {
        0, 0, 1, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0};

    CATransform3D transform = CATransform3DIdentity;
    transform               = CATransform3DRotate(transform, self.scale, 0, 1, 0);
    //    transform = CATransform3DRotate(transform, self.scale * 1 / 100, 1, 0, 0);
    //    transform = CATransform3DRotate(transform, self.scale * 1 / 100, 0, 0, 1);

    //    self.view.layer.sublayerTransform = transform;
    //    self.ballView.layer.sublayerTransform = transform;

    self.ballView.layer.sublayerTransform = transform;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    UIView *view               = [[UIView alloc] init];
    view.layer.shouldRasterize = YES;
    return NO;
}

// Ping主线程
//- (void)main {
//    //判断是否需要上报
//   __weak typeof(self) weakSelf = self;
//    void (^ verifyReport)(void) = ^() {
//        __strong typeof(weakSelf) strongSelf = weakSelf;
//        if (strongSelf.reportInfo.length > 0) {
//            if (strongSelf.handler) {
//                double responseTimeValue = floor([[NSDate date] timeIntervalSince1970] * 1000);
//                double duration = responseTimeValue - strongSelf.startTimeValue;
//                if (DEBUG) {
//                    NSLog(@"卡了%f,堆栈为--%@", duration, strongSelf.reportInfo);
//                }
//                strongSelf.handler(@{
//                 @"title": @"",
//                 @"duration": [NSString stringWithFormat:@"%.2f",duration],
//                 @"content": strongSelf.reportInfo
//                });
//            }
//            strongSelf.reportInfo = @"";
//        }
//    };
//
//     while (!self.cancelled) {
//         if (_isApplicationInActive) {
//             self.mainThreadBlock = YES;
//             self.reportInfo = @"";
//             self.startTimeValue = floor([[NSDate date] timeIntervalSince1970] * 1000);
//             dispatch_async(dispatch_get_main_queue(), ^{
//                 self.mainThreadBlock = NO;
//                 dispatch_semaphore_signal(self.semaphore);
//             });
//             [NSThread sleepForTimeInterval:(self.threshold/1000)];
//             if (self.isMainThreadBlock) {
//                 self.reportInfo = [InsectBacktraceLogger insect_backtraceOfMainThread];
//             }
//             dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
//             //卡顿超时情况;
//             verifyReport();
//         } else {
//             [NSThread sleepForTimeInterval:(self.threshold/1000)];
//         }
//     }
// }

- (CALayer *)layerAtX:(CGFloat)x
                    y:(CGFloat)y
                    z:(CGFloat)z
                color:(UIColor *)color
            transform:(CATransform3D)transform {
    CALayer *layer        = [CALayer layer];
    layer.backgroundColor = color.CGColor;
    layer.bounds          = CGRectMake(0, 0, 100, 100);
    layer.position        = CGPointMake(x, y);
    layer.zPosition       = z;
    layer.transform       = transform;
    [self.contentLayer addSublayer:layer];
    return layer;
}

- (void)createCircleCenter:(CGPoint)center
                    radius:(CGFloat)radius
                         z:(CGFloat)z
                 transform:(CATransform3D)transform {
    CAShapeLayer *shape = [CAShapeLayer layer];
    UIBezierPath *path  = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:(2 * M_PI) clockwise:YES];
    [path moveToPoint:center];
    shape.path      = path.CGPath;
    shape.fillColor = [[self class] randomColor].CGColor;
    shape.zPosition = z;
    shape.transform = transform;
    [self.imageContentLayer addSublayer:shape];
}

// 随机颜色
+ (UIColor *)randomColor {
    CGFloat r = arc4random_uniform(256);
    CGFloat g = arc4random_uniform(256);
    CGFloat b = arc4random_uniform(256);
    return [[self class] colorWithR:r g:g b:b a:1];
}

+ (UIColor *)colorWithR:(NSInteger)r g:(NSInteger)g b:(NSInteger)b a:(CGFloat)a {
    float red   = r / 255.0;
    float green = g / 255.0;
    float blue  = b / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:a];
}

- (void)testQMUI {
    @pas_weakify_self
        QMUIAlertAction *action1 = [QMUIAlertAction
            actionWithTitle:@"取消"
                      style:QMUIAlertActionStyleCancel
                    handler:^(__kindof QMUIAlertController *_Nonnull aAlertController, QMUIAlertAction *_Nonnull action) {
                        @pas_strongify_self
                            QMUITips *tips = [QMUITips showWithText:@"取消"];
                        tips.toastPosition = QMUIToastViewPositionTop;
                        NSLog(@"取消");
                    }];
    QMUIAlertAction *action2     = [QMUIAlertAction
        actionWithTitle:@"删除"
                  style:QMUIAlertActionStyleDestructive
                handler:^(__kindof QMUIAlertController *_Nonnull aAlertController,
                          QMUIAlertAction *_Nonnull action) {
                    [QMUITips showSucceed:@"删除"];
                    NSLog(@"删除");
                }];

    QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"确定删除？" message:@"删除后将无法恢复，请慎重考虑" preferredStyle:QMUIAlertControllerStyleAlert];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController showWithAnimated:YES];
}

@end
