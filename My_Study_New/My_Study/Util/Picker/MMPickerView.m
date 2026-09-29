//
//  MMPickerView.m
//  MMBaseComponent
//
//  Created by Zhiwei Han on 2023/1/28.
//

#import "MMDateUtil.h"
#import "MMPickerUtil.h"
#import "MMPickerView.h"

@interface MMPickerView () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIPickerView *pickVc;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, copy) NSString *year;

@property (nonatomic, copy) NSString *mouth;

@property (nonatomic, copy) NSString *day;

@property (nonatomic, copy) NSString *hour;

@property (nonatomic, copy) NSString *minute;

@end

@implementation MMPickerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.type         = MMPickerFormatterStyleDefault;
        _hasConfirmButton = NO;
        [self updateNowTime];
        [self initViews];
    }
    return self;
}

- (void)updateNowTime {
    NSDate *current      = [NSDate date];
    NSString *currentDay = [MMDateUtil getCurrentDateWithFormat:@"yyyy-MM-dd-HH-mm"];
    NSArray *arr         = [currentDay componentsSeparatedByString:@"-"];
    self.year            = [arr objectAtIndex:0];
    self.mouth           = [arr objectAtIndex:1];
    self.day             = [arr objectAtIndex:2];
    self.hour            = [arr objectAtIndex:3];
    if (self.type == MMPickerFormatterStyleCustom) {
        NSString *re  = [arr objectAtIndex:4];
        NSInteger re2 = [re integerValue];
        if (re2 == 59) {
            re2 = 0;
        } else {
            re2++;
        }
        if (re2 < 10) {
            self.minute = [NSString stringWithFormat:@"0%ld", re2];
        } else {
            self.minute = [NSString stringWithFormat:@"%ld", re2];
        }
    } else {
        self.minute = [arr objectAtIndex:4];
    }
}

- (void)initViews {
    self.pickVc.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:self.pickVc];
}

- (void)setType:(MMPickerFormatterStyle)type {
    _type = type;
    [self configComplete];
}

- (void)setHasConfirmButton:(BOOL)hasConfirmButton {
    _hasConfirmButton = hasConfirmButton;
    if (hasConfirmButton) {
        self.pickVc.frame = CGRectMake(0, 44, self.frame.size.width, self.frame.size.height - 44);
        [self addSubview:self.topView];
    } else {
        self.pickVc.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self.topView removeFromSuperview];
    }
}

- (void)cancelAction {
    if (_delegate && [_delegate respondsToSelector:@selector(cancelForPic)]) {
        [_delegate cancelForPic];
    }
}

- (void)confirmAction {
    if (_delegate && [_delegate respondsToSelector:@selector(sureForPic:)]) {
        if (self.type == MMPickerFormatterStyleDefault) {
            [_delegate sureForPic:[self separateDate:self.value]];
        } else if (self.type == MMPickerFormatterStyleLongTime) {
            NSArray *arr             = [self.value componentsSeparatedByString:@" "];
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self separateDate:[arr objectAtIndex:0]]];

            NSArray *timeItem = [[arr objectAtIndex:1] componentsSeparatedByString:@":"];
            [dic setObject:[timeItem objectAtIndex:0] forKey:@"hour"];
            [dic setObject:[timeItem objectAtIndex:1] forKey:@"minute"];
            [_delegate sureForPic:dic];
        } else if (self.type == MMPickerFormatterStyleTime) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            NSArray *timeItem        = [self.value componentsSeparatedByString:@":"];
            [dic setObject:[timeItem objectAtIndex:0] forKey:@"hour"];
            [dic setObject:[timeItem objectAtIndex:1] forKey:@"minute"];
            [_delegate sureForPic:dic];
        } else if (self.type == MMPickerFormatterStyleMonth) {
            [_delegate sureForPic:[self separateDate:self.value]];
        }
    }
}

- (NSMutableDictionary *)separateDate:(NSString *)value {
    NSArray *arr             = [value componentsSeparatedByString:@"-"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[arr objectAtIndex:0] forKey:@"year"];
    [dic setObject:[arr objectAtIndex:1] forKey:@"month"];
    if (arr.count > 2) {
        [dic setObject:[arr objectAtIndex:2] forKey:@"day"];
    }
    return dic;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.pickVc.frame = CGRectMake(0, 44, self.frame.size.width, self.frame.size.height - 44);
}

#pragma mark method

- (void)configComplete {
    NSDate *current = [NSDate date];
    if (self.type == MMPickerFormatterStyleDefault) {
        //        NSDateFormatter * dateformatter=[[NSDateFormatter alloc] init];
        //        [dateformatter setDateFormat:@"yyyy-MM-dd"];
        self.defaultData = [MMDateUtil getDateStringFromDate:current format:@"yyyy-MM-dd"]; // [dateformatter stringFromDate:current];

        NSArray *items = [self.defaultData componentsSeparatedByString:@"-"];

        NSString *year  = [items objectAtIndex:0];
        NSString *month = [items objectAtIndex:1];
        NSString *day   = [items objectAtIndex:2];

        self.dataSource = [NSMutableArray array];
        [self.dataSource addObject:[MMPickerUtil yearList]];
        [self.dataSource addObject:[MMPickerUtil monthList]];
        [self.dataSource addObject:[MMPickerUtil dayList:[self checkYear:year month:month]]];
        [self.pickVc reloadAllComponents];

        NSArray *years = [self.dataSource objectAtIndex:0];
        [self.pickVc selectRow:[years indexOfObject:year] inComponent:0 animated:NO];

        NSArray *months = [self.dataSource objectAtIndex:1];
        [self.pickVc selectRow:[months indexOfObject:month] inComponent:1 animated:NO];

        NSArray *days = [self.dataSource objectAtIndex:2];
        [self.pickVc selectRow:[days indexOfObject:day] inComponent:2 animated:NO];

    } else if (self.type == MMPickerFormatterStyleLongTime) {
        //        NSDateFormatter * dateformatter=[[NSDateFormatter alloc] init];
        //        [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        self.defaultData = [MMDateUtil getDateStringFromDate:current format:@"yyyy-MM-dd HH:mm"]; //[dateformatter stringFromDate:current];

        NSArray *items    = [self.defaultData componentsSeparatedByString:@" "];
        NSString *dataStr = [items objectAtIndex:0];
        NSString *timeStr = [items objectAtIndex:1];

        NSArray *dataArr = [dataStr componentsSeparatedByString:@"-"];
        NSString *year   = [dataArr objectAtIndex:0];
        NSString *month  = [dataArr objectAtIndex:1];
        NSString *day    = [dataArr objectAtIndex:2];

        NSArray *timeArr = [timeStr componentsSeparatedByString:@":"];
        NSString *hour   = [timeArr objectAtIndex:0];
        NSString *minute = [timeArr objectAtIndex:1];

        self.dataSource = [NSMutableArray array];
        [self.dataSource addObject:[MMPickerUtil yearList]];
        [self.dataSource addObject:[MMPickerUtil monthList]];
        [self.dataSource addObject:[MMPickerUtil dayList:[self checkYear:year month:month]]];
        [self.dataSource addObject:[MMPickerUtil hourList]];
        [self.dataSource addObject:[MMPickerUtil minuteList]];
        [self.pickVc reloadAllComponents];

        NSArray *years = [self.dataSource objectAtIndex:0];
        [self.pickVc selectRow:[years indexOfObject:year] inComponent:0 animated:NO];

        NSArray *months = [self.dataSource objectAtIndex:1];
        [self.pickVc selectRow:[months indexOfObject:month] inComponent:1 animated:NO];

        NSArray *days = [self.dataSource objectAtIndex:2];
        [self.pickVc selectRow:[days indexOfObject:day] inComponent:2 animated:NO];

        NSArray *hours = [self.dataSource objectAtIndex:3];
        [self.pickVc selectRow:[hours indexOfObject:hour] inComponent:3 animated:NO];

        NSArray *minutes = [self.dataSource objectAtIndex:4];
        [self.pickVc selectRow:[minutes indexOfObject:minute] inComponent:4 animated:NO];
    } else if (self.type == MMPickerFormatterStyleTime) {
        //        NSDateFormatter * dateformatter=[[NSDateFormatter alloc] init];
        //        [dateformatter setDateFormat:@"HH:mm"];
        self.defaultData = [MMDateUtil getDateStringFromDate:current format:@"HH:mm"]; //[dateformatter stringFromDate:current];

        NSArray *timeArr = [self.defaultData componentsSeparatedByString:@":"];
        NSString *hour   = [timeArr objectAtIndex:0];
        NSString *minute = [timeArr objectAtIndex:1];
        self.dataSource  = [NSMutableArray array];
        [self.dataSource addObject:[MMPickerUtil hourList]];
        [self.dataSource addObject:[MMPickerUtil minuteList]];
        [self.pickVc reloadAllComponents];

        NSArray *hours = [self.dataSource objectAtIndex:0];
        [self.pickVc selectRow:[hours indexOfObject:hour] inComponent:0 animated:NO];

        NSArray *minutes = [self.dataSource objectAtIndex:1];
        [self.pickVc selectRow:[minutes indexOfObject:minute] inComponent:1 animated:NO];
    } else if (self.type == MMPickerFormatterStyleMonth) {
        //        NSDateFormatter * dateformatter=[[NSDateFormatter alloc] init];
        //        [dateformatter setDateFormat:@"yyyy-MM"];
        self.defaultData = [MMDateUtil getDateStringFromDate:current format:@"yyyy-MM"]; //[dateformatter stringFromDate:current];

        NSArray *dataArr = [self.defaultData componentsSeparatedByString:@"-"];
        NSString *year   = [dataArr objectAtIndex:0];
        NSString *month  = [dataArr objectAtIndex:1];

        self.dataSource = [NSMutableArray array];
        [self.dataSource addObject:[MMPickerUtil yearList]];
        [self.dataSource addObject:[MMPickerUtil monthList]];

        [self.pickVc reloadAllComponents];
        NSArray *years = [self.dataSource objectAtIndex:0];
        [self.pickVc selectRow:[years indexOfObject:year] inComponent:0 animated:NO];

        NSArray *months = [self.dataSource objectAtIndex:1];
        [self.pickVc selectRow:[months indexOfObject:month] inComponent:1 animated:NO];
    } else if (self.type == MMPickerFormatterStyleCustom) {
        //        NSDateFormatter * dateformatter=[[NSDateFormatter alloc] init];
        //        [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm"];

        NSString *nowTime = [MMDateUtil getDateStringFromDate:current format:@"yyyy-MM-dd HH:mm"]; //[dateformatter stringFromDate:current];
        NSString *min     = [nowTime componentsSeparatedByString:@":"].lastObject;
        NSInteger min2    = [min integerValue];
        NSInteger resu    = 0;
        if (min2 == 59) {
            resu = 0;
        } else {
            resu = min2 + 1;
        }
        self.defaultData = [NSString stringWithFormat:@"%@:%@", [nowTime componentsSeparatedByString:@":"].firstObject, resu < 10 ? [NSString stringWithFormat:@"0%ld", resu] : [NSString stringWithFormat:@"%ld", resu]];

        //        self.defaultData = [dateformatter stringFromDate:current];

        NSArray *items    = [self.defaultData componentsSeparatedByString:@" "];
        NSString *dataStr = [items objectAtIndex:0];
        NSString *timeStr = [items objectAtIndex:1];

        NSArray *dataArr = [dataStr componentsSeparatedByString:@"-"];
        NSString *year   = [dataArr objectAtIndex:0];
        NSString *month  = [dataArr objectAtIndex:1];
        NSString *day    = [dataArr objectAtIndex:2];

        NSArray *timeArr = [timeStr componentsSeparatedByString:@":"];
        NSString *hour   = [timeArr objectAtIndex:0];
        NSString *minute = [timeArr objectAtIndex:1];

        self.dataSource = [NSMutableArray array];

        [self.dataSource addObject:[MMPickerUtil yearList2]];
        [self.dataSource addObject:[MMPickerUtil monthList2:month]];
        [self.dataSource addObject:[MMPickerUtil dayList2:[self checkYear:self.year month:month] toDay:day]];
        [self.dataSource addObject:[MMPickerUtil hourList2:hour]];
        [self.dataSource addObject:[MMPickerUtil minuteList2:minute]];
        [self.pickVc reloadAllComponents];

        NSArray *years = [self.dataSource objectAtIndex:0];
        [self.pickVc selectRow:[years indexOfObject:year] inComponent:0 animated:NO];

        NSArray *months = [self.dataSource objectAtIndex:1];
        [self.pickVc selectRow:[months indexOfObject:month] inComponent:1 animated:NO];

        NSArray *days = [self.dataSource objectAtIndex:2];
        [self.pickVc selectRow:[days indexOfObject:day] inComponent:2 animated:NO];

        NSArray *hours = [self.dataSource objectAtIndex:3];
        [self.pickVc selectRow:[hours indexOfObject:hour] inComponent:3 animated:NO];

        NSArray *minutes = [self.dataSource objectAtIndex:4];
        [self.pickVc selectRow:[minutes indexOfObject:minute] inComponent:4 animated:NO];
    }
}

- (NSString *)value {
    if (self.type == MMPickerFormatterStyleDefault) {
        NSArray *years  = [self.dataSource objectAtIndex:0];
        NSArray *months = [self.dataSource objectAtIndex:1];
        NSArray *days   = [self.dataSource objectAtIndex:2];

        NSString *year  = [years objectAtIndex:[self.pickVc selectedRowInComponent:0]];
        NSString *month = [months objectAtIndex:[self.pickVc selectedRowInComponent:1]];
        NSString *day   = [days objectAtIndex:[self.pickVc selectedRowInComponent:2]];

        return [NSString stringWithFormat:@"%@-%@-%@", year, month, day];
    } else if (self.type == MMPickerFormatterStyleLongTime) {
        NSArray *years   = [self.dataSource objectAtIndex:0];
        NSArray *months  = [self.dataSource objectAtIndex:1];
        NSArray *days    = [self.dataSource objectAtIndex:2];
        NSArray *hours   = [self.dataSource objectAtIndex:3];
        NSArray *minutes = [self.dataSource objectAtIndex:4];
        //        NSArray * seconds = [self.dataSource objectAtIndex:5];

        NSString *year   = [years objectAtIndex:[self.pickVc selectedRowInComponent:0]];
        NSString *month  = [months objectAtIndex:[self.pickVc selectedRowInComponent:1]];
        NSString *day    = [days objectAtIndex:[self.pickVc selectedRowInComponent:2]];
        NSString *hour   = [hours objectAtIndex:[self.pickVc selectedRowInComponent:3]];
        NSString *minute = [minutes objectAtIndex:[self.pickVc selectedRowInComponent:4]];
        //        NSString * second = [seconds objectAtIndex:[self.pickVc selectedRowInComponent:5]];

        //        return [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@",year,month,day,hour,minute,second];
        return [NSString stringWithFormat:@"%@-%@-%@ %@:%@", year, month, day, hour, minute];
    } else if (self.type == MMPickerFormatterStyleTime) {
        NSArray *hours   = [self.dataSource objectAtIndex:0];
        NSArray *minutes = [self.dataSource objectAtIndex:1];
        NSString *hour   = [hours objectAtIndex:[self.pickVc selectedRowInComponent:0]];
        NSString *minute = [minutes objectAtIndex:[self.pickVc selectedRowInComponent:1]];
        return [NSString stringWithFormat:@"%@:%@", hour, minute];
    } else if (self.type == MMPickerFormatterStyleMonth) {
        NSArray *years  = [self.dataSource objectAtIndex:0];
        NSArray *months = [self.dataSource objectAtIndex:1];
        NSString *year  = [years objectAtIndex:[self.pickVc selectedRowInComponent:0]];
        NSString *month = [months objectAtIndex:[self.pickVc selectedRowInComponent:1]];
        return [NSString stringWithFormat:@"%@-%@", year, month];
    } else if (self.type == MMPickerFormatterStyleCustom) {
        NSArray *years   = [self.dataSource objectAtIndex:0];
        NSArray *months  = [self.dataSource objectAtIndex:1];
        NSArray *days    = [self.dataSource objectAtIndex:2];
        NSArray *hours   = [self.dataSource objectAtIndex:3];
        NSArray *minutes = [self.dataSource objectAtIndex:4];

        NSString *year   = [years objectAtIndex:[self.pickVc selectedRowInComponent:0]];
        NSString *month  = [months objectAtIndex:[self.pickVc selectedRowInComponent:1]];
        NSString *day    = [days objectAtIndex:[self.pickVc selectedRowInComponent:2]];
        NSString *hour   = [hours objectAtIndex:[self.pickVc selectedRowInComponent:3]];
        NSString *minute = [minutes objectAtIndex:[self.pickVc selectedRowInComponent:4]];
        return [NSString stringWithFormat:@"%@-%@-%@ %@:%@", year, month, day, hour, minute];
    }
    return @"";
}

// return 1 每个月有31天  2 每个月有30天  3 每个月有28天 4 每个月有29天
- (NSInteger)checkYear:(NSString *)year month:(NSString *)month {
    NSInteger value = [month intValue];
    int yearValue   = [year intValue];
    BOOL isRun      = [MMPickerUtil bissextile:yearValue];
    if (value == 1 || value == 3 || value == 5 || value == 7 || value == 8 || value == 10 || value == 12) {
        return 1;
    } else if (value == 2) {
        if (isRun) {
            return 4;
        } else {
            return 3;
        }
    } else {
        return 2;
    }
    return 0;
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.dataSource.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *arr = [self.dataSource objectAtIndex:component];
    return arr.count;
}

#pragma mark UIPickerViewDelegate

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (self.type == MMPickerFormatterStyleDefault ||
        self.type == MMPickerFormatterStyleLongTime ||
        self.type == MMPickerFormatterStyleTime ||
        self.type == MMPickerFormatterStyleMonth ||
        self.type == MMPickerFormatterStyleCustom) {
        NSArray *arr  = [self.dataSource objectAtIndex:component];
        NSString *str = [arr objectAtIndex:row];
        if (component == 0) {
            return [NSString stringWithFormat:@"%@", str];
        } else if (component == 1) {
            return [NSString stringWithFormat:@"%@", str];
        } else if (component == 2) {
            return [NSString stringWithFormat:@"%@", str];
        } else if (component == 3) {
            return [NSString stringWithFormat:@"%@", str];
        } else if (component == 4) {
            return [NSString stringWithFormat:@"%@", str];
        }
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.type == MMPickerFormatterStyleDefault ||
        self.type == MMPickerFormatterStyleLongTime) {
        NSArray *arr  = [self.dataSource objectAtIndex:component];
        NSString *str = [arr objectAtIndex:row];

        NSArray *years  = [self.dataSource objectAtIndex:0];
        NSArray *months = [self.dataSource objectAtIndex:1];

        switch (component) {
            case 0:
                [self.dataSource replaceObjectAtIndex:2 withObject:[MMPickerUtil dayList:[self checkYear:str month:[months objectAtIndex:[self.pickVc selectedRowInComponent:1]]]]];
                [self.pickVc reloadComponent:2];
                break;
            case 1:
                [self.dataSource replaceObjectAtIndex:2 withObject:[MMPickerUtil dayList:[self checkYear:[years objectAtIndex:[self.pickVc selectedRowInComponent:0]] month:str]]];
                [self.pickVc reloadComponent:2];
                break;
            default:
                break;
        }
    } else if (self.type == MMPickerFormatterStyleCustom) {
        [self updateNowTime];
        NSArray *arr    = [self.dataSource objectAtIndex:component];
        NSString *str   = [arr objectAtIndex:row];
        NSInteger value = [str integerValue];

        switch (component) {
            case 0:
                if (value == [self.year integerValue]) {
                    [self.dataSource replaceObjectAtIndex:1 withObject:[MMPickerUtil monthList2:self.mouth]];
                    [self scrollComponent:1];

                    NSArray *months = [self.dataSource objectAtIndex:1];
                    NSString *month = [months objectAtIndex:[self.pickVc selectedRowInComponent:1]];
                    if ([month integerValue] == [self.mouth integerValue]) {
                        [self.dataSource replaceObjectAtIndex:2 withObject:[MMPickerUtil dayList2:[self checkYear:[NSString stringWithFormat:@"%ld", value] month:str] toDay:self.day]];
                        [self scrollComponent:2];

                        NSArray *days = [self.dataSource objectAtIndex:2];
                        NSString *day = [days objectAtIndex:[self.pickVc selectedRowInComponent:2]];
                        if ([day integerValue] == [self.day integerValue]) {
                            [self.dataSource replaceObjectAtIndex:3 withObject:[MMPickerUtil hourList2:self.hour]];
                            [self scrollComponent:3];

                            NSArray *hours = [self.dataSource objectAtIndex:3];
                            NSString *hour = [hours objectAtIndex:[self.pickVc selectedRowInComponent:3]];
                            if ([hour integerValue] == [self.hour integerValue]) {
                                [self.dataSource replaceObjectAtIndex:4 withObject:[MMPickerUtil minuteList2:self.minute]];
                                [self scrollComponent:4];
                            } else {
                                [self.dataSource replaceObjectAtIndex:4 withObject:[MMPickerUtil minuteList]];
                            }
                        } else {
                            [self.dataSource replaceObjectAtIndex:3 withObject:[MMPickerUtil hourList]];
                            [self.dataSource replaceObjectAtIndex:4 withObject:[MMPickerUtil minuteList]];
                        }
                    } else {
                        [self.dataSource replaceObjectAtIndex:2 withObject:[MMPickerUtil dayList2:[self checkYear:[NSString stringWithFormat:@"%ld", value] month:str] toDay:@"--"]];
                        [self.dataSource replaceObjectAtIndex:3 withObject:[MMPickerUtil hourList]];
                        [self.dataSource replaceObjectAtIndex:4 withObject:[MMPickerUtil minuteList]];
                    }
                } else {
                    [self.dataSource replaceObjectAtIndex:1 withObject:[MMPickerUtil monthList2:@"1"]];
                    [self.dataSource replaceObjectAtIndex:2 withObject:[MMPickerUtil dayList2:[self checkYear:[NSString stringWithFormat:@"%ld", value] month:str] toDay:@"--"]];
                    [self.dataSource replaceObjectAtIndex:3 withObject:[MMPickerUtil hourList]];
                    [self.dataSource replaceObjectAtIndex:4 withObject:[MMPickerUtil minuteList]];
                    [self.pickVc reloadAllComponents];
                }
                break;
            case 1: {
                NSArray *years = [self.dataSource objectAtIndex:0];
                NSString *year = [years objectAtIndex:[self.pickVc selectedRowInComponent:0]];
                if (value == [self.mouth integerValue] && [year integerValue] == [self.year integerValue]) {
                    [self.dataSource replaceObjectAtIndex:2 withObject:[MMPickerUtil dayList2:[self checkYear:self.year month:str] toDay:self.day]];

                    [self scrollComponent:2];

                    NSArray *days = [self.dataSource objectAtIndex:2];
                    NSString *day = [days objectAtIndex:[self.pickVc selectedRowInComponent:2]];
                    if ([day integerValue] == [self.day integerValue]) {
                        [self.dataSource replaceObjectAtIndex:3 withObject:[MMPickerUtil hourList2:self.hour]];

                        [self scrollComponent:3];

                        NSArray *hours = [self.dataSource objectAtIndex:3];
                        NSString *hour = [hours objectAtIndex:[self.pickVc selectedRowInComponent:3]];
                        if ([hour integerValue] == [self.hour integerValue]) {
                            [self.dataSource replaceObjectAtIndex:4 withObject:[MMPickerUtil minuteList2:self.minute]];
                            [self scrollComponent:4];
                        } else {
                            [self.dataSource replaceObjectAtIndex:4 withObject:[MMPickerUtil minuteList]];
                            [self.pickVc reloadComponent:4];
                        }
                    } else {
                        [self.dataSource replaceObjectAtIndex:3 withObject:[MMPickerUtil hourList]];
                        [self.pickVc reloadComponent:3];
                    }
                } else {
                    [self.dataSource replaceObjectAtIndex:2 withObject:[MMPickerUtil dayList2:[self checkYear:self.year month:str] toDay:@"--"]];
                    [self.dataSource replaceObjectAtIndex:3 withObject:[MMPickerUtil hourList]];
                    [self.dataSource replaceObjectAtIndex:4 withObject:[MMPickerUtil minuteList]];
                    [self.pickVc reloadAllComponents];
                }
                break;
            }
            case 2: {
                NSArray *years = [self.dataSource objectAtIndex:0];
                NSString *year = [years objectAtIndex:[self.pickVc selectedRowInComponent:0]];

                NSArray *mouths = [self.dataSource objectAtIndex:1];
                NSString *mouth = [mouths objectAtIndex:[self.pickVc selectedRowInComponent:1]];
                if (value == [self.day integerValue] && [mouth integerValue] == [self.mouth integerValue] && [year integerValue] == [self.year integerValue]) {
                    [self.dataSource replaceObjectAtIndex:3 withObject:[MMPickerUtil hourList2:self.hour]];

                    [self scrollComponent:3];

                    NSArray *hours = [self.dataSource objectAtIndex:3];
                    NSString *hour = [hours objectAtIndex:[self.pickVc selectedRowInComponent:3]];
                    if ([hour integerValue] == [self.hour integerValue]) {
                        [self.dataSource replaceObjectAtIndex:4 withObject:[MMPickerUtil minuteList2:self.minute]];
                        [self scrollComponent:4];
                    } else {
                        [self.dataSource replaceObjectAtIndex:4 withObject:[MMPickerUtil minuteList]];
                        [self.pickVc reloadComponent:4];
                    }
                } else {
                    [self.dataSource replaceObjectAtIndex:3 withObject:[MMPickerUtil hourList]];
                    [self.dataSource replaceObjectAtIndex:4 withObject:[MMPickerUtil minuteList]];
                    [self.pickVc reloadAllComponents];
                }
                break;
            }
            case 3: {
                NSArray *years = [self.dataSource objectAtIndex:0];
                NSString *year = [years objectAtIndex:[self.pickVc selectedRowInComponent:0]];

                NSArray *mouths = [self.dataSource objectAtIndex:1];
                NSString *mouth = [mouths objectAtIndex:[self.pickVc selectedRowInComponent:1]];

                NSArray *days = [self.dataSource objectAtIndex:2];
                NSString *day = [days objectAtIndex:[self.pickVc selectedRowInComponent:2]];
                if (value == [self.hour integerValue] &&
                    [mouth integerValue] == [self.mouth integerValue] &&
                    [day integerValue] == [self.day integerValue] &&
                    [year integerValue] == [self.year integerValue]) {
                    [self.dataSource replaceObjectAtIndex:4 withObject:[MMPickerUtil minuteList2:self.minute]];
                    [self scrollComponent:4];
                } else {
                    [self.dataSource replaceObjectAtIndex:4 withObject:[MMPickerUtil minuteList]];
                    [self.pickVc reloadComponent:4];
                }
                break;
            }
            default:
                break;
        }
    }

    if (_delegate && [_delegate respondsToSelector:@selector(mmpickerDidChange:)]) {
        [_delegate mmpickerDidChange:self];
    }
}

- (void)scrollComponent:(NSInteger)index {
    [self.pickVc reloadComponent:index];
    [self.pickVc selectRow:0 inComponent:index animated:YES];
}

#pragma mark lazyLoad

- (UIButton *)createCustomButton:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:UIColorFromRGB(0x4F7AFD) forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIPickerView *)pickVc {
    if (!_pickVc) {
        _pickVc            = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _pickVc.delegate   = self;
        _pickVc.dataSource = self;
    }
    return _pickVc;
}

- (UIView *)topView {
    if (!_topView) {
        _topView                 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
        _topView.backgroundColor = [UIColor whiteColor];

        UIButton *cancel = [self createCustomButton:@"取消" action:@selector(cancelAction)];
        cancel.frame     = CGRectMake(16, 0, 40, 44);
        [_topView addSubview:cancel];
        UIButton *confirm = [self createCustomButton:@"确定" action:@selector(confirmAction)];
        confirm.frame     = CGRectMake(MM_MainScreenWidth - 40 - 16, 0, 40, 44);
        [_topView addSubview:confirm];
    }
    return _topView;
}

@end
