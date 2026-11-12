//
//  ZWMemberStyle.h
//  My_Study
//
//  会员模块视觉规范 —— 对齐 App 主题（品牌绿 0x315F57 / 卡片白 / 浅绿灰底）
//  颜色随深浅主题切换（参考 LoginViewController / SettingViewController 的取色方式）
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 当前是否为深色主题（与登录页相同的亮度判断逻辑）
static inline BOOL ZWMemberIsDarkTheme(void) {
    UIColor *base = ThemePickerColorKey(ZWColorKey_p1).color;
    CGFloat r = 0, g = 0, b = 0, a = 0;
    if (![base getRed:&r green:&g blue:&b alpha:&a]) {
        return NO;
    }
    return ((0.299 * r + 0.587 * g + 0.114 * b) < 0.5);
}

static inline UIColor *ZWMemberColor(NSUInteger lightRGB, NSUInteger darkRGB) {
    return UIColorFromRGB(ZWMemberIsDarkTheme() ? darkRGB : lightRGB);
}

/// 品牌绿（Hero 卡片、头像、实心按钮，深浅主题保持一致）
static inline UIColor *ZWMemberBrandColor(void)  { return UIColorFromRGB(0x315F57); }
/// 强调色（数字、链接、聚焦态）
static inline UIColor *ZWMemberAccentColor(void) { return ZWMemberColor(0x315F57, 0x85B9A8); }
/// 主文字
static inline UIColor *ZWMemberInkColor(void)    { return ZWMemberColor(0x294B46, 0xE2EDE7); }
/// 辅助文字
static inline UIColor *ZWMemberMutedColor(void)  { return ZWMemberColor(0x82918E, 0xA0B3A9); }
/// 页面背景
static inline UIColor *ZWMemberBgColor(void)     { return ZWMemberColor(0xF4F7F5, 0x17221E); }
/// 卡片背景
static inline UIColor *ZWMemberCardColor(void)   { return ZWMemberColor(0xFFFFFF, 0x21312A); }
/// 描边 / 分隔线
static inline UIColor *ZWMemberBorderColor(void) { return ZWMemberColor(0xE4ECE7, 0x34483E); }
/// 浅底（头像底、徽标底、输入框底）
static inline UIColor *ZWMemberTintBgColor(void) { return ZWMemberColor(0xE7F0EC, 0x2E453B); }
/// Hero 卡片上的主文字
static inline UIColor *ZWMemberOnBrandColor(void)     { return [UIColor colorWithWhite:1.0 alpha:0.95]; }
/// Hero 卡片上的辅助文字
static inline UIColor *ZWMemberOnBrandSubColor(void)  { return [UIColor colorWithWhite:1.0 alpha:0.72]; }
/// Hero 卡片上的徽标底
static inline UIColor *ZWMemberOnBrandTintColor(void) { return [UIColor colorWithWhite:1.0 alpha:0.16]; }

/// 金额格式化（¥0.00）
static inline NSString *ZWMemberFormatMoney(id value) {
    return [NSString stringWithFormat:@"¥%.2f", [value doubleValue]];
}

/// 无值时显示占位
static inline NSString *ZWMemberNonEmpty(NSString *value) {
    return value.length ? value : @"—";
}

/// ISO8601 时间（2026-10-29T10:00:00.000Z）→ 2026-10-29 10:00
static inline NSString *ZWMemberFormatDate(id value) {
    if (![value isKindOfClass:[NSString class]] || ![value length]) return @"—";
    NSString *iso = value;
    NSDateFormatter *parser = [[NSDateFormatter alloc] init];
    parser.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    parser.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    parser.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    NSDate *date = [parser dateFromString:iso];
    if (!date) {
        parser.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
        date = [parser dateFromString:iso];
    }
    if (!date) return iso;
    NSDateFormatter *printer = [[NSDateFormatter alloc] init];
    printer.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    printer.dateFormat = @"yyyy-MM-dd HH:mm";
    return [printer stringFromDate:date];
}

/// 性别（0 未知 / 1 男 / 2 女）
static inline NSString *ZWMemberGenderText(id value) {
    switch ([value integerValue]) {
        case 1: return @"男";
        case 2: return @"女";
        default: return @"未知";
    }
}

/// 订单类型（1 堂食 / 2 外卖 / 3 零售）
static inline NSString *ZWMemberOrderTypeText(id value) {
    switch ([value integerValue]) {
        case 1: return @"堂食";
        case 2: return @"外卖";
        case 3: return @"零售";
        default: return @"消费";
    }
}

/// 支付方式（cash / wechat / alipay / balance）
static inline NSString *ZWMemberPayMethodText(id value) {
    if (![value isKindOfClass:[NSString class]]) return @"";
    static NSDictionary<NSString *, NSString *> *map = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = @{@"cash": @"现金", @"wechat": @"微信", @"alipay": @"支付宝", @"balance": @"储值卡"};
    });
    return map[value] ?: value;
}

NS_ASSUME_NONNULL_END
