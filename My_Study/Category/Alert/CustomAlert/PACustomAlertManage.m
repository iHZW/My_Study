//
//  PACustomAlertManage.m
//  TZYJ_IPhone
//
//  Created by vincent  on 15/7/14.
//
//

#import "PACustomAlertManage.h"
#import "UIViewCategory.h"
#import "UIGestureRecognizer+Block.h"


@implementation PACustomAlertManage

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addTarget:self action:@selector(action_disMiss:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)removeAction{
     [self removeTarget:self action:@selector(action_disMiss:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)action_disMiss:(UIControl *)control
{
    if (self.bolNoHaveBgEvent) {
        return;
    }
    @synchronized(self)
    {
        [self dismissView];
    }
    
}
- (void)dismissView
{
    [self dimissViewWithBlock:nil];
}

- (void)dimissViewWithBlock:(TapBlock)block{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (block) {
            block();
        }
    }];
}


- (void)showInView:(UIView *)inView
{
    if (inView)
        [inView addSubview:self];
    else
        [self showInView];
    
}

- (void)showInView
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
//    [UIView animateWithDuration:0.2 animations:^{
//        self.alpha = 1.0;
//    }];
}

+ (UIView *)showAlertView:(UIView *)view
               bolShowNav:(BOOL)isShow
                  bgcolor:(UIColor *)bgColor
                  bgAlpha:(float)alpha
                    offseth:(NSInteger)offseth
           bolHaveBgEvent:(BOOL)bolHaveBgEvent
                   inView:(UIView *)inview
{
    
    CGRect tempFrame = [[UIScreen mainScreen] bounds];
    
    if (inview) {
        tempFrame = inview.bounds;
    }
    
    tempFrame.origin.y = isShow?(64):0;
    tempFrame.size.height -= CGRectGetMinY(tempFrame);
    PACustomAlertManage *alert = [[PACustomAlertManage alloc] initWithFrame:tempFrame];
    alert.backgroundColor = [UIColor clearColor];
    alert.bolNoHaveBgEvent = !bolHaveBgEvent;
    
    UIView *bottomView = [alert buildView:alert.bounds bgColor:bgColor];
    bottomView.alpha = alpha;
    bottomView.userInteractionEnabled = NO;
    
    CGRect viewFrame = view.frame;
    viewFrame.origin.x = (tempFrame.size.width-viewFrame.size.width)/2.0;
    viewFrame.origin.y = (tempFrame.size.height - viewFrame.size.height)/2.0-offseth;
    view.frame = viewFrame;
    
    if (view) {
        [alert addSubview:view];
    }
    
    [alert showInView:inview];
    return alert;
}

+ (UIView *)showAlertView:(UIView *)view
               bolShowNav:(BOOL)isShow
                  bgcolor:(UIColor *)bgColor
                  bgAlpha:(float)alpha
                  offseth:(NSInteger)offseth
           bolHaveBgEvent:(BOOL)bolHaveBgEvent
            alertVertical:(CustomAlertVerticalType)verticalType
                   inView:(UIView *)inview
{
    UIView *alert = [self showAlertView:view bolShowNav:isShow bgcolor:bgColor bgAlpha:alpha offseth:offseth bolHaveBgEvent:bolHaveBgEvent inView:inview];
    CGFloat ypoint = view.y;
    switch (verticalType) {
        case CustomAlertVerticalTop:
            ypoint = 0 - offseth;
            break;
        case CustomAlertVerticalBottom:
            ypoint = alert.height - view.height - offseth;
            break;
            
        default:
            break;
    }
    
    view.y = ypoint;
    return alert;
}

+ (UIView *)showAlertView:(UIView *)view
               bolShowNav:(BOOL)isShow 
                  bgcolor:(UIColor *)bgColor
                  bgAlpha:(float)alpha
                  offseth:(NSInteger)offseth
           bolHaveBgEvent:(BOOL)bolHaveBgEvent
{
    return [PACustomAlertManage showAlertView:view bolShowNav:isShow bgcolor:bgColor bgAlpha:alpha offseth:offseth bolHaveBgEvent:bolHaveBgEvent inView:nil];
}

+ (UIView *)showAlertView:(UIView *)view
              bolShowNav:(BOOL)isShow
                 bgcolor:(UIColor *)bgColor
                 bgAlpha:(float)alpha
{
    return [PACustomAlertManage showAlertView:view bolShowNav:isShow bgcolor:bgColor bgAlpha:alpha offseth:0 bolHaveBgEvent:YES];
}

+ (UIView *)showAlertView:(UIView *)view
               bolShowNav:(BOOL)isShow
                  bgcolor:(UIColor *)bgColor
                  bgAlpha:(float)alpha
                  offseth:(NSInteger)offseth
{
    return [self showAlertView:view bolShowNav:isShow bgcolor:bgColor bgAlpha:alpha offseth:offseth bolHaveBgEvent:YES];
}

+ (UIView *)showAlertView:(UIView *)view
               bolShowNav:(BOOL)isShow
                  offseth:(NSInteger)offseth
{
    return [PACustomAlertManage showAlertView:view bolShowNav:isShow bgcolor:[UIColor blackColor] bgAlpha:0.7 offseth:offseth];
}

+ (UIView *)showAlertView:(UIView *)view
              bolShowNav:(BOOL)isShow
                 offseth:(NSInteger)offseth
          bolHaveBgEvent:(BOOL)bolHaveBgEvent
{
//    return [PACustomAlertManage showAlertView:view bolShowNav:isShow bgcolor:[UIColor blackColor] bgAlpha:0.7 offseth:offseth];
    return [PACustomAlertManage showAlertView:view bolShowNav:isShow bgcolor:[UIColor blackColor] bgAlpha:0.6 offseth:offseth bolHaveBgEvent:bolHaveBgEvent];
}

+ (UIView *)showCoverWithFrame:(CGRect)frame tapBlock:(TapBlock)tapBlock{
    UIView *conver = [[UIView alloc] initWithFrame:frame];
    conver.backgroundColor = UIColorFromRGB(0x000000);
    conver.alpha = 0.4;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id obj) {
        if (tapBlock) {
            tapBlock();
        }
    }];
    [conver addGestureRecognizer:gesture];
    
    return conver;
}

@end
