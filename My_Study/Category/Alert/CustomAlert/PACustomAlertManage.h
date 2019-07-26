//
//  PACustomAlertManage.h
//  TZYJ_IPhone
//
//  Created by vincent  on 15/7/14.
//
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CustomAlertVerticalCenter,
    CustomAlertVerticalTop,
    CustomAlertVerticalBottom,
} CustomAlertVerticalType;

typedef void (^TapBlock)(void);
@interface PACustomAlertManage : UIControl

@property (nonatomic, assign) BOOL bolNoHaveBgEvent;
//弹出keywindow上
- (void)showInView;
//弹出到指定view
- (void)showInView:(UIView *)inView;
- (void)dismissView;
- (void)dimissViewWithBlock:(TapBlock)block;

/**
 * 带灰底的弹出view
 *
 *  @param view   需要在屏幕中间显示的view
 *  @param isShow 灰底是否覆盖顶部导航，NO覆盖，YES,不覆盖
 *
 *  @return 整个view
 */
+ (UIView *)showAlertView:(UIView *)view
              bolShowNav:(BOOL)isShow
                 offseth:(NSInteger)offseth;


//bgcolor背景色值，alpha 透明度
+ (UIView *)showAlertView:(UIView *)view
              bolShowNav:(BOOL)isShow
                 bgcolor:(UIColor *)bgColor
                 bgAlpha:(float)alpha;

/**
 *  弹出背景框
 *
 *  @param view           想要加在上层的view
 *  @param isShow         是否显示导航 yes显示， no不显示
 *  @param bgColor        背景颜色
 *  @param alpha          底透明度
 *  @param offseth        偏移量
 *  @param bolHaveBgEvent 底部半透明是否有点击事件，yes有
 *
 *  @return 整个弹出view
 */
+ (UIView *)showAlertView:(UIView *)view
               bolShowNav:(BOOL)isShow
                  bgcolor:(UIColor *)bgColor
                  bgAlpha:(float)alpha
                  offseth:(NSInteger)offseth
           bolHaveBgEvent:(BOOL)bolHaveBgEvent;

+ (UIView *)showAlertView:(UIView *)view
               bolShowNav:(BOOL)isShow
                  offseth:(NSInteger)offseth
           bolHaveBgEvent:(BOOL)bolHaveBgEvent;

+ (UIView *)showCoverWithFrame:(CGRect)frame tapBlock:(TapBlock)tapBlock;

/**
 *  弹出背景框
 *
 *  @param view           想要加在上层的view
 *  @param isShow         是否显示导航 yes显示， no不显示
 *  @param bgColor        背景颜色
 *  @param alpha          底透明度
 *  @param offseth        向上偏移量
 *  @param bolHaveBgEvent 底部半透明是否有点击事件，yes有
 *  @param inview          指定的view
 *  @return 整个弹出view
 */
+ (UIView *)showAlertView:(UIView *)view
               bolShowNav:(BOOL)isShow
                  bgcolor:(UIColor *)bgColor
                  bgAlpha:(float)alpha
                  offseth:(NSInteger)offseth
           bolHaveBgEvent:(BOOL)bolHaveBgEvent
                   inView:(UIView *)inview;


/**
 *  弹出背景框
 *
 *  @param view           想要加在上层的view
 *  @param isShow         是否显示导航 yes显示， no不显示
 *  @param bgColor        背景颜色
 *  @param alpha          底透明度
 *  @param offseth        向上偏移量
 *  @param bolHaveBgEvent 底部半透明是否有点击事件，yes有
 *  @param inview          指定的view
 *  @prarm verticalType    顶中底，默认中
 *  @return 整个弹出view
 */
+ (UIView *)showAlertView:(UIView *)view
               bolShowNav:(BOOL)isShow
                  bgcolor:(UIColor *)bgColor
                  bgAlpha:(float)alpha
                  offseth:(NSInteger)offseth
           bolHaveBgEvent:(BOOL)bolHaveBgEvent
            alertVertical:(CustomAlertVerticalType)verticalType
                   inView:(UIView *)inview;

- (void)removeAction;
@end
