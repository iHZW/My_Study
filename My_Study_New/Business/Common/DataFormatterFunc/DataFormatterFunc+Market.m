//
//  DataFormatterFunc+Market.m
//  FormaterLib
//
//  Created by Howard on 2019/3/15.
//

#import "DataFormatterFunc+Market.h"

unsigned int LunarCalendarTable[199] = {
    
    0x04AE53,0x0A5748,0x5526BD,0x0D2650,0x0D9544,0x46AAB9,0x056A4D,0x09AD42,0x24AEB6,0x04AE4A,/*1901-1910*/
    
    0x6A4DBE,0x0A4D52,0x0D2546,0x5D52BA,0x0B544E,0x0D6A43,0x296D37,0x095B4B,0x749BC1,0x049754,/*1911-1920*/
    
    0x0A4B48,0x5B25BC,0x06A550,0x06D445,0x4ADAB8,0x02B64D,0x095742,0x2497B7,0x04974A,0x664B3E,/*1921-1930*/
    
    0x0D4A51,0x0EA546,0x56D4BA,0x05AD4E,0x02B644,0x393738,0x092E4B,0x7C96BF,0x0C9553,0x0D4A48,/*1931-1940*/
    
    0x6DA53B,0x0B554F,0x056A45,0x4AADB9,0x025D4D,0x092D42,0x2C95B6,0x0A954A,0x7B4ABD,0x06CA51,/*1941-1950*/
    
    0x0B5546,0x555ABB,0x04DA4E,0x0A5B43,0x352BB8,0x052B4C,0x8A953F,0x0E9552,0x06AA48,0x6AD53C,/*1951-1960*/
    
    0x0AB54F,0x04B645,0x4A5739,0x0A574D,0x052642,0x3E9335,0x0D9549,0x75AABE,0x056A51,0x096D46,/*1961-1970*/
    
    0x54AEBB,0x04AD4F,0x0A4D43,0x4D26B7,0x0D254B,0x8D52BF,0x0B5452,0x0B6A47,0x696D3C,0x095B50,/*1971-1980*/
    
    0x049B45,0x4A4BB9,0x0A4B4D,0xAB25C2,0x06A554,0x06D449,0x6ADA3D,0x0AB651,0x093746,0x5497BB,/*1981-1990*/
    
    0x04974F,0x064B44,0x36A537,0x0EA54A,0x86B2BF,0x05AC53,0x0AB647,0x5936BC,0x092E50,0x0C9645,/*1991-2000*/
    
    0x4D4AB8,0x0D4A4C,0x0DA541,0x25AAB6,0x056A49,0x7AADBD,0x025D52,0x092D47,0x5C95BA,0x0A954E,/*2001-2010*/
    
    0x0B4A43,0x4B5537,0x0AD54A,0x955ABF,0x04BA53,0x0A5B48,0x652BBC,0x052B50,0x0A9345,0x474AB9,/*2011-2020*/
    
    0x06AA4C,0x0AD541,0x24DAB6,0x04B64A,0x69573D,0x0A4E51,0x0D2646,0x5E933A,0x0D534D,0x05AA43,/*2021-2030*/
    
    0x36B537,0x096D4B,0xB4AEBF,0x04AD53,0x0A4D48,0x6D25BC,0x0D254F,0x0D5244,0x5DAA38,0x0B5A4C,/*2031-2040*/
    
    0x056D41,0x24ADB6,0x049B4A,0x7A4BBE,0x0A4B51,0x0AA546,0x5B52BA,0x06D24E,0x0ADA42,0x355B37,/*2041-2050*/
    
    0x09374B,0x8497C1,0x049753,0x064B48,0x66A53C,0x0EA54F,0x06B244,0x4AB638,0x0AAE4C,0x092E42,/*2051-2060*/
    
    0x3C9735,0x0C9649,0x7D4ABD,0x0D4A51,0x0DA545,0x55AABA,0x056A4E,0x0A6D43,0x452EB7,0x052D4B,/*2061-2070*/
    
    0x8A95BF,0x0A9553,0x0B4A47,0x6B553B,0x0AD54F,0x055A45,0x4A5D38,0x0A5B4C,0x052B42,0x3A93B6,/*2071-2080*/
    
    0x069349,0x7729BD,0x06AA51,0x0AD546,0x54DABA,0x04B64E,0x0A5743,0x452738,0x0D264A,0x8E933E,/*2081-2090*/
    
    0x0D5252,0x0DAA47,0x66B53B,0x056D4F,0x04AE45,0x4A4EB9,0x0A4D4C,0x0D1541,0x2D92B5          /*2091-2099*/
    
};

@implementation DataFormatterFunc (Market)

+ (NSString *)FormatDStr:(float)v len:(int)len dig:(int)dig
{
    NSInteger ln, rn;
    char floatstr[64];
    char temp[2];
    char formatStr[10];
    char formatStr2[10] = {'%'};
    
    NSString *strRetVal = nil;
    
    [self itoa:dig c:temp];
    sprintf(formatStr, ".%sf", temp);
    strcat(formatStr2, formatStr);
    sprintf(floatstr, formatStr2, v);
    
    NSString * vv = [NSString stringWithUTF8String:floatstr];
    NSRange rang     = [vv rangeOfString:@"."];
    ln                 = rang.location;
    rn                 = [vv length] - ln - 1;
    
    if (rang.location != NSNotFound)
    {
        NSRange subrang;
        NSString *rightstr;
        subrang.location     = 0;
        subrang.length         = MAX(ln, 0);
        NSString *leftstr     = [vv substringWithRange:subrang];
        subrang.location     = ln + 1;
        subrang.length         = MAX(rn, 0);
        NSString *rightstro = [vv substringWithRange:subrang];
        NSInteger over             = [vv length] - len;
        
        if (over > 0)
        {
            NSRange r;
            r.location     = 0;
            r.length     = MIN([rightstro length] - over, [rightstro length]);
            rightstr     = [rightstro substringWithRange:r];
        }
        else
            rightstr = rightstro;
        
        if ([rightstr length] > 0 && [leftstr length] < len)
            strRetVal = [NSString stringWithFormat:@"%@.%@", leftstr, rightstr];
        else
            strRetVal = leftstr;
    }
    else
        strRetVal = vv;
    
    return strRetVal;
}

+ (char *)itoa:(int)n c:(char *)c
{
    char *pHead = c;
    
    int i,sign;
    
    if((sign=n)<0)
        n=-n;
    
    i=0;
    
    do
    {
        c[i++]=n%10+'0';
    }while ((n/=10)>0);
    
    if(sign<0)
        c[i++]='-';
    c[i]='\0';
    
    return pHead;
}

+ (NSString *)formatDate:(int)date flag:(NSString *)flag
{
    if (date <= 0) return @"-";
    //如20110525 ==> 11/5/25
    int day        = date % 100;
    int month    = (date / 100) % 100;
    int year    = (date / 10000);
    return [NSString stringWithFormat:@"%d%@%@%d%@%@%d", year, flag, month<10?@"0":@"", month, flag, day<10?@"0":@"", day];
}

+ (NSString *)formatDate:(NSString *)dateTime srcFormat:(NSString *)srcFormat destFormat:(NSString *)destFormat
{
    if (dateTime == nil) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:srcFormat];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    NSDate *curDataTime = [formatter dateFromString:dateTime];
    
    [formatter setDateFormat:destFormat];
    NSString *formatDate = [formatter stringFromDate:curDataTime];
    
    
    return formatDate;
}

+ (NSTimeInterval)getCurTick
{
    return [NSDate timeIntervalSinceReferenceDate];
}

+ (NSString *)getDate:(NSString*)curDateStr
{
    NSArray * timeArray = [curDateStr componentsSeparatedByString:@" "];
    
    if ([timeArray count] > 0)
    {
        return [timeArray objectAtIndex:0];
    }else
    {
        return curDateStr;
    }
    
}

//+ (NSTimeInterval)getReferenceTick
//{
//    return [NSDate dateWithTimeIntervalSinceReferenceDate:0];
//}

// NSDate* ==> numDate(20110930)
+ (int)getNumDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString * sDate = [formatter stringFromDate:date];
    return [sDate intValue];
}

// numDate(20110930) ==> NSDate*
+ (NSDate *)getDateFromNumDate:(int)numDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSDate * aDate = [formatter dateFromString:[NSString stringWithFormat:@"%d", numDate]];
    return aDate;
}

+ (NSString *)getCurrentDateTimeWithFormatter:(NSString *)formatterStr
{
    NSString *dateVal = nil;
    if ([formatterStr length] > 0)
    {
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:formatterStr];
        dateVal = [formatter stringFromDate:date];
    }
    return dateVal;
}

// NSDateComponents类型的weekday ==> 中国式星期几
+ (int)getCNWeekDay:(int)dateComponentsWeekDay
{
    if (dateComponentsWeekDay == 1)
        return 7;
    else
        return dateComponentsWeekDay - 1;
    //    1－－星期天
    //    2－－星期一
    //    3－－星期二
    //    4－－星期三
    //    5－－星期四
    //    6－－星期五
    //    7－－星期六
}

+ (NSDate *)IncDate:(NSDate *)date withDay:(int)day
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    [componentsToAdd setDay:day];
    NSDate * newDate = [calendar dateByAddingComponents:componentsToAdd toDate:date options:0];
    return newDate;
}

// numDate: 20110930
// 返回周一的数字日期
+ (int)getBeginningOfWeekNumDate:(int)numDate
{
    NSDate *aDate = [DataFormatterFunc getDateFromNumDate:numDate];
    if (aDate == nil) return 0;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *weekDayComponents = [calendar components:NSCalendarUnitWeekday fromDate:aDate];
    int CNWeekDay = [DataFormatterFunc getCNWeekDay:(int)[weekDayComponents weekday]];
    
    if (CNWeekDay == 1)        //星期一
        return numDate;
    else {
        NSDate * mondayDate = [DataFormatterFunc IncDate:aDate withDay:1-CNWeekDay];
        return [DataFormatterFunc getNumDate:mondayDate];
    }
}

// numDate(20110930) ==> 20110901
+ (int)getBeginningOfMonthNumDate:(int)numDate
{
    return numDate / 100 * 100 + 1;
}

// numDate: 20110930
// pweekday: 返回星期几，已转化为中国习惯。
// pweek: 一年中第几周
+ (BOOL)getWeekday:(int)numDate pweekday:(int *)pweekday pweek:(int *)pweek
{
    NSDate *aDate = [DataFormatterFunc getDateFromNumDate:numDate];
    if (aDate == nil) return NO;
    
    NSCalendar *gregorian               = [NSCalendar currentCalendar];
    NSDateComponents *weekDayComponents = [gregorian components:(NSCalendarUnitWeekOfYear | NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekday) fromDate:aDate];
    NSInteger week                      = [weekDayComponents weekOfYear];
    NSInteger weekday                   = [weekDayComponents weekday];
    *pweekday                           = (int)[DataFormatterFunc getCNWeekDay:(int)weekday];
    *pweek                              = (int)week;
    
    return YES;
}

// numDate: 20110930
// pweekday: 返回星期几，已转化为中国习惯。
// pweek: 一年中第几周
+ (BOOL)getMonthday:(int)numDate pday:(int *)pday pmonth:(int *)pmonth
{
    *pday = numDate % 100;
    *pmonth = (numDate / 100) % 100;
    return YES;
}

+ (NSTimeInterval)getDateFrom:(NSString *)fromDate toDate:(NSString *)toDate;
{
    NSTimeInterval time = 0;
    
    if ([fromDate length] > 0 && [toDate length] > 0)
    {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate * dateDeadLine = [formatter dateFromString:toDate];
        NSDate * dateNow = [formatter dateFromString:fromDate];
        time = [dateDeadLine timeIntervalSinceDate:dateNow];
    }
    
    return time;
}

+ (NSString *)getDataStrWith:(NSTimeInterval)timeNum
{
    if(timeNum >= 0)
    {
        //timeNum -- ;
        NSInteger days = ((NSInteger)timeNum) / (3600 * 24);
        NSInteger hours = (((NSInteger)timeNum) - (3600 * 24) * days) / 3600;
        NSInteger mins = (((NSInteger)timeNum) - (3600 * 24) * days - 3600 * hours) / 60;
        NSInteger seconds = ((NSInteger)timeNum) - (3600 * 24) * days - 3600 * hours - 60 * mins;
        hours += days *24;
        return [NSString stringWithFormat:@"%02ld时%02ld分%02ld秒", (long)hours, (long)mins, (long)seconds];
    }
    else
    {
        return @"--小时--分--秒";
    }
}

+ (NSString *)getDataStrWithMS:(NSTimeInterval)timeNum
{
    if(timeNum > 0)
    {
        //  timeNum -- ;
        NSInteger days = ((NSInteger)timeNum) / (3600 * 24);
        NSInteger hours = (((NSInteger)timeNum) - (3600 * 24) * days) / 3600;
        NSInteger mins = (((NSInteger)timeNum) - (3600 * 24) * days - 3600 * hours) / 60;
        NSInteger seconds = ((NSInteger)timeNum) - (3600 * 24) * days - 3600 * hours - 60 * mins;
        
        NSString *str = [[NSString alloc] initWithFormat:@"%02ld:%02ld", (long)mins, (long)seconds];
        return str;
    }
    else
    {
        return @"00:00";
    }
}

+ (NSString *)getCurrentDateTimeStr:(NSString *)formatStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatStr;
    NSString *todayStr = [dateFormatter stringFromDate:[NSDate date]];
    return todayStr;
}

+ (int)getWeekDay:(int)year month:(int)month day:(int)day
{
    int j,count = 0;
    int MonthAdd[12]    = {0,31,59,90,120,151,181,212,243,273,304,334};
    count = MonthAdd[month-1];
    
    count = count + day;
    
    if (((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) && month >= 3)
        count += 1;
    
    count = count + (year - 1901) * 365;
    
    for (j = 1901; j < year; j++)
    {
        if ((j % 4 == 0 && j % 100 != 0) || (j % 400 == 0))
            count++;
    }
    
    return ((count+1) % 7);
}

+ (unsigned int)lunarCalendarNum:(int)year month:(int)month day:(int)day
{
    unsigned int LunarCalendarDay = 0;
    int MonthAdd[12] = {0,31,59,90,120,151,181,212,243,273,304,334};
    int Spring_NY,Sun_NY,StaticDayCount;
    int index,flag;
    
    //Spring_NY 记录春节离当年元旦的天数。
    //Sun_NY 记录阳历日离当年元旦的天数。
    
    if ( ((LunarCalendarTable[year-1901] & 0x0060) >> 5) == 1)
        Spring_NY = (LunarCalendarTable[year-1901] & 0x001F) - 1;
    else
        Spring_NY = (LunarCalendarTable[year-1901] & 0x001F) - 1 + 31;
    
    Sun_NY = MonthAdd[month-1] + day - 1;
    
    if ((!(year % 4)) && (month > 2)) Sun_NY++;
    
    //StaticDayCount记录大小月的天数 29 或30
    //index 记录从哪个月开始来计算。
    //flag 是用来对闰月的特殊处理。
    //判断阳历日在春节前还是春节后
    
    if (Sun_NY >= Spring_NY)//阳历日在春节后（含春节那天）
    {
        Sun_NY -= Spring_NY;
        month = 1;
        index = 1;
        flag = 0;
        
        if ( ( LunarCalendarTable[year - 1901] & (0x80000 >> (index-1)) ) ==0)
            StaticDayCount = 29;
        else
            StaticDayCount = 30;
        
        while (Sun_NY >= StaticDayCount)
        {
            Sun_NY -= StaticDayCount;
            index++;
            
            if (month == ((LunarCalendarTable[year - 1901] & 0xF00000) >> 20) )
            {
                flag = ~flag;
                
                if (flag == 0) month++;
            }
            else
                month++;
            
            if ((LunarCalendarTable[year - 1901] & (0x80000 >> (index-1))) ==0)
                StaticDayCount=29;
            else
                StaticDayCount=30;
        }
        
        day = Sun_NY + 1;
    }
    else //阳历日在春节前
    {
        Spring_NY -= Sun_NY;
        year--;
        month = 12;
        
        if (((LunarCalendarTable[year - 1901] & 0xF00000) >> 20) == 0)
            index = 12;
        else
            index = 13;
        
        flag = 0;
        
        if ((LunarCalendarTable[year - 1901] & (0x80000 >> (index-1)) ) ==0)
            StaticDayCount = 29;
        else
            StaticDayCount = 30;
        
        while (Spring_NY > StaticDayCount)
        {
            Spring_NY -= StaticDayCount;
            index--;
            
            if (flag == 0)
                month--;
            
            if (month == ((LunarCalendarTable[year - 1901] & 0xF00000) >> 20))
                flag = ~flag;
            
            if ( ( LunarCalendarTable[year - 1901] & (0x80000 >> (index-1)) ) ==0)
                StaticDayCount = 29;
            else
                StaticDayCount = 30;
        }
        
        day = StaticDayCount - Spring_NY + 1;
    }
    
    LunarCalendarDay |= day;
    
    LunarCalendarDay |= (month << 6);
    
    //    if (month == ((LunarCalendarTable[year - 1901] & 0xF00000) >> 20))
    //        return 1;
    //    else
    //        return 0;
    
    return LunarCalendarDay;
}

+ (NSArray *)lunarCalendarMonthAndDay:(unsigned int)lunarCalendarDay
{
    int nIndex1 = (lunarCalendarDay & 0x3C0) >> 6;
    int nIndex2 = lunarCalendarDay & 0x3F;
    
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:nIndex1], [NSNumber numberWithInt:nIndex2], nil];
}

+ (NSString *)lunarCalendarString:(int)year month:(int)month day:(int)day
{
    unsigned int lunarCalendarDay = [self lunarCalendarNum:year month:month day:day];
    NSArray *chDay = [NSArray arrayWithObjects:@"*", @"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九",
                      @"初十", @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九",
                      @"二十", @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十", nil];
    
    NSArray *chMonth = [NSArray arrayWithObjects:@"*", @"正", @"二", @"三", @"四", @"五", @"六", @"七", @"八", @"九", @"十", @"十一", @"腊", nil];
    
    int nIndex1 = (lunarCalendarDay & 0x3C0) >> 6;
    int nIndex2 = lunarCalendarDay & 0x3F;
    
    if (nIndex1 < [chMonth count] && nIndex1 >= 0 && nIndex2 < [chDay count] && nIndex2 >= 0)
        return [NSString stringWithFormat:@"%@月%@", [chMonth objectAtIndex:nIndex1], [chDay objectAtIndex:nIndex2]];
    
    return nil;
}

+ (NSString *)lunarCalendarString:(unsigned int)lunarCalendarDay
{
    NSArray *chDay = [NSArray arrayWithObjects:@"*", @"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九",
                      @"初十", @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九",
                      @"二十", @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十", nil];
    
    NSArray *chMonth = [NSArray arrayWithObjects:@"*", @"正", @"二", @"三", @"四", @"五", @"六", @"七", @"八", @"九", @"十", @"十一", @"腊", nil];
    
    int nIndex1 = (lunarCalendarDay & 0x3C0) >> 6;
    int nIndex2 = lunarCalendarDay & 0x3F;
    
    if (nIndex1 < [chMonth count] && nIndex1 >= 0 && nIndex2 < [chDay count] && nIndex2 >= 0)
        return [NSString stringWithFormat:@"%@月%@", [chMonth objectAtIndex:nIndex1], [chDay objectAtIndex:nIndex2]];
    
    return nil;
}

+ (NSString *)getAstroWithMonth:(int)m day:(int)d
{
    NSString *astroString = @"魔羯水瓶双鱼白羊金牛双子巨蟹狮子处女天秤天蝎射手魔羯";
    NSString *astroFormat = @"102123444543";
    NSString *result      = nil;
    
    if (m < 1 || m > 12 || d < 1 || d > 31 || (m == 2 && d > 29) || ((m == 4 || m == 6 || m == 9 || m == 11) && d > 30))
        return result;
    
    result = [NSString stringWithFormat:@"%@",[astroString substringWithRange:NSMakeRange(m*2-(d < [[astroFormat substringWithRange:NSMakeRange((m-1), 1)] intValue] - (-19))*2,2)]];
    
    return result;
}

// 如果dateStr为2012-02-23，则格式应为yyyy-MM-dd
// 如果dateStr为20120223，则格式应为yyyyMMdd
+ (BOOL)isTodayOfStrDate:(NSString *)dateStr formatStr:(NSString *)formatStr
{
    if (dateStr == nil) return NO;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatStr;
    NSString *todayStr = [dateFormatter stringFromDate:[NSDate date]];
    if (todayStr == nil) return NO;
    
    return [dateStr compare:todayStr] == NSOrderedSame;
}

+ (_int64)toDecimalSystemWithBinarySystem:(NSString *)binary
{
    _int64 ll = 0 ;
    int  temp = 0 ;
    
    for (int i = 0; i < binary.length; i ++)
    {
        temp = [[binary substringWithRange:NSMakeRange(i, 1)] intValue];
        temp = temp * powf(2, binary.length - i - 1);
        ll += temp;
    }
    
    NSString * result = [NSString stringWithFormat:@"%lld",ll];
    return [result integerValue] ;
}

+ (float)mappingAsixYValue:(float)max min:(float)min v:(float)v top:(float)top bottom:(float)bottom
{
    float y;
    
    if (max == min)
        y = bottom;
    else if (v <= max && v >= min)
        y = bottom - (v - min)/(max - min)*(bottom - top);
    else
        y = (v < min) ? bottom : top;
    
    return y;
}

//根据Y的坐标，映射Y对应的值
+ (float)mappingValueByAsixY:(float)max min:(float)min y:(float)y top:(float)top bottom:(float)bottom
{
    float v;
    if (top == bottom)
        v = min;
    else if (top <= y && y <= bottom)
        v = max - (y - top)/(bottom - top)*(max - min);
    else
        v = (y < top) ? max : min;
    return v;
}

+ (float)mappingAsixXValue:(float)max min:(float)min v:(float)v left:(float)left right:(float)right
{
    float x = 0;
    
    if (min <= v && v <= max)
        x = left + (v - min)/(max - min)*(right - left);
    else if (v < min)
        x = left;
    else if (v > max)
        x = right;
    
    return x;
}


//格式化金额
+ (NSString *)getMoneyFormatStringWith:(float)money isNeedPoint:(BOOL)point
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = kCFNumberFormatterCurrencyStyle;
    NSString *string = [formatter stringFromNumber:[NSNumber numberWithFloat:ABS(money)]];
    string = [string substringFromIndex:1];
    
    if([string rangeOfString:@"."].length >0 && point == NO)
    {
        string = [string substringToIndex:[string rangeOfString:@"."].location];
    }
    
    //    NSString * integer,* fraction;
    //    if([string rangeOfString:@"."].length != 0) //有小数部分
    //    {
    //        integer = [[string componentsSeparatedByString:@"."] objectAtIndex:0];
    //        fraction = [[string componentsSeparatedByString:@"."] objectAtIndex:1];
    //        if([fraction length]<2)
    //        {
    //            fraction = [NSString stringWithFormat:@"%@0",fraction];
    //        }
    //        fraction = [fraction substringToIndex:2];
    //    }
    //    else
    //    {
    //        integer = string;
    //        fraction = @"00";
    //    }
    //
    //    if(point)     // 如果需要小数点
    //    {
    //        string = [NSString stringWithFormat:@"%@.%@",integer,fraction];
    //    }
    //    else
    //        string = [NSString stringWithString:integer];
    //
    return string;
}

+ (NSArray *)seperateStringByLen:(NSString *)content len:(int)len
{
    NSArray *retVal = nil;
    if (len > 0)
    {
        NSInteger cntLen  = [content length];
        NSInteger offset  = cntLen % len == 0 ? 0 : 1;
        NSInteger count   = cntLen / len + offset;
        
        NSMutableArray *keyArr = [NSMutableArray array];
        
        if (cntLen / len > 0)
        {
            for (NSInteger i = 0; i < count; i++)
            {
                [keyArr addObject:[[content substringFromIndex:i * len] substringToIndex:MIN(len, cntLen-i*len)]];
            }
            
            retVal = keyArr;
        }
        else
            retVal  = [NSArray arrayWithObjects:content, nil];
    }
    
    return retVal;
}

//千位分割符
+ (NSString *)separatedDigitStringWithStr:(NSString *)digitString

{
    if (digitString.length <= 3) {
        
        return digitString;
        
    } else {
        
        NSMutableString *processString = [NSMutableString stringWithString:digitString];
        NSInteger location = processString.length - 3;
        
        NSMutableArray *processArray = [[NSMutableArray alloc]init];
        
        while (location >= 0) {
            
            NSString *temp = [processString substringWithRange:NSMakeRange(location, 3)];
            
            
            [processArray addObject:temp];
            
            if (location < 3 && location > 0)
                
            {
                
                NSString *t = [processString substringWithRange:NSMakeRange(0, location)];
                
                [processArray addObject:t];
                
            }
            
            location -= 3;
            
        }
        
        NSMutableArray *resultsArray = [[NSMutableArray alloc]init];
        
        int k = 0;
        
        for (NSString *str in processArray)
            
        {
            
            k++;
            
            NSMutableString *tmp = [NSMutableString stringWithString:str];
            
            if (str.length > 2 && k < processArray.count )
                
            {
                
                [tmp insertString:@"," atIndex:0];
                
                [resultsArray addObject:tmp];
                
            } else {
                
                [resultsArray addObject:tmp];
                
            }
            
        }
        NSMutableString *resultString = [NSMutableString string];
        
        for (NSInteger i = resultsArray.count - 1 ; i >= 0; i--)
            
        {
            
            NSString *tmp = [resultsArray objectAtIndex:i];
            
            [resultString appendString:tmp];
            
        }
        
        return resultString;
        
    }
    
}

+ (NSString *)getNewStrWithSepStr:(NSString *)sepStr recvStr:(NSString *)recvStr
{
    if([sepStr length] == 0)
    {
        return recvStr;
    }
    NSInteger count = [recvStr length];
    NSMutableString * str = [NSMutableString stringWithFormat:@""];
    for(int i = 0; i < count; i++)
    {
        [str appendString:[recvStr substringWithRange:NSMakeRange(i, 1)]];
        if(i != count - 1)
            [str appendString:sepStr];
    }
    
    return str;
}

+ (NSDate *)dateFromString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    return destDate;
}

+ (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

//获取2个日期间的时间间隔，返回多少秒
+ (NSTimeInterval)getTimeIntervalFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    if(fromDate && toDate)
        return [toDate timeIntervalSinceDate:fromDate];
    else
        return 0;
}

+ (NSTimeInterval)getTimeIntervalFromString:(NSString *)fromDate toString:(NSString *)toDate
{
    if([self dateFromString:fromDate] || [self dateFromString:toDate])
        return 0;
    return [self getTimeIntervalFromDate:[self dateFromString:fromDate] toDate:[self dateFromString:toDate]];
}

+ (NSNumber *)numberFromString:(NSString *)stringVal
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    return [f numberFromString:stringVal];
}

+ (NSString *)getCurTimeStr
{
    unsigned int units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday;
    
    NSCalendar *mycal    = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *now            = [NSDate date];
    
    NSDateComponents *comp = [mycal components:units fromDate:now];
    
    NSInteger month        = [comp month];
    NSInteger year        = [comp year];
    NSInteger day        = [comp day];
    NSInteger hour        = [comp hour];
    NSInteger minute    = [comp minute];
    NSInteger second    = [comp second];
    NSString *strDay    = day < 10 ? [NSString stringWithFormat:@"0%ld", (long)day] : [NSString stringWithFormat:@"%ld", (long)day];
    NSString *strMonth    = month < 10 ? [NSString stringWithFormat:@"0%ld", (long)month] : [NSString stringWithFormat:@"%ld", (long)month];
    NSString *strHour    = hour < 10 ? [NSString stringWithFormat:@"0%ld", (long)hour] : [NSString stringWithFormat:@"%ld", (long)hour];
    NSString *strMinute    = minute < 10 ? [NSString stringWithFormat:@"0%ld", (long)minute] : [NSString stringWithFormat:@"%ld", (long)minute];
    NSString *strSecond    = second < 10 ? [NSString stringWithFormat:@"0%ld", (long)second] : [NSString stringWithFormat:@"%ld", (long)second];
    NSString *strDate    = [NSString stringWithFormat:@"%ld-%@-%@ %@:%@:%@", (long)year, strMonth, strDay, strHour, strMinute, strSecond];
    
    return strDate;
}

+ (NSString *)getCurTimeNanoSecondStr
{
    unsigned int units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday;
    NSCalendar *mycal    = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *now            = [NSDate date];
    
    NSDateComponents *comp = [mycal components:units fromDate:now];
    NSInteger hour        = [comp hour];
    NSInteger minute    = [comp minute];
    NSInteger second    = [comp second];
    NSInteger nanosecond    = [comp nanosecond];
    
    NSString *strHour    = hour < 10 ? [NSString stringWithFormat:@"0%ld", (long)hour] : [NSString stringWithFormat:@"%ld", (long)hour];
    NSString *strMinute    = minute < 10 ? [NSString stringWithFormat:@"0%ld", (long)minute] : [NSString stringWithFormat:@"%ld", (long)minute];
    NSString *strSecond    = second < 10 ? [NSString stringWithFormat:@"0%ld", (long)second] : [NSString stringWithFormat:@"%ld", (long)second];
    NSString *strNanoSecond    = nanosecond < 10 ? [NSString stringWithFormat:@"0%ld", (long)nanosecond] : [NSString stringWithFormat:@"%ld", (long)nanosecond];
    
    NSString *strDate    = [NSString stringWithFormat:@"%@:%@:%@:%@", strHour, strMinute, strSecond, strNanoSecond];
    
    return strDate;
}

+ (NSString *)getTimeStrInMinutes:(NSInteger)interval;
{
    unsigned int units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday;
    NSCalendar *mycal    = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *now            = [NSDate date];
    
    NSDateComponents *comp = [mycal components:units fromDate:now];
    
    NSInteger month        = [comp month];
    NSInteger year        = [comp year];
    NSInteger day        = [comp day];
    NSInteger hour        = [comp hour];
    NSInteger minute    = [comp minute]/interval*interval;
    NSString *strDay    = day < 10 ? [NSString stringWithFormat:@"0%ld", (long)day] : [NSString stringWithFormat:@"%ld", (long)day];
    NSString *strMonth    = month < 10 ? [NSString stringWithFormat:@"0%ld", (long)month] : [NSString stringWithFormat:@"%ld", (long)month];
    NSString *strHour    = hour < 10 ? [NSString stringWithFormat:@"0%ld", (long)hour] : [NSString stringWithFormat:@"%ld", (long)hour];
    NSString *strMinute    = minute < 10 ? [NSString stringWithFormat:@"0%ld", (long)minute] : [NSString stringWithFormat:@"%ld", (long)minute];
    NSString *strDate    = [NSString stringWithFormat:@"%ld%@%@%@%@", (long)year, strMonth, strDay, strHour, strMinute];
    
    return strDate;
}

+(NSString *)getNewFormatTimeEx:(NSString *)time
{
    if (!([time isKindOfClass:[NSString class]] && time.length > 5))
        return time;
    NSString * datestr    = time;
    NSString * subStr1 = [datestr substringFromIndex:5];
    NSString * needStr = datestr;
    
    NSArray  * array = [time componentsSeparatedByString:@" "];
    
    if ([array count] > 1)
    {
        if ([DataFormatterFunc isTodayOfStrDate:[array objectAtIndex:0] formatStr:@"yyyy-MM-dd"])
        {
            subStr1 = [array objectAtIndex:1];
        }
    }
    
    if (subStr1)
    {
        NSRange range = [subStr1 rangeOfString:@":"];
        
        if ([subStr1 rangeOfString:@":"].location != NSNotFound)
        {
            NSLog(@"rang.locatin length:%@", @([[subStr1 substringFromIndex:range.location] length]));
            if ([[subStr1 substringFromIndex:range.location] length] > 2)
            {
                needStr = [subStr1 substringToIndex:range.location + 3];
            }else if([[subStr1 substringFromIndex:range.location] length] > 1)
            {
                needStr = [subStr1 substringToIndex:range.location + 2];
            }else
            {
                needStr = [subStr1 substringToIndex:range.location - 1];
            }
        }
    }
    return needStr;
}

+ (NSString *)getServerTimeMinuteModNVal:(int)nVal
{
    unsigned int units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday;
    NSCalendar *mycal    = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *now            = [NSDate date];
    
    NSDateComponents *comp = [mycal components:units fromDate:now];
    NSInteger year      = [comp year];
    NSInteger month     = [comp month];
    NSInteger day       = [comp day];
    NSInteger hour        = [comp hour];
    NSInteger minute    = [comp minute];
    NSInteger tmpVal          = minute % nVal == 0 ? minute : minute - (minute % nVal);
    NSString *retVal    = [NSString stringWithFormat:@"%@%@%@%@%@", @(year), @(month), @(day), @(hour), @(tmpVal)];
    
    return retVal;
}

+ (NSString *)stringBMPFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

@end
