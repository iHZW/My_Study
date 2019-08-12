//
//  DZHDrawingDefine.h
//  DZHDrawable
//
//  Created by Duanwwu on 14-7-8.
//  Copyright (c) 2014年 Duanwwu. All rights reserved.
//

#ifndef DZHDrawable_DZHDrawingDefine_h
#define DZHDrawable_DZHDrawingDefine_h

#define kOHLCPointCount     6 //美国线点个数

struct CGLine
{
    CGPoint start;
    CGPoint end;
};
typedef struct CGLine CGLine;

static inline CGLine CGLineMake(CGFloat x1, CGFloat y1, CGFloat x2, CGFloat y2)
{
    return (CGLine){.start = CGPointMake(x1,y1), .end = CGPointMake(x2,y2)};
}

typedef NS_ENUM(NSInteger, MarketPriceType)
{
    MarketPriceTypeRise = 0, //价格涨
    MarketPriceTypeFall = 1, //价格跌
    MarketPriceTypeFlat = 2, //价格平
};//涨跌类型

typedef NS_ENUM(NSInteger, KLineType)
{
    KLineTypePositive   = 0, //阳线
    KLineTypeNegative   = 1, //阴线
    KLineTypeCross      = 2, //十字线
};

typedef NS_ENUM(NSInteger, EXRightsType)
{
    EXRightsTypeBefore              = 0,    //前复权
    EXRightsTypeAfter               = 1,    //后复权
    EXRightsTypeER                  = 2,    //除权
};

static inline NSString * nameForEXRightsType(EXRightsType exRightsType)
{
    switch (exRightsType)
    {
        case EXRightsTypeBefore:
            return @"前复权";
        case EXRightsTypeAfter:
            return @"后复权";
        default:
            return @"除权";
    }
}

typedef enum
{
    MinuteLineTypeTrend, /** 走势图 */
    MinuteLineTypeAvg, /** 均线 */
}MinuteLineType;

typedef enum
{
    KLineCycleFive      = 5,
    KLineCycleTen       = 10,
    KLineCycleTwenty    = 20,
    KLineCycleThirty    = 30,
}KLineCycle;

typedef enum
{
    VolumeTypePositive,
    VolumeTypeNegative,
}VolumeType;

typedef enum
{
    MACDLineTypeFast,
    MACDLineTypeSlow,
}MACDLineType;

typedef enum
{
    MACDTypePositive,
    MACDTypeNegative,
}MACDType;

typedef enum
{
    KDJLineTypeK,
    KDJLineTypeD,
    KDJLineTypeJ,
}KDJLineType;

typedef enum
{
    RSILineType1,
    RSILineType2,
    RSILineType3,
}RSILineType;

typedef enum
{
    WRLineType1,
    WRLineType2,
}WRLineType;

typedef enum
{
    BIASLineType1,
    BIASLineType2,
    BIASLineType3,
}BIASLineType;

typedef enum
{
    DMALineTypeDDD,
    DMALineTypeAMA,
}DMALineType;

typedef enum
{
    BOLLLineTypeUPP,
    BOLLLineTypeMID,
    BOLLLineTypeLOW,
}BOLLLineType;

typedef enum
{
    BSTypeB,
    BSTypeS,
}BSType;

typedef enum
{
    NiuXIongTypeNiu,
    NiuXIongTypeXiong,
}NiuXiongType;

typedef enum
{
    ENELineTypeUpper,
    ENELineTypeMidder,
    ENELineTypeLower,
}ENELineType;

typedef NS_ENUM(NSInteger , LTSHLineType) {
    
    LTSHLineTypeDragon,
    LTSHLineTypeUpper,
    LTSHLineTypeMiddle,
    LTSHLineTypeLower,
};


typedef NS_ENUM(NSInteger , JHJJLineType) {
    JHJJLineTypeTrend,          //集合竞价 匹配价走势图
    JHJJLineTypeUnmatchGray,    //集合竞价 未匹配类型 灰色
    JHJJLineTypeUnmatchGreen,   //集合竞价 未匹配类型 色色
    JHJJLineTypeUnmatchRed,     //集合竞价 未匹配类型 红色
};

/**< 资金博弈 */
typedef NS_ENUM(NSInteger, ZJBYLineType) {
    ZJBYLineTypeJumbo, //特大
    ZJBYLineTypeBig,  //大
    ZJBYLineTypeMiddle, //中等
    ZJBYLineTypeSmall,  //小
};

// 6.16 DMI指标
typedef NS_ENUM(NSInteger , DMILineType) {
    DMILineTypePDI,         //DMI指标 PDI颜色   黑
    DMILineTypeMDI,         //DMI指标 MDI颜色   红
    DMILineTypeADX,         //DMI指标 ADX颜色   黄
    DMILineTypeADXR,        //DMI指标 ADXR颜色  蓝
};

// 6.16 DMI指标
typedef NS_ENUM(NSInteger , NewIndexLineType) {
    NewIndexLineTypeBlack,          //新增指标   黑色
    NewIndexLineTypeRed,            //新增指标   红色
};

static inline NSInteger indexWithCycle(NSInteger index, int cycle)
{
    return index < cycle ? cycle : index;
}

#endif
