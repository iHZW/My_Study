//
//  NSString+MoneyFormat.h
//  PASecuritiesApp
//
//  Created by Weirdln on 16/6/1.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MoneyFormat)

/**
 *  将自己按照指定格式格式化字符串
 *
 *  @param numberStyle 需要的格式，设置成NSNumberFormatterNoStyle格式化成123,456,789.00格式
 */
- (NSString *)formatToNumberStyle:(NSNumberFormatterStyle)numberStyle;

 /** 获取小数点个数 */
- (NSInteger)getNumberOfDecimalPoint;

//将字符串存在“十百千“等汉字的值转换成存数字
+ (NSString *)convertCharacterMoneyToDigital:(NSString *)characterMoney;

- (NSString *)convertCharacterMoneyToDigital;

/**
 *  将自己格式成金额格式的字符串，小数点位数由本身的位数决定 比如123,456,789.00
 */
- (NSString *)formatToMoneyStyle;

/**
 *  按照传入的小数点位数将自己格式化成金额格式
 */
- (NSString *)formatToMoneyStyleWithDecimalPoint:(NSInteger)decimalPoint;

/**
 *  按照传入的小数点位数将自己格式化成金额格式,并金额超过一个亿截取时，不遵从四舍五入规则
 */
- (NSString *)formatToMoneyStyleSpecialRoundingWithDecimalPoint:(NSInteger)decimalPoint;

/**
 *  格式化成不带小数点的千分位格式
 */
- (NSString *)formatToMoneyStyleWithNoPoint;

/**
 *  按照传入的小数点位数格式化成金额格式
 */
+ (NSString *)formatValue:(CGFloat)value decimalPoint:(NSInteger)decimalPoint;

/**
 *  如果传入的字符串为空或者长度为0，返回制定的字符串
 */
+ (NSString *)formatToMoneyStyle:(NSString *)moneyString placeIfNull:(NSString *)place;

/**
 *  将自己格式化成千分位格式123,456,789
 */
- (NSString *)formatToDecimalString;

/**
 *  判断输入的字符是不是数字和.
 *
 *  @param str 输入字符串
 *
 *  @return YES:数字和. NO:非数字和.
 */
+ (BOOL)isNumber:(NSString *)str;

/**
 *  判断输入的字符串是不是纯数字
 *
 *  @param string 输入字符串
 *
 *  @return YES:数字 NO:非数字
 */
+ (BOOL)isPureInt:(NSString *)string;

/**
 *  判断输入的字符串是否是 money类型的, 1:只有一个.  2:不以.开头  3:小数.后的位数可控
 *
 *  @param content 输入的内容
 *  @param count   小数点后可输入的位数
 *  @param string  当前输入的内容
 *  @param tf      当前的textField
 *
 *  @return YES:是 money类型的 否则NO
 */
+ (BOOL)isMoneyType:(NSString *)content count:(NSInteger)count replacementString:(NSString *)string textField:(UITextField *)tf;

/**
 *  判断输入的是不是 空格
 *
 *  @param string 正在输入的字符
 *
 *  @return YES:是 空格 否则NO
 */
+ (BOOL)isSpaceStr:(NSString *)string;

/**
 *  是否是金额整数倍
 *  @param money 金额字符串
 *  @param multiple ：倍数
 *  @return YES 是整数倍
 */
+ (BOOL)isFormatMoney:(NSString *)money multiple:(NSInteger)multiple;

/**
 格式化 大额金额减法结果  A - B (6.3增)
 * 小于等于0，不返回"--" 带负号
 * 大于0，小于1万，返回符合小数位数的值 如100.00
 * 大于1万，小于1亿，格式化为以万做单位
 * 大于1亿，格式化为以亿做单位
 @param firstV  数值1
 @param secondV 数值2
 @param precision 突破万(或值为0)后面显示的小数点个数，如100000，precision为2时显示10.00万
 @return 字符串
 */
+ (NSString *)formatMoneyToSubtract:(int)firstV secondV:(int)secondV precision:(int)precision;

/*
 * 对金额小数点截断
 * doubleValue ： 多少位数  例如100000000
 */
+ (NSString *)truncationMoneyStringformat:(NSString *)value doubleValue:(double)doubleValue;


@end
