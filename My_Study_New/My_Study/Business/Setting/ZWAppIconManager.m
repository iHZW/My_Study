//
//  ZWAppIconManager.m
//  My_Study
//
//  Created by Codex on 2026/7/7.
//  Copyright © 2026 HZW. All rights reserved.
//

#import "ZWAppIconManager.h"

NSString *const ZWAppIconOptionTitleKey = @"title";
NSString *const ZWAppIconOptionNameKey  = @"iconName";

static NSString *const kZWAppIconSpringFestival = @"AppIconSpringFestival";
static NSString *const kZWAppIconDragonBoat     = @"AppIconDragonBoat";
static NSString *const kZWAppIconMidAutumn      = @"AppIconMidAutumn";
static NSString *const kZWAppIconDoubleEleven   = @"AppIconDoubleEleven";

static NSString *const kZWAppIconAutoModeKey          = @"kZWAppIconAutoModeKey";
static NSString *const kZWAppIconManualNameKey        = @"kZWAppIconManualNameKey";
static NSString *const kZWAppIconLastAutoNameKey      = @"kZWAppIconLastAutoNameKey";
static NSString *const kZWAppIconLastAutoFailTokenKey = @"kZWAppIconLastAutoFailTokenKey";

static NSInteger const kZWAppIconSpringFestivalStartDay = 28;
static NSInteger const kZWAppIconSpringFestivalEndDay   = 8;

@interface ZWAppIconManager ()

@property (nonatomic, assign) BOOL didStartAutoCheck;

@end

@implementation ZWAppIconManager

+ (instancetype)sharedManager {
    static ZWAppIconManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ZWAppIconManager alloc] init];
    });
    return manager;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)startAutoCheck {
    if (self.didStartAutoCheck) {
        return;
    }
    self.didStartAutoCheck = YES;
    [NSUserDefaults.standardUserDefaults removeObjectForKey:kZWAppIconLastAutoFailTokenKey];
    [NSUserDefaults.standardUserDefaults synchronize];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(checkAndApplyAutoIconIfNeeded)
                                               name:UIApplicationSignificantTimeChangeNotification
                                             object:nil];
}

- (BOOL)supportsAlternateIcons {
    if (@available(iOS 10.3, *)) {
        return UIApplication.sharedApplication.supportsAlternateIcons;
    }
    return NO;
}

- (BOOL)isAutoModeEnabled {
    id value = [NSUserDefaults.standardUserDefaults objectForKey:kZWAppIconAutoModeKey];
    if (!value) {
        return YES;
    }
    return [value boolValue];
}

- (void)setAutoModeEnabled:(BOOL)enabled completion:(ZWAppIconChangeCompletion)completion {
    [NSUserDefaults.standardUserDefaults setBool:enabled forKey:kZWAppIconAutoModeKey];
    if (enabled) {
        [NSUserDefaults.standardUserDefaults removeObjectForKey:kZWAppIconLastAutoFailTokenKey];
    }
    [NSUserDefaults.standardUserDefaults synchronize];
    if (enabled) {
        [self checkAndApplyAutoIconIfNeededWithCompletion:completion];
    } else if (completion) {
        completion(YES, @"已关闭跟随节日自动切换", nil);
    }
}

- (void)setManualIconName:(NSString *)iconName title:(NSString *)title completion:(ZWAppIconChangeCompletion)completion {
    [NSUserDefaults.standardUserDefaults setBool:NO forKey:kZWAppIconAutoModeKey];
    if (iconName.length > 0) {
        [NSUserDefaults.standardUserDefaults setObject:iconName forKey:kZWAppIconManualNameKey];
    } else {
        [NSUserDefaults.standardUserDefaults removeObjectForKey:kZWAppIconManualNameKey];
    }
    [NSUserDefaults.standardUserDefaults synchronize];

    [self applyIconName:iconName title:title silent:NO completion:completion];
}

- (void)checkAndApplyAutoIconIfNeeded {
    [self checkAndApplyAutoIconIfNeededWithCompletion:nil];
}

- (void)checkAndApplyAutoIconIfNeededWithCompletion:(ZWAppIconChangeCompletion)completion {
    if (![self isAutoModeEnabled]) {
        if (completion) {
            completion(YES, @"当前为手动图标模式", nil);
        }
        return;
    }
    if (UIApplication.sharedApplication.applicationState != UIApplicationStateActive) {
        if (completion) {
            completion(YES, @"App进入前台后会自动检查图标", nil);
        }
        return;
    }
    if (![self supportsAlternateIcons]) {
        if (completion) {
            completion(NO, @"当前设备不支持切换App图标", nil);
        }
        return;
    }

    NSString *targetIconName = [self expectedAutoIconNameForDate:NSDate.date];
    NSString *currentIconName = [self currentIconName];
    BOOL isSameIcon = (currentIconName.length == 0 && targetIconName.length == 0) || [currentIconName isEqualToString:targetIconName];
    if (isSameIcon) {
        [NSUserDefaults.standardUserDefaults setObject:targetIconName ?: @"" forKey:kZWAppIconLastAutoNameKey];
        [NSUserDefaults.standardUserDefaults synchronize];
        if (completion) {
            completion(YES, @"当前图标已经符合节日规则", nil);
        }
        return;
    }

    NSString *failToken = [self failTokenForIconName:targetIconName date:NSDate.date];
    NSString *lastFailToken = [NSUserDefaults.standardUserDefaults stringForKey:kZWAppIconLastAutoFailTokenKey];
    if ([lastFailToken isEqualToString:failToken]) {
        if (completion) {
            completion(NO, @"上次自动切换失败，重新开启自动模式后会再次尝试", nil);
        }
        return;
    }

    NSString *title = [self titleForIconName:targetIconName];
    [self applyIconName:targetIconName title:title silent:YES completion:^(BOOL success, NSString *message, NSError *_Nullable error) {
        if (success) {
            [NSUserDefaults.standardUserDefaults setObject:targetIconName ?: @"" forKey:kZWAppIconLastAutoNameKey];
            [NSUserDefaults.standardUserDefaults removeObjectForKey:kZWAppIconLastAutoFailTokenKey];
            [NSUserDefaults.standardUserDefaults synchronize];
        } else {
            [NSUserDefaults.standardUserDefaults setObject:failToken forKey:kZWAppIconLastAutoFailTokenKey];
            [NSUserDefaults.standardUserDefaults synchronize];
        }
        if (completion) {
            completion(success, message, error);
        }
    }];
}

- (void)applyIconName:(NSString *)iconName title:(NSString *)title silent:(BOOL)silent completion:(ZWAppIconChangeCompletion)completion {
    if (![self supportsAlternateIcons]) {
        if (completion) {
            completion(NO, @"当前设备不支持切换App图标", nil);
        }
        return;
    }

    NSString *currentIconName = [self currentIconName];
    BOOL isSameIcon = (currentIconName.length == 0 && iconName.length == 0) || [currentIconName isEqualToString:iconName];
    if (isSameIcon) {
        if (completion) {
            completion(YES, [NSString stringWithFormat:@"当前已经是%@", title], nil);
        }
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if (@available(iOS 10.3, *)) {
            [UIApplication.sharedApplication setAlternateIconName:iconName completionHandler:^(NSError *_Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        NSString *errorMessage = error.localizedDescription.length > 0 ? error.localizedDescription : @"请确认图标资源已经加入工程";
                        if (completion) {
                            completion(NO, [NSString stringWithFormat:@"切换失败：%@", errorMessage], error);
                        }
                        return;
                    }
                    if (completion) {
                        completion(YES, [NSString stringWithFormat:@"已切换为%@", title], nil);
                    }
                });
            }];
        }
    });
}

- (NSArray<NSDictionary<NSString *, NSString *> *> *)iconOptions {
    return @[
        @{ZWAppIconOptionTitleKey: @"默认图标", ZWAppIconOptionNameKey: @""},
        @{ZWAppIconOptionTitleKey: @"春节图标", ZWAppIconOptionNameKey: kZWAppIconSpringFestival},
        @{ZWAppIconOptionTitleKey: @"端午图标", ZWAppIconOptionNameKey: kZWAppIconDragonBoat},
        @{ZWAppIconOptionTitleKey: @"中秋图标", ZWAppIconOptionNameKey: kZWAppIconMidAutumn},
        @{ZWAppIconOptionTitleKey: @"双十一图标", ZWAppIconOptionNameKey: kZWAppIconDoubleEleven},
    ];
}

- (NSString *)titleForIconName:(NSString *)iconName {
    NSString *safeIconName = iconName ?: @"";
    for (NSDictionary *option in [self iconOptions]) {
        if ([option[ZWAppIconOptionNameKey] isEqualToString:safeIconName]) {
            return option[ZWAppIconOptionTitleKey];
        }
    }
    return @"默认图标";
}

- (NSString *)currentIconName {
    if (@available(iOS 10.3, *)) {
        return UIApplication.sharedApplication.alternateIconName;
    }
    return nil;
}

- (NSString *)expectedAutoIconNameForDate:(NSDate *)date {
    if ([self isDoubleElevenDate:date]) {
        return kZWAppIconDoubleEleven;
    }
    if ([self isSpringFestivalDate:date]) {
        return kZWAppIconSpringFestival;
    }
    if ([self isDragonBoatDate:date]) {
        return kZWAppIconDragonBoat;
    }
    if ([self isMidAutumnDate:date]) {
        return kZWAppIconMidAutumn;
    }
    return nil;
}

- (NSString *)autoRuleDescriptionForDate:(NSDate *)date {
    NSString *targetIconName = [self expectedAutoIconNameForDate:date];
    NSDateComponents *components = [self chineseDateComponentsWithDate:date];
    NSString *targetTitle = [self titleForIconName:targetIconName];
    return [NSString stringWithFormat:@"当前农历：%@%@月%@日，自动目标：%@",
            components.isLeapMonth ? @"闰" : @"",
            @(components.month),
            @(components.day),
            targetTitle];
}

- (BOOL)isDoubleElevenDate:(NSDate *)date {
    NSDateComponents *components = [NSCalendar.currentCalendar components:NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    return components.month == 11 && components.day >= 10 && components.day <= 12;
}

- (BOOL)isSpringFestivalDate:(NSDate *)date {
    NSDateComponents *components = [self chineseDateComponentsWithDate:date];
    if (components.isLeapMonth) {
        return NO;
    }

    // 覆盖春节常见假期：腊月二十八到正月初八。
    // 不写死公历日期，避免每年放假安排调整后规则失效。
    return (components.month == 12 && components.day >= kZWAppIconSpringFestivalStartDay) ||
           (components.month == 1 && components.day <= kZWAppIconSpringFestivalEndDay);
}

- (BOOL)isDragonBoatDate:(NSDate *)date {
    NSDateComponents *components = [self chineseDateComponentsWithDate:date];
    if (components.isLeapMonth) {
        return NO;
    }
    return components.month == 5 && components.day >= 4 && components.day <= 6;
}

- (BOOL)isMidAutumnDate:(NSDate *)date {
    NSDateComponents *components = [self chineseDateComponentsWithDate:date];
    if (components.isLeapMonth) {
        return NO;
    }
    return components.month == 8 && components.day >= 14 && components.day <= 16;
}

- (NSDateComponents *)chineseDateComponentsWithDate:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    calendar.timeZone = NSTimeZone.localTimeZone;
    return [calendar components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitCalendar | NSCalendarUnitEra fromDate:date];
}

- (NSString *)failTokenForIconName:(NSString *)iconName date:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.timeZone = NSTimeZone.localTimeZone;
    formatter.dateFormat = @"yyyyMMdd";
    return [NSString stringWithFormat:@"%@_%@", [formatter stringFromDate:date], iconName ?: @"default"];
}

@end
