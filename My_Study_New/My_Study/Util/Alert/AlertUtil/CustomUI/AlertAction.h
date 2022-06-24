//
//  AlertAction.h
//  CRM
//
//  Created by js on 2020/2/20.
//  Copyright © 2020 js. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface AlertAction : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *backgroudColor;
@property (nonatomic, copy,nullable) dispatch_block_t clickCallback;


+ (instancetype)action:(NSString *)title
                textColor:(UIColor *)textColor
                backgroudColor:(UIColor *)backgroudColor
                clickCallback:(dispatch_block_t)clickCallback;
/** 默认取消样式 */
+ (instancetype)defaultCancelAction:(NSString *)title
                      clickCallback:(dispatch_block_t)clickCallback;
/** 默认点击按钮样式 */
+ (instancetype)defaultNormalAction:(NSString *)title
                      clickCallback:(dispatch_block_t)clickCallback;
/** 默认红色删除样式 */
+ (instancetype)defaultDestructiveAction:(NSString *)title
                           clickCallback:(dispatch_block_t)clickCallback;
/** 默认确定样式*/
+ (instancetype)defaultConfirmAction:(NSString *)title
                       clickCallback:(dispatch_block_t)clickCallback;
@end

NS_ASSUME_NONNULL_END
