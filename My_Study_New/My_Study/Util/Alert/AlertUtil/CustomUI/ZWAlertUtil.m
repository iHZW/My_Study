//
//  ZWAlertUtil.m
//  My_Study
//
//  Created by hzw on 2024/1/29.
//  Copyright © 2024 HZW. All rights reserved.
//

#import "ZWAlertUtil.h"
#import "ZWSDK.h"
#import "UIFont+Tool.h"

@implementation ZWAlertUtil

/// 自定义默认样式的弹出框
/// - Parameters:
///   - title: 标题
///   - centerViewBlock: 自定义中间视图
///   - cancelName: 左侧取消名称
///   - okName: 右侧确认名称
///   - cancelBlock: 取消回调
///   - okBlock: 确认回调
+ (void)mmConfirm:(nullable NSString *)title
  centerViewBlock:(MakeViewBlock)centerViewBlock
        cancelName:(nullable NSString *)cancelName
           okName:(nullable NSString *)okName
      cancelBlock:(void (^)(void))cancelBlock
          okBlock:(void (^)(void))okBlock {
    AlertView *alertView = [[AlertView alloc] init];
    alertView.title = title;
    alertView.titleFont = [UIFont eh_midiumFontSize:17];
    alertView.disableBgTap = YES;
    /**  message 支持html标签  */
    @weakify(alertView)
    if (centerViewBlock) {
        alertView.customCenterViewBlock = centerViewBlock;
    }
    alertView.actions = @[
        [AlertAction defaultCancelAction:cancelName ?: @"取消" clickCallback:^{
            @strongify(alertView)
            BlockSafeRun(cancelBlock);
            [alertView hidden];
        }],
        [AlertAction defaultConfirmAction:okName ?: @"确认" clickCallback:^{
            @strongify(alertView)
            BlockSafeRun(okBlock);
            [alertView hidden];
        }]
    ];
    [alertView show];
}



/// 自定义默认样式的弹出框
/// - Parameters:
///   - title: 标题
///   - actionType: 弹出类型
///   - topViewBlock: 自定义头部视图
///   - centerViewBlock: 自定义中间视图
///   - bottomViewBlock: 自定义中底部视图
+ (AlertView *)mmConfirm:(nullable NSString *)title
                actionType:(ActionType)actionType
              topViewBlock:(MakeViewBlock)topViewBlock
           centerViewBlock:(MakeViewBlock)centerViewBlock
         bottomViewBlock:(MakeViewBlock)bottomViewBlock {
    AlertView *alertView = [ZWAlertUtil mmConfirm:title
                                       actionType:actionType
                                         autoShow:YES
                                     topViewBlock:topViewBlock
                                  centerViewBlock:centerViewBlock
                                  bottomViewBlock:bottomViewBlock];
    return alertView;
}

/// 自定义默认样式的弹出框
/// - Parameters:
///   - title: 标题
///   - actionType: 弹出类型
///   - autoShow: 是否自动弹起   YES: 自动弹起  NO:不自动弹起
///   - topViewBlock: 自定义头部视图
///   - centerViewBlock: 自定义中间视图
///   - bottomViewBlock: 自定义中底部视图
+ (AlertView *)mmConfirm:(nullable NSString *)title
                actionType:(ActionType)actionType
                  autoShow:(BOOL)autoShow
              topViewBlock:(MakeViewBlock)topViewBlock
           centerViewBlock:(MakeViewBlock)centerViewBlock
         bottomViewBlock:(MakeViewBlock)bottomViewBlock {
    AlertView *alertView = [[AlertView alloc] init];
    alertView.title = title;
    alertView.actionType = actionType;
    alertView.titleFont = [UIFont eh_midiumFontSize:17];
    alertView.disableBgTap = NO;

    if (topViewBlock) {
        alertView.customTopViewBlock = topViewBlock;
    }

    if (centerViewBlock) {
        alertView.customCenterViewBlock = centerViewBlock;
    }

    if (bottomViewBlock) {
        alertView.customBottomViewBlock = bottomViewBlock;
    }
    if (autoShow) {
        [alertView show];
    }
    return alertView;
    
}

@end
