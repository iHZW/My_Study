//
//  PASTradeProtocols.h
//  PASecuritiesApp
//
//  Created by Howard on 16/4/14.
//  Copyright © 2016年 PAS. All rights reserved.
//


#ifndef PASTradeProtocols_h
#define PASTradeProtocols_h

typedef NS_ENUM(NSInteger , FromType) {
    FromTypeMySelfStock, /** 自选界面 */
    FromTypeStockDetail, /** 个股详情 */
};

 /** 交易市场类型 */
typedef NS_ENUM(NSInteger, TradeMarketType) {
    TradeMarketTypeHS, /** 沪深市场 */
    TradeMarketTypeHGT, /** 沪港通 */
    TradeMarketTypeSGT, /** 深港通 */
    TradeMarketTypeMargin, /** 两融 */
};

/** 交易页面tab类型 */
typedef NS_ENUM(NSInteger, TradeType) {
    TradeTypeBuy, /** 买入 */
    TradeTypeSell, /** 卖出 */
    TradeTypeRevocable, /** 撤单 */
    TradeTypeHolding, /** 持仓 */
    TradeTypeSearch, /** 查询 */
    TradeTypeOther, /**  其他  */
};

/** 页面类型 */
typedef NS_ENUM(NSInteger, TradePageType) {
    TradeTypeCommon, /** 普通买卖 */
    TradeTypeMargin, /** 两融买卖 */
    TradeTypeHuGangTong, // 沪港通
    TradeTypeShenGangTong, // 深港通
};

 /** 委托买入，卖出类型 */
typedef enum : NSInteger {
    EntrustTypeBuy,   //普通买
    EntrustTypeSell,  //普通卖
    EntrustTypeMarketBuy,      //市价买入
    EntrustTypeMarketSell,  //市价卖出
    
    EntrustTypeMarginBuy, // 两融买
    EntrustTypeMarginSell, // 两融卖
    
    EntrustTypeMarginFinaningSell,  //融券卖出
    
    EntrustTypeMarginFinaingBuy,   // 融资买入
    EntrustTypeMarketFinaningBuy,  // 融资买入（市价买入）
    
    EntrustTypeRefundSellTicket,  //卖券还款
    EntrustTypeReturnTicket,      //现券还券
    EntrustTypeBuyTicketReturn,   // 买券还券
    
    EntrustTypeHuGangTongBuy,       // 沪港通买入
    EntrustTypeHuGangTongSell,      // 沪港通卖出
    EntrustTypeHUGangTongZeroSell,  // 沪港通零股卖出
    
    EntrustTypeShenGangTongBuy,       // 深港通买入
    EntrustTypeShenGangTongSell,      // 深港通卖出
    EntrustTypeShenGangTongZeroSell,  // 深港通零股卖出
    
} EntrustType;

typedef enum :NSUInteger
{
    CommonTradeType,    // 普通交易
    StructuredFundTradeType,    // 分级基金
}FundTradeType;

/** 沪港通申报类型**/
typedef enum : NSUInteger
{
    HuGangTongVoteReport,   // 投票申报
    HuGangTongCompanyReport,   // 公司行为申报
    
}HuGangTongReportType;

/** 交易买卖方向*/
typedef NS_ENUM(NSInteger, EntrustDirection) {
    EntrustDirectionBuy,
    EntrustDirectionSell,
};

 /** 将买卖类型直接转换成买卖方向 */
CG_INLINE EntrustDirection ConvertDirectionFromType(EntrustType entrustType){

    if (entrustType == TradeTypeBuy ||
        entrustType == EntrustTypeMarketBuy ||
        entrustType == EntrustTypeMarginBuy ||
        entrustType == EntrustTypeMarginFinaingBuy ||
        entrustType == EntrustTypeMarketFinaningBuy ||
        entrustType == EntrustTypeHuGangTongBuy ||
        entrustType == EntrustTypeBuyTicketReturn ||
        entrustType == EntrustTypeShenGangTongBuy)
        return EntrustDirectionBuy;
    return EntrustDirectionSell;
}

 /** 交易查询页面类型 */
typedef enum : NSInteger {
    TradeRecordTypeUnkown,
    TradeRecordTypeHolding, // 持仓界面持仓
    TradeRecordTypeEntrustHolding, // 卖入卖出界面持仓
    TradeRecordTypeEntrust, // 当日委托
    TradeRecordTypeHistoryEntrust, // 历史委托
    TradeRecordTypeRevocableEntrust, // 撤单
    TradeRecordTypeTurnover, // 当日成交
    TradeRecordTypeHistoryTurnover, //历史成交
    TradeRecordTypeBill, // 对账单
    TradeRecordTypeFundFlow, // 资金流水
    TradeRecordTypeDistributed, // 配号查询
    TradeRecordTypeLucky, // 中签查询
    TradeRecordTypePayment, // 缴款查询
    TradeRecordTypeTurnoverTotal, // 当日成交汇总
    TradeRecordTypeHistoryTurnoverTotal, // 历史成交汇总
    TradeRecordTypeNewStockSubscribeLimit, // 新股申购额度
    
    TradeRecordTypeHKRevocableEntrust,  //港股撤单
    TradeRecordTypeSZHKRevocableEntrust,  // 深港通撤单
    TradeRecordTypeHKEntrust,//港股当日委托
    TradeRecordTypeHKTurnover,   //港股当日成交
    TradeRecordTypeFundSearch, // 资金查询
    TradeRecordTypeHKHolding,    //港股持仓
    TradeRecordTypeHKHistoryEntrust,  //港股历史委托
    TradeRecordTypeHKHistoryTurnover,   //港股历史成交
    TradeRecordTypeVoteDeclareEntrust,  //投票申报当日委托
    TradeRecordTypeVoteDeclareHistoryEntrust, //投票申报历史委托
    TradeRecordTypeHKBill, // 港股对账单
    TradeRecordTypeDeliveryOrder, // 交割单
    TradeRecordTypeAmountSearch,  //额度查询
    TradeRecordTypeExchangeRateSearch, // 汇率查询
    TradeRecordTypeCompanyBehaviorEntrust,  //公司行为申报当日委托
    TradeRecordTypeCompanyBehaviorHistoryEntrust, //公司行为申报历史委托
    
    TradeRecordTypeBuyBackForward,                        /**   提前购回  */
    TradeRecordTypeBuyBackForwardAppointmentSearch,       /**   提前购回预约查询  */
    TradeRecordTypeBuyBackAppointmentCancelSearch,        /**  提前购回预约撤销查询    */
    TradeRecordTypeBuyBackrollingAdjustment,              /**  展期调整  */
    TradeRecordTypePrematuritySearch,                     /**  未到期合约查询   报价回购 */
    TradeRecordTypeBuyBackEntrust,                        /**   当日委托      报价回购 */
    TradeRecordTypeBuyBackHistoryEntrust,                 /**   历史委托    报价回购  */
    TradeRecordTypeBuyBackHistoryTurnover,                /**  历史成交     报价回购   */
    
    TradeRecordTypeRepurchaseEntrust,                       /**  当日委托  逆回购 */
    TradeRecordTypeRepurchaseTurnover,                      /**  当日成交  逆回购 */
    TradeRecordTypeRepurchaseRevocableEntrust,              /**  撤单     逆回购*/
    TradeRecordTypeUnexpiredContract,                       /**  未到期合约 逆回购 */

} TradeRecordType;

/**
 *  分级基金交易类型
 */
typedef enum : NSUInteger {
    StructuredFundTypeSubscribe,            /**  申购    */
    StructuredFundTypeRedemption,           /**  赎回   */
    StructuredFundTypeSplit,                /**  拆分    */
    StructuredFundTypeMerge,                /**  合并    */
}StructuredFundType;

typedef enum : NSUInteger {
    RepurchaseRecordTypeEntrust,            /**  当日委托  逆回购 */
    RepurchaseRecordTypeTurnover,           /**  当日成交  逆回购 */
    RepurchaseRecordTypeRevocableEntrust,   /**  撤单     逆回购*/
}RepurchaseRecordType;

typedef enum : NSUInteger {
    RepurchaseMarketTypeSH,                 /** 逆回购市场类型  沪市 */
    RepurchaseMarketTypeSZ,               /** 逆回购市场类型  深市 */
    
}RepurchaseMarketType;


typedef enum : NSUInteger {
    StrategyEntrustTypeDJMR,               /**  到价买入 */
    StrategyEntrustTypeZYZS,               /** 止盈止损*/
    
}StrategyEntrustType;

typedef enum : NSUInteger {
    TradeSearchTypeTodayEntrust,                /**  当日委托 */
    TradeSearchTypeTodayTurnover,               /** 当日成交*/
    TradeSearchTypeHistory,                       /**  历史 */
}TradeSearchType;

typedef NS_ENUM (NSInteger, PASIncomeBalanceType)
{
    PASIncomeBalanceType_Total,    /** 总盈亏*/
    PASIncomeBalanceType_Today,   /**  当日盈亏*/
};


/**
 ETF场内基金 类型

 - PASETFFundEntrustType_onlineMoney: <#PASETFFundEntrustType_onlineMoney description#>
 */
typedef NS_ENUM (NSInteger, PASETFFundEntrustType)
{
    PASETFFundEntrustType_onlineMoney,      /** 网上现金*/
    PASETFFundEntrustType_offlineMoney,     /** 网下现金*/
    PASETFFundEntrustType_offlineStock,     /** 网下股票*/
    
    PASETFFundEntrustType_offerBuy,         /** 认购*/
    PASETFFundEntrustType_subscribe,        /** 申购*/
    PASETFFundEntrustType_redemption,        /** 赎回*/
};

/**
 *  预设委托列表类型
 */
typedef NS_ENUM (NSInteger, PASPresetTradeType) {
    /**
     *  预设委托买单
     */
    PASPresetTradeType_Buy,
    /**
     *  预设委托卖单
     */
    PASPresetTradeType_Sell,
};


typedef void (^ReturnTextBlock)(NSString *showText1,NSString *showText2);



/**
 *  交易base类，包含交易市场类型
 */
@protocol PAS_tradeBase <NSObject>

@property (nonatomic) TradeMarketType tradeMarketType;

@end

/**
 *  交易首页
 */
@protocol PAS_tradeMain <PAS_tradeBase>

@property (nonatomic, assign) BOOL bolComeInFormScheme;//是否是通过scheme进来，区分二级页面返回

@end

/**
 *  模拟炒股首页
 */
@protocol PAS_simulatedtrade <PAS_tradeBase>

@end

/**
 *  交易（持仓，买入，卖出，撤单，查询）
 */
@protocol PAS_Trade <PAS_tradeBase>

@property (nonatomic) TradeType tradeType;
@end

/**
 *  市价设置
 */
@protocol PAS_tradpriceSet <NSObject>

@property (nonatomic, copy) ReturnTextBlock returnTextBlock;

@end

/**
 *  一键清仓
 */
@protocol PAS_tradOnekeyClear <NSObject>



@end
/**
 *  持仓
 */
@protocol PAS_myposition <PAS_Trade>

@end
/**
 *  全部持仓
 */
@protocol PAS_myallposition <PAS_Trade>

@end


/**
 *  交易委托
 */
@protocol PAS_Entrust <PAS_tradeBase>

@property (nonatomic, copy) NSString *code;

@optional
@property (nonatomic, copy) NSString *type;// 股票类型
@property (nonatomic, copy) NSString *productID;// 产品编号
@property (nonatomic, copy) NSString *byFollowInvestorID;// 被跟投人ID
@property (nonatomic, copy) NSString *ext;// 扩展字段

@property (nonatomic) EntrustType entrustType;
@property (nonatomic, copy) NSString *entrustVolume;
@property (nonatomic, copy) NSString *entrustPrice;
@property (nonatomic) FundTradeType fundTradeType;   // 基金交易类型

@end

/**
 *  买入
 */
@protocol PAS_gototradebuypage <PAS_Entrust>


@end

/**
 *  卖出
 */
@protocol PAS_gototradesellpage <PAS_Entrust>

@end

/**
 *  市价买入/市价卖出
 */
@protocol PAS_marketpriceentrust <PAS_tradeBase>

@property (nonatomic) EntrustType entrustType;

@end

/**
 *  交易查询
 */
@protocol PAS_tradeRecord <PAS_tradeBase>

 /** 交易查询类型 */
@property (nonatomic) TradeRecordType recordType;
@property (nonatomic) BOOL isNeedSelectedDate;  //是否显示时间选择器
@property (nonatomic, copy) NSString *title;

@end


/**
 查询明细页面
 */
@protocol PAS_tradequerydetail <NSObject>

@end

/**
 *  资金流水
 */
@protocol PAS_fundflow <PAS_tradeBase>


@end
/**
 *  对账单
 */
@protocol PAS_bill <PAS_tradeBase>


@end
/**
 *  历史委托 历史成交
 */
@protocol PAS_historyentrust <PAS_tradeBase>

@end


/**
 *  报价回购
 */
@protocol PAS_tradequotebuyback <NSObject>

@end


/**
 回购列表
 */
@protocol PAS_buybackentrust <NSObject>

@end


/**
 报价回购查询列表
 */
@protocol PAS_buybacksearch <NSObject>

@end


#pragma mark ---- 预设委托

/**
 *  预约委托列表页面
 */
@protocol PAS_PresetTradeHome <NSObject>

@property (nonatomic) PASPresetTradeType defaultType; // 预设委托类型

@end

/**
 *  预约委托设置页面
 */
@protocol PAS_PresetSettings <NSObject>

@end

/**
 *  预约委托查询页面
 */
@protocol PAS_PresetSearch <NSObject>

@end

/**
 *  场内基金申赎
 */
@protocol PAS_floorFund <NSObject>
@property (nonatomic) TradeType tradeType;
@property (nonatomic, copy) NSString *code;

@end

/**
 场内货币基金申购
 */
@protocol PAS_floorfundsubscribe <PAS_floorFund>

@end

/**
 场内货币基金赎回
 */
@protocol PAS_floorfundredemption <PAS_floorFund>

@end

/**
 *  分级基金首页
 */
@protocol PAS_structuredfundhome <NSObject>

@end

/**
 *  分级基金
 */
@protocol PAS_StructuredFund <NSObject>
@property (nonatomic) StructuredFundType fundEntrustType;

@end

/**
 *  逆回购
 */
@protocol PAS_repurchasehome <NSObject>

@end


/**
 逆回购 借出资金交易查询页
 */
@protocol PAS_repurchasefundloan <NSObject>
@property (nonatomic) RepurchaseRecordType recordType;


@end

/**
 逆回购 交易页面
 */
@protocol PAS_repurchaseentrust <NSObject>
@property (nonatomic) RepurchaseMarketType repurchaseMarketType;


@end

/**
 逆回购 选择品种界面
 */
@protocol PAS_repurchasechoice <NSObject>

@property (nonatomic) RepurchaseMarketType marketType;

@end


/**
 未到期合约
 */
@protocol PAS_unexpiredcontractview <NSObject>


@end


/**
 国债 -- 购买帮助
 */
@protocol PAS_repurchasehelp <NSObject>


@end


/**
 策略交易首页
 */
@protocol PAS_strategytradeorder <NSObject>

@property (nonatomic, strong) NSString *typeJump;

@end

/**
 策略交易 策略埋单页面
 */
@protocol PAS_strategyentrust <NSObject>

@property (nonatomic) StrategyEntrustType repurchaseType;

@end
/**
 策略交易 选择持仓页面
 */
@protocol PAS_selectposition <NSObject>

@end

/**
 6.9 ETF场内基金页面
 */
@protocol PAS_etffieldfund <NSObject>
@end

@protocol PAS_etfFundHome <NSObject>
@end

/**
 ETF 认购
 */
@protocol PAS_etfsubscription <NSObject>
@end

/**
 场内基金
 */
@protocol PAS_intrafieldfund <NSObject>
@end

@protocol PAS_recodtransactionlist <NSObject>

@end

/**
 一键清仓
 */
@protocol PAS_clearholding <NSObject>
@end

/**
 转股回售
 */
@protocol PAS_exchangestockputback <NSObject>


@end

#endif /* PASTradeProtocols_h */
