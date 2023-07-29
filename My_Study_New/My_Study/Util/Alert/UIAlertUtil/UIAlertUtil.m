//
//  UIAlertUtil.m
//  TZYJ_IPhone
//
//  Created by Howard on 15/6/10.
//
//

#import "UIAlertUtil.h"
#import "GCDCommon.h"
#import "ZWSDK.h"
#import <objc/runtime.h>

@implementation UIAlertUtil

#pragma mark - Alert common function
/**
 生成提示框，为兼容iPhone6&6+，需使用UIAlertController

 @param title 标题
 @param message 消息内容
 @param cancelButtonTitle 取消标题
 @param otherButtonTitles 其他按钮集
 @param type UIAlertControllerStyle(UIAlertControllerStyleActionSheet, UIAlertControllerStyleAlert)
 @param actionBlock 触发事件回调
 @return 返回controller
 */
+ (id)alertObject:(NSString *)title
          message:(NSString *)message
cancelButtonTitle:(NSString *)cancelButtonTitle
otherButtonTitles:(NSArray *)otherButtonTitles
alertControllerStyle:(UIAlertControllerStyle)type
      actionBlock:(UIAlertViewTapBlock)actionBlock NS_AVAILABLE_IOS(8_0)
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:type];
        if (cancelButtonTitle) {
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                if (actionBlock) {
                    actionBlock(0);
                }
            }];
            
            [alert addAction:cancelAction];
        }
        
        if ([otherButtonTitles count] > 0) {
            for (NSInteger idx = 0; idx < [otherButtonTitles count]; idx++) {
                UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:otherButtonTitles[idx] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    if (actionBlock) {
                        actionBlock(idx+1);
                    }
                }];
                [alert addAction:confirmAction];
            }
        }
        
        return alert;
    }
    
    return nil;
}

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
             superVC:(UIViewController *)superVC NS_AVAILABLE_IOS(8_0)
{
    id alert = [[self class] alertObject:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles alertControllerStyle:type actionBlock:actionBlock];
    
    if (alert) {
        [alert dismissViewControllerAnimated:YES completion:^{
            [superVC presentViewController:alert animated:YES completion:nil];
        }];
    }
    
    return alert;
}

#pragma mark - Alert function
/**
 *  显示提示框，为兼容iPhone6&6+，需使用UIAlertController.
 *
 *  @param title             标题
 *  @param message           消息内容
 *  @param cancelButtonTitle 取消标题
 *  @param otherButtonTitles 其他按钮集
 *  @param cancelBlock       取消触发事件
 *  @param confirmBlock        其他按钮触发事件
 *  @param superVC           父视图控制器
 *  @return                  返回alertview或controller
 */
+ (id)showAlertTitle:(NSString *)title
             message:(NSString *)message
   cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitles:(NSArray *)otherButtonTitles
         cancelBlock:(UIAlertViewVoidBlock)cancelBlock
        confirmBlock:(UIAlertViewVoidBlock)confirmBlock
             superVC:(UIViewController *)superVC
{
    NSAssert([NSThread isMainThread], @"不能在辅线程弹UI");
    
    id alert = [[self class] showAlertTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles actionBlock:^(NSInteger index) {
        if (index == 0) {
            if (cancelBlock) {
                cancelBlock();
            }
        } else {
            if (index == 1 && confirmBlock) {
                confirmBlock();
            }
        }
    } superVC:superVC];
    
    return alert;
}

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
             superVC:(UIViewController *)superVC
{
    if(!title){
        title = @"";
    }
    NSAssert([NSThread isMainThread], @"不能在辅线程弹UI");
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        id alert = [[self class] showAlertTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles alertControllerStyle:UIAlertControllerStyleAlert actionBlock:actionBlock superVC:superVC];
        
        return alert;
    } else {
        UIAlertView *alertV = [UIAlertView showWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (actionBlock) {
                actionBlock(buttonIndex);
            }
        }];
        
        return alertV;
    }
}

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
             superVC:(UIViewController *)superVC
{
    NSAssert([NSThread isMainThread], @"不能在辅线程弹UI");
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        id alert = [[self class] alertObject:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles alertControllerStyle:UIAlertControllerStyleAlert actionBlock:actionBlock];

        if (alert) {
            [self changeAlertControllerProperty:alert msg:message align:textAlign color:msgColor font:font];
            [superVC presentViewController:alert animated:YES completion:nil];
        }
        
        return alert;
    } else {
        UIAlertView *alertV = [UIAlertView showWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (actionBlock) {
                actionBlock(buttonIndex);
            }
        }];
        
        return alertV;
    }
}

/**
 *  隐藏指定的alert
 *
 *  @param alert   对应alert对象
 *  @param animate 是否动画展示
 */
+ (void)dismissAlert:(id)alert animate:(BOOL)animate
{
    NSAssert([NSThread isMainThread], @"不能在辅线程弹UI");
    if ([alert isKindOfClass:[UIAlertView class]]) {
        [(UIAlertView *)alert dismissWithClickedButtonIndex:0 animated:animate];
    } else if ([alert isKindOfClass:[UIAlertController class]]) {
        UIAlertController *alertVC = (UIAlertController *)alert;
        [alertVC dismissViewControllerAnimated:animate completion:nil];
    }
}

/**
 *  获取UIAlertController属性名
 */
+ (void)changeAlertControllerProperty:(UIAlertController *)alert
                                  msg:(NSString *)msg
                                align:(NSTextAlignment)align
                                color:(UIColor *)color
                                 font:(UIFont *)font
{
    unsigned int count = 0;
    Ivar *property = class_copyIvarList([UIAlertController class], &count);
    
    for (int i = 0; i < count; i ++) {
        Ivar message = property[i];
        NSString *ivarName = [NSString stringWithCString:ivar_getName(message) encoding:NSUTF8StringEncoding];
        if ([ivarName isEqualToString:@"_attributedMessage"] && msg && [[UIDevice currentDevice].systemVersion floatValue] >= 8.3) {
            
            NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
            paragraph.alignment = align;//设置对齐方式
            
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc]
                                              initWithString:msg
                                              attributes:@{NSFontAttributeName:font,
                                                           NSForegroundColorAttributeName:color,
                                                           NSParagraphStyleAttributeName:paragraph}];
            
            [alert setValue:str forKey:@"attributedMessage"];
        }
    }
    free(property);
    //最后把message内容替换掉
    //    object_setIvar(alert, message, str);//ios9以上可以用
}

#pragma mark - messageBox‘s compatible function
/**< 传入controller,保证在主线执行 */
+ (void)messageBox:(NSString *)msg title:(NSString *)title superVC:(UIViewController *)superVC
{
    if(msg.length > 0){
        performBlockOnMainQueue(NO, ^{
            [UIAlertUtil showAlertTitle:title
                                message:msg
                      cancelButtonTitle:@"确定"
                      otherButtonTitles:nil
                            cancelBlock:nil
                           confirmBlock:nil
                                superVC:superVC];
        });
    }
}

/**
 *  可定义按钮字符
 *
 *  @param msg     内容
 *  @param superVC controller
 */
+ (void)messageBox:(NSString *)msg superVC:(UIViewController *)superVC
{
    if(msg.length > 0){
      [UIAlertUtil messageBox:msg title:@"" superVC:superVC];
    } 
}

/**
 *  可定义按钮字符
 *
 *  @param msg     内容
 *  @param superVC 父视图控制器
 *  @param btnName 取消按钮名称
 */
+ (void)messageBox:(NSString *)msg superVC:(UIViewController *)superVC btnName:(NSString*)btnName
{
    if(msg.length > 0){
        performBlockOnMainQueue(NO, ^{
            [UIAlertUtil showAlertTitle:@""
                                message:msg
                      cancelButtonTitle:btnName
                      otherButtonTitles:nil
                            cancelBlock:nil
                           confirmBlock:nil
                                superVC:superVC];
        });
    }
}

@end
