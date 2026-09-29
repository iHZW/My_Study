//
//  MMPickerUtil.h
//  MMBaseComponent
//
//  Created by Zhiwei Han on 2023/1/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMPickerUtil : NSObject

// 是否是闰年
+ (BOOL)bissextile:(int)year;

+ (NSArray *)yearList;

+ (NSArray *)yearList2;

+ (NSArray *)monthList;

+ (NSArray *)monthList2:(NSString *)nowMouth;

// type = 1 31天 / type = 2 30天 / type = 3 28天 / type = 4 29天
+ (NSArray *)dayList:(NSInteger)type;

// type = 1 31天 / type = 2 30天 / type = 3 28天 / type = 4 29天   不足10号不补0
+ (NSArray *)dayList2:(NSInteger)type toDay:(NSString *)today;

+ (NSArray *)hourList;

+ (NSArray *)hourList2:(NSString *)hour;

+ (NSArray *)minuteList;

+ (NSArray *)minuteList2:(NSString *)minute;

+ (NSArray *)secondList;

@end

NS_ASSUME_NONNULL_END
