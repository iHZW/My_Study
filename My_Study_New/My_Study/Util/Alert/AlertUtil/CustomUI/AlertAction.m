//
//  AlertAction.m
//  CRM
//
//  Created by js on 2020/2/20.
//  Copyright © 2020 js. All rights reserved.
//

#import "AlertAction.h"
#import "UIColor+Ext.h"

@implementation AlertAction

+ (instancetype)action:(NSString *)title
textColor:(UIColor *)textColor
backgroudColor:(UIColor *)backgroudColor
         clickCallback:(dispatch_block_t)clickCallback{
    AlertAction *action = [[AlertAction alloc] init];
    action.title = title;
    action.textColor = textColor;
    action.backgroudColor = backgroudColor;
    action.clickCallback = clickCallback;
    return action;
}

/** 默认取消样式 */
+ (instancetype)defaultCancelAction:(NSString *)title
                      clickCallback:(dispatch_block_t)clickCallback{
    AlertAction *action = [[AlertAction alloc] init];
    action.title = title;
    action.textColor = [UIColor colorFromHexCode:@"#AAAAAA"];
    action.backgroudColor = [UIColor colorFromHexCode:@"#F8F9FF"];
    action.clickCallback = clickCallback;
    return action;
}

/** 默认点击按钮样式 */
+ (instancetype)defaultNormalAction:(NSString *)title
                      clickCallback:(dispatch_block_t)clickCallback{
    AlertAction *action = [[AlertAction alloc] init];
    action.title = title;
    action.textColor = [UIColor colorFromHexCode:@"#4F7AFD"];
    action.backgroudColor = [UIColor colorFromHexCode:@"#F1F4FF"];
    action.clickCallback = clickCallback;
    return action;
}
/** 默认红色删除样式 */
+ (instancetype)defaultDestructiveAction:(NSString *)title
                           clickCallback:(dispatch_block_t)clickCallback{
    AlertAction *action = [[AlertAction alloc] init];
    action.title = title;
    action.textColor = [UIColor colorFromHexCode:@"#FF4266"];
    action.backgroudColor = [UIColor colorFromHexCode:@"#FFF8F9"];
    action.clickCallback = clickCallback;
    return action;
}

/** 默认确定样式*/
+ (instancetype)defaultConfirmAction:(NSString *)title
                       clickCallback:(dispatch_block_t)clickCallback{
    AlertAction *action = [[AlertAction alloc] init];
    action.title = title;
    action.textColor = [UIColor colorFromHexCode:@"#FFFFFF"];
    action.backgroudColor = [UIColor colorFromHexCode:@"#4F7AFD"];
    action.clickCallback = clickCallback;
    return action;
}
@end
