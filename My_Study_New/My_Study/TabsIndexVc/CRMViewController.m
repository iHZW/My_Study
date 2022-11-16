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

@interface CRMViewController ()

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@property (nonatomic, copy) NSString *reportInfo;

@property (nonatomic, copy) HandleBlock handler;

@property (nonatomic, assign) BOOL cancelled;

@property (nonatomic, strong) UIView *ballView;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) CGFloat scale;

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGFloat heightTag;

/**底部容器*/
@property (nonatomic, strong) CATransformLayer *contentLayer;
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

    //    [self loadTime];

    //    [self loadIconImage];
}

- (void)loadBallView {
    self.ballView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [self.view addSubview:self.ballView];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.ballView addGestureRecognizer:pan];

    // 创建CATransformLayer对象
    CATransformLayer *contentLayer = [CATransformLayer layer];
    contentLayer.frame             = self.ballView.layer.bounds;
    self.imageContentLayer         = contentLayer;
    [self.ballView.layer addSublayer:self.imageContentLayer];

    CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.ballView.bounds), CGRectGetMidY(self.ballView.bounds));

    CGPoint centerxPoint = centerPoint;

    for (int i = 0; i < 100; i++) {
        // 使用勾股定理 计算圆的半径,
        CGFloat radius = sqrt(powl(50.0, 2) - powl(i * 0.5, 2));

        /** z轴正半轴  画圆  */
        [self createCircleCenter:centerPoint radius:radius z:i * 0.5 transform:CATransform3DIdentity];

        /** z轴负半轴  画圆  */
        [self createCircleCenter:centerPoint radius:radius z:-i * 0.5 transform:CATransform3DIdentity];

        //        /** x轴正半轴  画圆  */
        //        [self createCircleCenter:CGPointMake(-centerPoint.x,centerPoint.y) radius:radius z:i*0.5 transform:CATransform3DMakeRotation(M_PI_2, 0, 1, 0)];
        //        /** x轴正半轴  画圆  */
        //        [self createCircleCenter:CGPointMake(-centerPoint.x,centerPoint.y) radius:radius z:-i*0.5 transform:CATransform3DMakeRotation(M_PI_2, 0, 1, 0)];

        //        /** y轴正半轴  画圆  */
        //        [self createCircleCenter:CGPointMake(centerPoint.x, centerPoint.y + i*0.5) radius:radius z:0 transform:CATransform3DMakeRotation(M_PI_2, 1, 0, 0)];
        //        /** y轴正半轴  画圆  */
        //        [self createCircleCenter:CGPointMake(centerPoint.x, centerPoint.y - i*0.5) radius:radius z:0 transform:CATransform3DMakeRotation(M_PI_2, 1, 0, 0)];
    }
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
    // 创建CATransformLayer对象
    CATransformLayer *contentLayer = [CATransformLayer layer];
    contentLayer.frame             = self.view.layer.bounds;
    CGSize size                    = contentLayer.bounds.size;
    contentLayer.transform         = CATransform3DMakeTranslation(size.width / 2, size.height / 2, 0);
    self.contentLayer              = contentLayer;
    [self.view.layer addSublayer:contentLayer];
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
    [self.view addGestureRecognizer:pan];
}

- (void)pan:(UIPanGestureRecognizer *)recognizer {
    NSString *objectTag = recognizer.objectTag;

    if ([objectTag isEqualToString:@"2"]) {
        // 获取到的是手指移动后，在相对坐标中的偏移量(以手指接触屏幕的第一个点为坐标原点)
        CGPoint translation               = [recognizer translationInView:self.view];
        CATransform3D transform           = CATransform3DIdentity;
        transform                         = CATransform3DRotate(transform, translation.x * 1 / 100, 0, 1, 0);
        transform                         = CATransform3DRotate(transform, translation.y * 1 / 100, 1, 0, 0);
        self.view.layer.sublayerTransform = transform;
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesBegan ----");

    [self testQMUI];
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
