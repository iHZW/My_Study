//
//  ZWColorPickInfoWindow.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/13.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWColorPickInfoWindow.h"
#import "ZWColorPickInfoView.h"
#import "NSTimer+SJAssetAdd.h"
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

@interface ZWColorPickInfoController : UIViewController


@end


@implementation ZWColorPickInfoController

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.view.window.frame = CGRectMake(30, kMainScreenHeight - (size.height < size.width ? size.height : size.width) - 30, size.height, size.width);
    });
}

/** 默认不支持旋转  */
- (BOOL)shouldAutorotate
{
    return YES;
}

/** 默认竖屏  */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

/** 默认竖屏  */
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end


@interface ZWColorPickInfoWindow ()<ZWColorPickInfoViewDelegate>

@property (nonatomic, strong) ZWColorPickInfoView *pickInfoView;

@property (nonatomic, strong, nullable) NSTimer *cycleTimer;

@property (nonatomic, copy) NSString *titleName;

@property (nonatomic, assign) NSInteger count;
@end

@implementation ZWColorPickInfoWindow

+ (instancetype)shareInstance
{
    static ZWColorPickInfoWindow *mamager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mamager = [[ZWColorPickInfoWindow alloc] init];
    });
    return mamager;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.titleName = @"";
        self.frame = CGRectMake(30, kMainNavHeight+kSysStatusBarHeight + 60, kMainScreenWidth - 60, 80);
        
        #if defined(__IPHONE_13_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
            if (@available(iOS 13.0, *)) {
                for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes){
                    if (windowScene.activationState == UISceneActivationStateForegroundActive){
                        self.windowScene = windowScene;
                        break;
                    }
                }
            }
        #endif
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelAlert;
        
        if (!self.rootViewController) {
            self.rootViewController = [[ZWColorPickInfoController alloc] init];
        }
        
        self.pickInfoView = [[ZWColorPickInfoView alloc] initWithFrame:self.bounds];
        self.pickInfoView.delegate = self;
        [self.rootViewController.view addSubview:self.pickInfoView];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self addGestureRecognizer:pan];
        
        [self sj_addObserver:self forKeyPath:@"titleName"];
        
    }
    return self;
}


- (void)showView
{
    self.hidden = NO;
    
    /** 启动定时器, 主要为了监听剪贴板值变化  */
    [self _refreshOrStop:NO];
}

- (void)hiddenView
{
    self.hidden = YES;
    [self _refreshOrStop:YES];
}

#pragma mark - 监听复制板内容变化
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"titleName"]) {
        BOOL isAble = [DataFormatterFunc isColorNum:self.titleName];
        if (self.titleName.length >= 3 && isAble) {
            [self.pickInfoView setCurrentColor:self.titleName];
        }
    }
}



#pragma mark - dealCopyString
- (void)dealCopyString
{
    UIPasteboard *tempUIPasteboard = [UIPasteboard generalPasteboard];
    if (tempUIPasteboard.changeCount != self.count) {
        self.count = tempUIPasteboard.changeCount;
        NSString *hexString = tempUIPasteboard.string;
        if ([hexString hasPrefix:@"#"]) {
            hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
        } else if ([hexString hasPrefix:@"0x"]) {
            hexString = [hexString stringByReplacingOccurrencesOfString:@"0x" withString:@""];
        }
        self.titleName = hexString;
    }
}


#pragma mark - ZWColorPickInfoViewDelegate
- (void)closeBtnAction:(id)sender view:(ZWColorPickInfoView *)view
{
    [self hiddenView];
}


#pragma mark - niubi
- (void)pan:(UIPanGestureRecognizer *)sender
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
    

#pragma mark - cycleTimer
- (void)_refreshOrStop:(BOOL)isStop {
    if (isStop) {
        if ( _cycleTimer != nil ) {
            [_cycleTimer invalidate];
            _cycleTimer = nil;
        }
    }
    else {
        if ( _cycleTimer == nil ) {
            __weak typeof(self) _self = self;
            _cycleTimer = [NSTimer sj_timerWithTimeInterval:0.5 repeats:YES usingBlock:^(NSTimer * _Nonnull timer) {
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                [self dealCopyString];
            }];
            [_cycleTimer sj_fire];
            [NSRunLoop.mainRunLoop addTimer:_cycleTimer forMode:NSRunLoopCommonModes];
        }
    }
}

@end
