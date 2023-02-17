//
//  MMPickerControl.m
//  MMBaseComponent
//
//  Created by Zhiwei Han on 2023/1/28.
//

#import "MMPickerControl.h"
#import "MMPickerView.h"

@interface MMPickerControl ()

@property (nonatomic, strong) UIView *backgroundVc;

@property (nonatomic, strong) MMPickerView *picker;

@end

@implementation MMPickerControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    [self addSubview:self.backgroundVc];
    [self addSubview:self.picker];
}

+ (void)showAnimation:(NSDictionary *)param confirmHander:(ConfirmAction)confirm cancelHander:(CancelAction)cancel {
    NSDictionary *data = [param objectForKey:@"data"];
    NSString *dateType = [data objectForKey:@"dateType"];

    MMPickerControl *control = [[MMPickerControl alloc] initWithFrame:CGRectMake(0, 0, MM_MainScreenWidth, MM_MainScreenHeight)];

    [control setCancelHander:^{
        MM_BlockSafeRun(cancel);
    }];

    [control setConfirmHander:^(NSDictionary *_Nonnull value) {
        MM_BlockSafeRun(confirm, value);
    }];

    [[UIApplication eh_displayViewController].view addSubview:control];

    control.backgroundVc.frame = CGRectMake(0, 0, MM_MainScreenWidth, MM_MainScreenHeight);
    control.picker.frame       = CGRectMake(0, MM_MainScreenHeight, MM_MainScreenWidth, 256);
    control.backgroundVc.alpha = 0;

    if ([dateType isEqualToString:@"date"]) {
        control.picker.type = MMPickerFormatterStyleDefault;
    } else if ([dateType isEqualToString:@"datetime"]) {
        control.picker.type = MMPickerFormatterStyleLongTime;
    } else if ([dateType isEqualToString:@"time"]) {
        control.picker.type = MMPickerFormatterStyleTime;
    } else if ([dateType isEqualToString:@"dateYearMonth"]) {
        control.picker.type = MMPickerFormatterStyleMonth;
    }

    [UIView animateWithDuration:0.4f animations:^{
        control.backgroundVc.alpha = 0.6;
        control.picker.frame       = CGRectMake(0, MM_MainScreenHeight - 256, MM_MainScreenWidth, 256);
    }];
}

- (void)dismissAnimation {
    [UIView animateWithDuration:0.4f animations:^{
        self.backgroundVc.alpha = 0;
        self.picker.frame       = CGRectMake(0, MM_MainScreenHeight, MM_MainScreenWidth, 256);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)backgroundAction {
    MM_BlockSafeRun(self.cancelHander);
    [self dismissAnimation];
}

#pragma mark

- (void)cancelForPic {
    MM_BlockSafeRun(self.cancelHander);
    [self dismissAnimation];
}

- (void)sureForPic:(NSDictionary *)value {
    MM_BlockSafeRun(self.confirmHander, value);
    [self dismissAnimation];
}

#pragma mark lazyLoad

- (UIView *)backgroundVc {
    if (!_backgroundVc) {
        _backgroundVc                        = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MM_MainScreenWidth, MM_MainScreenHeight)];
        _backgroundVc.backgroundColor        = [UIColor blackColor];
        _backgroundVc.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap          = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:self action:@selector(backgroundAction)];
        [_backgroundVc addGestureRecognizer:tap];
    }
    return _backgroundVc;
}

- (MMPickerView *)picker {
    if (!_picker) {
        _picker                  = [[MMPickerView alloc] initWithFrame:CGRectMake(0, MM_MainScreenHeight, MM_MainScreenWidth, 256)];
        _picker.delegate         = self;
        _picker.hasConfirmButton = YES;
        _picker.backgroundColor  = [UIColor whiteColor];
        [_picker configComplete];
    }
    return _picker;
}

@end
