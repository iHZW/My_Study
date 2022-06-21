//
//  URLProtocolHelper.m
//  WMOA
//
//  Created by fhkvsou on 2019/1/28.
//  Copyright © 2019年 weimob. All rights reserved.
//
#if APPLOGOPEN

#import "DebugLogHelper.h"
#import <objc/runtime.h>
//#import "DebugURLProtocol.h"
#import "MDLogViewController.h"
#import "MDDebugViewController.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface DebugLogHelper ()

@end

@implementation DebugLogHelper

+ (DebugLogHelper *)shared{
    static DebugLogHelper * helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper=[[DebugLogHelper alloc] init];
    });
    return helper;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isSwizzle = NO;
    }
    return self;
}

- (void)initLogBtn{
    self.logButton = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth - 60, kScreenHeight - 200, 60, 60)];
    [self.logButton addTarget:self action:@selector(logBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.logButton setTitle:@"开发" forState:UIControlStateNormal];
    
    self.logButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.logButton setBackgroundColor:[UIColor blackColor]];
    self.logButton.alpha = 0.5;
    self.logButton.layer.cornerRadius = 30;
    self.logButton.layer.masksToBounds = YES;
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.logButton];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.logButton];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(changePostion:)];
    [self.logButton addGestureRecognizer:pan];
}

-(void)changePostion:(UIPanGestureRecognizer *)pan{
    CGPoint point = [pan translationInView:self.logButton];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGRect originalFrame = self.logButton.frame;
    if (originalFrame.origin.x >= 0 && originalFrame.origin.x+originalFrame.size.width <= width) {
        originalFrame.origin.x += point.x;
        
    }if (originalFrame.origin.y >= 0 && originalFrame.origin.y+originalFrame.size.height <= height) {
        originalFrame.origin.y += point.y;
    }
    self.logButton.frame = originalFrame;
    
    [pan setTranslation:CGPointZero inView:self.logButton];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.logButton.enabled = NO;
    }else if (pan.state == UIGestureRecognizerStateChanged){
        
    } else {CGRect frame = self.logButton.frame;//是否越界
        BOOL isOver = NO;
        if (frame.origin.x < 0) {
            frame.origin.x = 0;isOver = YES;
        } else if (frame.origin.x+frame.size.width > width) {
            frame.origin.x = width - frame.size.width;isOver = YES;
        }if (frame.origin.y < 0) {
            frame.origin.y = 0;isOver = YES;
        } else if (frame.origin.y+frame.size.height > height) {
            frame.origin.y = height - frame.size.height;
            isOver = YES;
        }if (isOver) {
            [UIView animateWithDuration:0.3 animations:^{
                self.logButton.frame = frame;
            }];
        }
        self.logButton.enabled = YES;
    }
}
    

- (void)logBtnClick{
    
    MDDebugViewController *vc = [[MDDebugViewController alloc] init];
    
//    MDLogViewController *vc = [[MDLogViewController alloc] init];
//    vc.forceDisableBackGesture = YES;
    [[[UIApplication displayViewController] navigationController] pushViewController:vc animated:YES];
    [DebugLogHelper shared].logButton.hidden = YES;
}

- (void)addLogButton{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self initLogBtn];
    });
}

//- (void)load {
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self initLogBtn];
//    });
//    
//    self.isSwizzle=YES;
//    Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
//    [self swizzleSelector:@selector(protocolClasses) fromClass:cls toClass:[self class]];
//    
//}
//
//- (void)unload {
//    self.isSwizzle=NO;
//    Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
//    [self swizzleSelector:@selector(protocolClasses) fromClass:cls toClass:[self class]];
//}
//
//- (void)swizzleSelector:(SEL)selector fromClass:(Class)original toClass:(Class)stub {
//    Method originalMethod = class_getInstanceMethod(original, selector);
//    Method stubMethod = class_getInstanceMethod(stub, selector);
//    if (!originalMethod || !stubMethod) {
//        [NSException raise:NSInternalInconsistencyException format:@"Couldn't load NEURLSessionConfiguration."];
//    }
//    method_exchangeImplementations(originalMethod, stubMethod);
//}
//
//- (NSArray *)protocolClasses {
//    // 如果还有其他的监控protocol，也可以在这里加进去
//    return @[[DebugURLProtocol class]];
//}
//
//- (void)dealloc{
//}

@end
#endif
