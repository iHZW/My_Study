//
//  UIAlertUtil.h
//  TZYJ_IPhone
//
//  Created by Howard on 15/6/10.
//
//

#import <Foundation/Foundation.h>
#import "UIAlertView+Blocks.h"
#import "UIActionSheet+Blocks.h"

typedef void (^UIAlertViewVoidBlock)(void);
typedef void (^UIAlertViewTapBlock)(NSInteger index);

@interface UIAlertUtil : NSObject

#pragma mark - Alert common function
/**
 *  显示提示框，为兼容iPhone6&6+，需使用UIAlertController
 *
 *  @param title             标题
 *  @param message           消息内容
 *  @param cancelButtonTitle 取消标题
 *  @param otherButtonTitles 其他按钮集
 *  @param type              UIAlertControllerStyle(UIAlertControllerStyleActionSheet, UIAlertControllerStyleAlert)
 *  @param actionBlock       触发事件回调
 *  @param superVC           父视图控制器
 *
 *  @return 返回controller
 */
+ (id)showAlertTitle:(NSString *)title
             message:(NSString *)message
   cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitles:(NSArray *)otherButtonTitles
alertControllerStyle:(UIAlertControllerStyle)type
         actionBlock:(UIAlertViewTapBlock)actionBlock
             superVC:(UIViewController *)superVC    NS_AVAILABLE_IOS(8_0);

#pragma mark - Alert function
/**
 *  显示提示框，为兼容iPhone6&6+，需使用UIAlertController.
 *
 *  @param title             标题
 *  @param message           消息内容
 *  @param cancelButtonTitle 取消标题
 *  @param otherButtonTitles 其他按钮集
 *  @param cancelBlock       取消触发事件
 *  @param confirmBlock      其他按钮触发事件
 *  @param superVC           父视图控制器
 *  @return                  返回alertview或controller
 */
+ (id)showAlertTitle:(NSString *)title
             message:(NSString *)message
   cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitles:(NSArray *)otherButtonTitles
         cancelBlock:(UIAlertViewVoidBlock)cancelBlock
        confirmBlock:(UIAlertViewVoidBlock)confirmBlock
             superVC:(UIViewController *)superVC;

/**
 *  显示提示框，为兼容iPhone6&6+，需使用UIAlertController.
 *
 *  @param title             标题
 *  @param message           消息内容
 *  @param cancelButtonTitle 取消标题
 *  @param otherButtonTitles 其他按钮集
 *  @param actionBlock       触发事件回调
 *  @param superVC           父视图控制器
 *
 *  @return 返回alertview或controller
 */
+ (id)showAlertTitle:(NSString *)title
             message:(NSString *)message
   cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitles:(NSArray *)otherButtonTitles
         actionBlock:(UIAlertViewTapBlock)actionBlock
             superVC:(UIViewController *)superVC;

/**
 *  显示提示框，为兼容iPhone6&6+，需使用UIAlertController.
 *
 *  @param title             标题
 *  @param message           消息内容
 *  @param cancelButtonTitle 取消标题
 *  @param otherButtonTitles 其他按钮集
 *  @param textAlign         内容布局方式
 *  @param font             内容字体大小
 *  @param actionBlock       触发事件回调
 *  @param superVC           父视图控制器
 *
 *  @return 返回alertview或controller
 */
+ (id)showAlertTitle:(NSString *)title
             message:(NSString *)message
   cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitles:(NSArray *)otherButtonTitles
               align:(NSTextAlignment)textAlign
                font:(UIFont *)font
            msgColor:(UIColor *)msgColor
         actionBlock:(UIAlertViewTapBlock)actionBlock
             superVC:(UIViewController *)superVC;

/**
 *  隐藏指定的alert
 *
 *  @param alert   对应alert对象
 *  @param animate 是否动画展示
 */
+ (void)dismissAlert:(id)alert animate:(BOOL)animate;

/**
 更改alertcontroller布局
 */
+ (void)changeAlertControllerProperty:(UIAlertController *)alert
                                  msg:(NSString *)msg
                                align:(NSTextAlignment)align
                                color:(UIColor *)color
                                 font:(UIFont *)font;

#pragma mark - messageBox‘s compatible function
/**< 传入controller,保证在主线执行 */
+ (void)messageBox:(NSString *)msg superVC:(UIViewController *)superVC;

/**
 *  可定义按钮字符
 *
 *  @param msg     内容
 *  @param superVC 父视图控制器
 *  @param btnName 取消按钮名称
 */
+ (void)messageBox:(NSString *)msg superVC:(UIViewController *)superVC btnName:(NSString*)btnName;

/**
 *  主线程调用alert，弹出msg内容框
 *
 *  @param msg     内容
 *  @param title   标题
 *  @param superVC  controller
 */
+ (void)messageBox:(NSString *)msg title:(NSString *)title superVC:(UIViewController *)superVC;

@end
