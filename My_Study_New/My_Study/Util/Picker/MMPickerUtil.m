//
//  MMPickerUtil.m
//  MMBaseComponent
//
//  Created by Zhiwei Han on 2023/1/28.
//

#import "MMPickerUtil.h"

@implementation MMPickerUtil

+ (BOOL)bissextile:(int)year {
    if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        return YES;
    } else {
        return NO;
    }
    return NO;
}

// 默认当前年份前后十年
+ (NSArray *)yearList {
    NSDate *current = [NSDate date];

    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy"];
    NSString *thisYearString = [dateformatter stringFromDate:current];

    NSInteger year1 = [thisYearString integerValue];

    NSMutableArray *yearList = [NSMutableArray array];
    [yearList addObject:[NSString stringWithFormat:@"%ld", year1]];

    for (NSInteger i = 0; i < 100; i++) {
        year1--;
        [yearList addObject:[NSString stringWithFormat:@"%ld", year1]];
    }

    NSInteger year2 = [thisYearString integerValue];

    for (NSInteger i = 0; i < 100; i++) {
        year2++;
        [yearList addObject:[NSString stringWithFormat:@"%ld", year2]];
    }

    [yearList sortUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    return [yearList copy];
}

+ (NSArray *)yearList2 {
    NSDate *current = [NSDate date];

    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy"];
    NSString *thisYearString = [dateformatter stringFromDate:current];

    NSInteger year1 = [thisYearString integerValue];

    NSMutableArray *yearList = [NSMutableArray array];
    [yearList addObject:[NSString stringWithFormat:@"%ld", year1]];

    for (NSInteger i = 0; i < 100; i++) {
        year1++;
        [yearList addObject:[NSString stringWithFormat:@"%ld", year1]];
    }

    [yearList sortUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    return [yearList copy];
}

+ (NSArray *)monthList {
    return @[
        @"01",
        @"02",
        @"03",
        @"04",
        @"05",
        @"06",
        @"07",
        @"08",
        @"09",
        @"10",
        @"11",
        @"12"
    ];
}

+ (NSArray *)monthList2:(NSString *)nowMouth {
    NSInteger now          = [nowMouth integerValue];
    NSMutableArray *result = [NSMutableArray array];
    for (NSInteger i = 1; i < 13; i++) {
        if (i >= now) {
            if (i > 9) {
                [result addObject:[NSString stringWithFormat:@"%ld", i]];
            } else {
                [result addObject:[NSString stringWithFormat:@"0%ld", i]];
            }
        }
    }
    return result;
}

+ (NSArray *)dayList:(NSInteger)type {
    NSMutableArray *dayList = [NSMutableArray array];
    NSInteger count         = 30;
    if (type == 1) {
        count = 31;
    } else if (type == 2) {
        count = 30;
    } else if (type == 3) {
        count = 28;
    } else if (type == 4) {
        count = 29;
    }
    for (NSInteger i = 1; i <= count; i++) {
        if (i < 10) {
            [dayList addObject:[NSString stringWithFormat:@"0%ld", i]];
        } else {
            [dayList addObject:[NSString stringWithFormat:@"%ld", i]];
        }
    }
    return dayList;
}

+ (NSArray *)dayList2:(NSInteger)type toDay:(NSString *)today {
    NSMutableArray *dayList = [NSMutableArray array];
    NSInteger count         = 30;
    if (type == 1) {
        count = 31;
    } else if (type == 2) {
        count = 30;
    } else if (type == 3) {
        count = 28;
    } else if (type == 4) {
        count = 29;
    }
    for (NSInteger i = 1; i < count + 1; i++) {
        if ([today isEqualToString:@"--"]) {
            if (i < 10) {
                [dayList addObject:[NSString stringWithFormat:@"0%ld", i]];
            } else {
                [dayList addObject:[NSString stringWithFormat:@"%ld", i]];
            }
        } else {
            NSInteger nowday = [today integerValue];
            if (i >= nowday) {
                if (i < 10) {
                    [dayList addObject:[NSString stringWithFormat:@"0%ld", i]];
                } else {
                    [dayList addObject:[NSString stringWithFormat:@"%ld", i]];
                }
            }
        }
    }
    return dayList;
}

+ (NSArray *)hourList {
    NSInteger num            = 0;
    NSMutableArray *hourList = [NSMutableArray array];
    for (NSInteger i = 0; i < 24; i++) {
        if (i < 10) {
            [hourList addObject:[NSString stringWithFormat:@"0%ld", num]];
        } else {
            [hourList addObject:[NSString stringWithFormat:@"%ld", num]];
        }
        num++;
    }
    return hourList;
}

+ (NSArray *)hourList2:(NSString *)hour {
    NSMutableArray *hourList = [NSMutableArray array];
    for (NSInteger i = 0; i < 24; i++) {
        if ([hour isEqualToString:@"--"]) {
            if (i < 10) {
                [hourList addObject:[NSString stringWithFormat:@"0%ld", i]];
            } else {
                [hourList addObject:[NSString stringWithFormat:@"%ld", i]];
            }
        } else {
            NSInteger nowHour = [hour integerValue];
            if (i >= nowHour) {
                if (i < 10) {
                    [hourList addObject:[NSString stringWithFormat:@"0%ld", i]];
                } else {
                    [hourList addObject:[NSString stringWithFormat:@"%ld", i]];
                }
            }
        }
    }
    return hourList;
}

+ (NSArray *)minuteList {
    NSInteger num              = 0;
    NSMutableArray *minuteList = [NSMutableArray array];
    for (NSInteger i = 0; i < 60; i++) {
        if (i < 10) {
            [minuteList addObject:[NSString stringWithFormat:@"0%ld", num]];
        } else {
            [minuteList addObject:[NSString stringWithFormat:@"%ld", num]];
        }
        num++;
    }
    return minuteList;
}

+ (NSArray *)minuteList2:(NSString *)minute {
    NSMutableArray *minuteList = [NSMutableArray array];
    for (NSInteger i = 0; i < 60; i++) {
        if ([minute isEqualToString:@"--"]) {
            if (i < 10) {
                [minuteList addObject:[NSString stringWithFormat:@"0%ld", i]];
            } else {
                [minuteList addObject:[NSString stringWithFormat:@"%ld", i]];
            }
        } else {
            NSInteger nowMintute = [minute integerValue];
            if (i >= nowMintute) {
                if (i < 10) {
                    [minuteList addObject:[NSString stringWithFormat:@"0%ld", i]];
                } else {
                    [minuteList addObject:[NSString stringWithFormat:@"%ld", i]];
                }
            }
        }
    }
    return minuteList;
}

+ (NSArray *)secondList {
    NSInteger num              = 0;
    NSMutableArray *secondList = [NSMutableArray array];
    for (NSInteger i = 0; i < 60; i++) {
        if (i < 10) {
            [secondList addObject:[NSString stringWithFormat:@"0%ld", num]];
        } else {
            [secondList addObject:[NSString stringWithFormat:@"%ld", num]];
        }
        num++;
    }
    return secondList;
}

@end
