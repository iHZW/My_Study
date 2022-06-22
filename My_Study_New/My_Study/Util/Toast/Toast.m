//
//  Toast.m
//  StarterApp
//
//  Created by js on 2019/6/24.
//  Copyright © 2019 js. All rights reserved.
//

#import "Toast.h"
#import "UIApplication+Ext.h"
#import "UIColor+Ext.h"
#import "LogUtil.h"

#define kMinWidth 70
#define kMinHeight 20
#define kMaxWidth [Toast maxWidth]

@interface Toast ()

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic ,strong) UILabel * alertTitle;

@property (nonatomic ,assign) NSInteger numberOfLines;
@property (nonatomic, copy) NSString *title;
@property (nonatomic ,assign) ToastPosition toastPosition;
@property (nonatomic, assign) CGFloat adjustY;

@property (nonatomic, assign,readwrite) BOOL isCanceled;
@end

@implementation Toast

+ (Toast *)show:(NSString *)msg{
    return [self show:msg adjustY:0 inView:nil];
}

+ (Toast *)show:(NSString *)msg adjustY:(CGFloat)adjustY inView:(UIView *)superView{
    return [self show:nil msg:msg numberOfLines:0 duration:1.5 position:ToastPositionTop adjustY:adjustY inView:superView willShow:nil finish:nil];
}

+ (Toast *)showBlueToast:(nullable UIImage *)icon msg:(nullable NSString *)msg{
    Toast *toast = [Toast show:icon msg:msg numberOfLines:1 duration:1.5 position:ToastPositionTop adjustY:0 inView:nil willShow:nil finish:nil];
//    toast.backgroundColor = [UIColor colorFromHexCode:@"#4F7AFD"];
//    toast.alpha = 0.84;
//    toast.layer.cornerRadius = 8;
//    toast.layer.shadowColor = [[UIColor colorFromHexCode:@"#4F7AFD"] colorWithAlphaComponent:0.25].CGColor;
//    toast.layer.shadowOffset = CGSizeMake(0,5);
//    toast.layer.shadowOpacity = 1;
//    toast.layer.shadowRadius = 20;
    return toast;
}

+ (Toast *)show:(NSString *)msg
  numberOfLines:(NSInteger)numberOfLines
    duration:(NSTimeInterval)duration
    position:(ToastPosition)position
     adjustY:(CGFloat)adjustY
    willShow:(nullable ToastBlock)showBlock
      finish:(nullable ToastBlock)finishBlock{
    return [self show:msg numberOfLines:numberOfLines  duration:duration position:position adjustY:adjustY inView:nil willShow:showBlock finish:finishBlock];
}

+ (Toast *)show:(NSString *)message
  numberOfLines:(NSInteger)numberOfLines
    duration:(NSTimeInterval)duration
    position:(ToastPosition)position
     adjustY:(CGFloat)adjustY
      inView:(nullable UIView *)parentView
    willShow:(nullable ToastBlock)showBlock
      finish:(nullable ToastBlock)finishBlock{
    
    return [self show:nil msg:message numberOfLines:numberOfLines duration:duration position:position adjustY:adjustY inView:parentView willShow:showBlock finish:finishBlock];
}

+ (Toast *)show:(nullable UIImage *)icon
            msg:(NSString *)message
  numberOfLines:(NSInteger)numberOfLines
duration:(NSTimeInterval)duration
position:(ToastPosition)position
 adjustY:(CGFloat)adjustY
  inView:(nullable UIView *)parentView
willShow:(nullable ToastBlock)showBlock
         finish:(nullable ToastBlock)finishBlock{
    if ((![message isKindOfClass:[NSString class]] || message.length <= 0) && icon == nil) {
           return nil;
       }
       
       if (duration <= 0){
           duration = 1.5;
       }
       
       if (parentView == nil){
           parentView = [UIApplication displayWindow];
       }

       if (adjustY == 0){
           switch (position) {
               case ToastPositionTop:
                   adjustY = 113;
                   break;
               case ToastPositionBottom:
                   adjustY = -60;
                   break;
               default:
                   adjustY = 0;
                   break;
           }
       }
      
       Toast * toast = [[Toast alloc] init];
        toast.numberOfLines = numberOfLines;
        toast.backgroundColor = [UIColor colorFromHexCode:@"#4F7AFD"];
        toast.alpha = 0.84;
        toast.layer.cornerRadius = 8;
        toast.layer.shadowColor = [[UIColor colorFromHexCode:@"#4F7AFD"] colorWithAlphaComponent:0.25].CGColor;
        toast.layer.shadowOffset = CGSizeMake(0,5);
        toast.layer.shadowOpacity = 1;
        toast.layer.shadowRadius = 20;
       [parentView addSubview:toast];
       [toast configData:icon msg:message postion:position adjustY:adjustY];
       // 模态化页面取不到最上层的viewcontroller,所以暂时放window上
      
       BlockSafeRun(showBlock,toast);
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           CGPoint center = toast.center;
           [UIView animateWithDuration:0.3 animations:^{
               toast.center = CGPointMake(center.x, center.y - 60);
               toast.alpha = 0;
           } completion:^(BOOL finished) {
               [toast removeFromSuperview];
           }];
           
           BlockSafeRun(finishBlock,toast);
       });
       return toast;
}

- (instancetype)init{
    if (self = [super init]) {
        [self defaultConfig];
        [self initViews];
    }
    return self;
}

+ (CGFloat)maxWidth{
    return kMainScreenWidth - 100;
}

- (void)setNumberOfLines:(NSInteger)numberOfLines{
    _numberOfLines = numberOfLines;
    _alertTitle.numberOfLines = numberOfLines;
}

- (void)defaultConfig{
    self.backgroundColor = [UIColor colorFromHexCode:@"#000000"];
    self.alpha = 0.7;
    self.layer.cornerRadius = 6;
    self.clipsToBounds = NO;
}

- (void)initViews{
    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_iconImageView];
    
    _alertTitle = [[UILabel alloc]init];
    _alertTitle.numberOfLines = self.numberOfLines;
    _alertTitle.textAlignment = NSTextAlignmentCenter;
    _alertTitle.font = [UIFont systemFontOfSize:14];
    _alertTitle.textColor = [UIColor colorFromHexCode:@"#FFFFFF"];
    _alertTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:_alertTitle];
}

- (void)configData:(UIImage *)icon msg:(NSString *)msg postion:(ToastPosition)toastPosition adjustY:(CGFloat)adjustY{
    self.icon = icon;
    self.title = msg;
    self.toastPosition = toastPosition;
    self.adjustY = adjustY;
    
    
    _iconImageView.image = self.icon;
    _alertTitle.text = self.title;
    
    
    CGSize alertSize = [_alertTitle sizeThatFits:CGSizeMake(kMaxWidth, MAXFLOAT)];
    
    
    if (alertSize.width <= kMinWidth) {
        alertSize = CGSizeMake(kMinWidth, 20);
    }
    
    if (alertSize.height <= kMinHeight) {
        alertSize = CGSizeMake(alertSize.width, kMinHeight);
    }
    
    if (self.numberOfLines == 1 && alertSize.width > kMaxWidth){
        alertSize = CGSizeMake(kMaxWidth, 20);
    }
    
    if (self.icon){
        self.iconImageView.frame = CGRectMake(16.5, 12, 18, 18);
        _alertTitle.frame = CGRectMake(16.5 + 18 + 8, 12, alertSize.width, alertSize.height);
        self.frame = CGRectMake(0, 0, alertSize.width + 33 + 18 + 8, alertSize.height + 24);
    } else {
        _alertTitle.frame = CGRectMake(16.5, 12, alertSize.width, alertSize.height);
        self.frame = CGRectMake(0, 0, alertSize.width + 33, alertSize.height + 24);
    }
    
    
    CGPoint center = [self toastCenter:alertSize.height + 24];
    self.center = CGPointMake(center.x, center.y - 60);
    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.center = center;
        self.alpha = 1;
    }];
    
//
//    [self setNeedsLayout];
//    [self layoutIfNeeded];
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    
}

- (CGFloat)topMargin{
    if (@available(iOS 11.0, *)) {
       return self.safeAreaInsets.top;
    }
    return 0;
}

- (CGFloat)bottomMargin{
    if (@available(iOS 11.0, *)) {
        return self.safeAreaInsets.bottom;
    }
    return 0;
}

- (CGFloat)parentViewHeight{
    CGFloat minusY = [self topMargin] + [self bottomMargin];
    return CGRectGetHeight(self.superview.frame) - minusY;
}

- (CGFloat)parentViewWidth{
    return CGRectGetWidth(self.superview.frame);
}

- (CGPoint)toastCenter:(CGFloat)toastHeight{
    CGPoint center = CGPointZero;
    
    switch (self.toastPosition) {
        case ToastPositionTop:
             center = CGPointMake([self parentViewWidth] / 2,[self topMargin]);
            break;
        case ToastPositionBottom:
            center = CGPointMake([self parentViewWidth] / 2,[self parentViewHeight] - toastHeight);
        default:
            break;
    }
    
    if (CGPointEqualToPoint(center, CGPointZero)){
        center = CGPointMake([self parentViewWidth] / 2, [self parentViewHeight] / 2);
    }
    
    center = CGPointMake(center.x, center.y + self.adjustY);
    
    return center;
}

- (void)dealloc{
    [LogUtil debug:@"Toast释放" flag:self.title context:self];
}


- (void)cancel{
    self.isCanceled = YES;
    [self removeFromSuperview];
}

@end
