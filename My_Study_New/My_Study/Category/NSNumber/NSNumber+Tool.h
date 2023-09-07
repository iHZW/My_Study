//
//  NSNumber+Tool.h
//  NBBankEHomeProject
//
//  Created by wsk on 2022/11/23.
//

#import <Foundation/Foundation.h>

extern NSString* const _Nullable cg_user_default_key_iem_switch;

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (Tool)

+ (CGFloat)eh_safeTop;

+ (CGFloat)eh_safeTopToNavBar;

+ (CGFloat)eh_safeBottom;

+ (CGFloat)eh_safeLeft;

+ (CGFloat)eh_safeRight;

+ (BOOL)eh_iphoneX;

+ (CGFloat)eh_tabBarHeight;

/// 屏幕缩放比
+ (CGFloat)eh_screenScale;

@end

NS_ASSUME_NONNULL_END
