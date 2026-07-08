//
//  ZWAppIconManager.h
//  My_Study
//
//  Created by Codex on 2026/7/7.
//  Copyright © 2026 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const ZWAppIconOptionTitleKey;
extern NSString *const ZWAppIconOptionNameKey;

typedef void (^ZWAppIconChangeCompletion)(BOOL success, NSString *message, NSError *_Nullable error);

@interface ZWAppIconManager : NSObject

+ (instancetype)sharedManager;

/// 启动自动检查，内部会监听系统时间变化。
- (void)startAutoCheck;

/// App 回到前台或启动后调用。自动模式开启时，命中节日换节日图标，过期恢复默认图标。
- (void)checkAndApplyAutoIconIfNeeded;

- (BOOL)supportsAlternateIcons;
- (BOOL)isAutoModeEnabled;
- (void)setAutoModeEnabled:(BOOL)enabled completion:(nullable ZWAppIconChangeCompletion)completion;

/// 手动设置图标。调用后会自动关闭跟随节日模式，避免被下一次自动检查覆盖。
- (void)setManualIconName:(nullable NSString *)iconName title:(NSString *)title completion:(nullable ZWAppIconChangeCompletion)completion;

- (NSArray<NSDictionary<NSString *, NSString *> *> *)iconOptions;
- (NSString *)titleForIconName:(nullable NSString *)iconName;
- (nullable NSString *)currentIconName;
- (nullable NSString *)expectedAutoIconNameForDate:(NSDate *)date;
- (NSString *)autoRuleDescriptionForDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
