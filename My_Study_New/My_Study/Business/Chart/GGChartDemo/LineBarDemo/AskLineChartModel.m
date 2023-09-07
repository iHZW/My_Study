//
//  AskLineChartModel.m
//  My_Study
//
//  Created by Zhiwei Han on 2023/9/7.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "AskLineChartModel.h"
#import "KLineData.h"
#import "NSDate+GGDate.h"

@implementation AskLineChartModel

+ (AskLineChartModel *)getDayDataModel {
    NSData *dataStock = [NSData dataWithContentsOfFile:[self stockDataJsonPath]];
    NSArray *stockJson = [NSJSONSerialization JSONObjectWithData:dataStock options:0 error:nil];

    NSArray<KLineData *> *datas = [[[KLineData arrayForArray:stockJson class:[KLineData class]] reverseObjectEnumerator] allObjects];

    [datas enumerateObjectsUsingBlock:^(KLineData *obj, NSUInteger idx, BOOL *stop) {
        obj.ggDate = [NSDate dateWithString:obj.date format:@"yyyy-MM-dd HH:mm:ss"];
    }];
    AskLineChartModel *model = [[AskLineChartModel alloc] init];
    model.kType = KLineTypeDay;
    model.kLineArray = datas;
    model.desName = @"行业板块几乎全线下跌，半导体、光伏设备、电源设备、船舶制造、电子化学品、电子元件板块跌幅居前，仅教育、旅游酒店、游戏板块逆市翻红。";

    return model;
}

+ (AskLineChartModel *)getWeekDataModel {
    NSData *dataStock = [NSData dataWithContentsOfFile:[self stockWeekDataJsonPath]];
    NSArray *stockJson = [NSJSONSerialization JSONObjectWithData:dataStock options:0 error:nil];

    NSArray<KLineData *> *datas = [[[KLineData arrayForArray:stockJson class:[KLineData class]] reverseObjectEnumerator] allObjects];

    [datas enumerateObjectsUsingBlock:^(KLineData *obj, NSUInteger idx, BOOL *stop) {
        obj.ggDate = [NSDate dateWithString:obj.date format:@"yyyy-MM-dd HH:mm:ss"];
    }];
    AskLineChartModel *model = [[AskLineChartModel alloc] init];
    model.kType = KLineTypeWeek;
    model.kLineArray = datas;
    model.desName = @"A股三大指数今日集体收跌，沪指跌1.13%，收报3122.35点；深证成指跌1.84%，收报10321.44点；创业板指跌2.11%，收报2056.98点。市场成交额达到7668亿元，北向资金今日净卖出70.72亿。";
    
    return model;
}

+ (AskLineChartModel *)getMonthDataModel {
    NSData *dataStock = [NSData dataWithContentsOfFile:[self stockMonthDataJsonPath]];
    NSArray *stockJson = [NSJSONSerialization JSONObjectWithData:dataStock options:0 error:nil];

    NSArray<KLineData *> *datas = [[[KLineData arrayForArray:stockJson class:[KLineData class]] reverseObjectEnumerator] allObjects];

    [datas enumerateObjectsUsingBlock:^(KLineData *obj, NSUInteger idx, BOOL *stop) {
        obj.ggDate = [NSDate dateWithString:obj.date format:@"yyyy-MM-dd HH:mm:ss"];
    }];
    AskLineChartModel *model = [[AskLineChartModel alloc] init];
    model.kType = KLineTypeMonth;
    model.kLineArray = datas;
    model.desName = @"个股方面，下跌股票数量超过4700只。游戏股开盘走强，华立科技、大晟文化涨停。华为概念股走势分化，华映科技6天5板，星星科技、熙菱信息、汉仪股份均20CM涨停。教育股震荡走强，国脉科技涨超5%。券商股尾盘异动，首创证券涨超6%。下跌方面，芯片股集体调整，光刻胶方向领跌，同益股份跌超12%、波长光电跌超15%，中芯国际跌超8%。";

    return model;
}

+ (NSString *)stockDataJsonPath {
    return [[NSBundle mainBundle] pathForResource:@"600887_kdata" ofType:@"json"];
}

+ (NSString *)stockWeekDataJsonPath {
    return [[NSBundle mainBundle] pathForResource:@"week_k_data_60087" ofType:@"json"];
}

+ (NSString *)stockMonthDataJsonPath {
    return [[NSBundle mainBundle] pathForResource:@"month_k_data_600887" ofType:@"json"];
}

@end
