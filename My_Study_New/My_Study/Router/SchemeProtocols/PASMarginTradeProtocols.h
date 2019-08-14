//
//  PASMarginTradeProtocols.h
//  PASecuritiesApp
//
//  Created by 沐雨立 on 16/8/17.
//  Copyright © 2016年 PAS. All rights reserved.
//

#ifndef PASMarginTradeProtocols_h
#define PASMarginTradeProtocols_h
#import "PASTradeProtocols.h"


/** 融资交易页面tab类型 */
//typedef NS_ENUM(NSInteger, FinaningTradeType) {
//    FinaningTradeTypeBuy, /** 融资买入 */
//    FinaningTradeTypeSell, /** 融资卖出 */
//
//};

//typedef NS_ENUM(NSInteger,MarginTradeTypeTab ){  /**   融资交易   */
//    MarginTradeTypeTabMoney, /** 融资买入或者融资卖出 */
//    MarginTradeTypeTabRevocableEntrust,   /**  撤单 */
//    MarginTradeTypeTabHolding,   /**  持仓  */
//
//};

typedef NS_ENUM(NSInteger, AssetLiabilityTab){
    
    MarginTradeTabFund,   /**  资金余额   */
    MarginTradeTabFundSearch,  /**  负债查询 */
    MarginTradeTabMonryDebtsTotal,   /**  融资负债汇总  */
    MarginTradeTabTicketDebtsTotal,   /**  融券负债汇总  */
    MarginTradeTabCreditFundSearch,  /**  信用资产查询  */
    HKTradeTabFund,          /**  港股通资金查询   */
    HKTradeAmountSearch,    /**  港股通额度查询   */
    HKTradeExchangeRate,     /**   港股通汇率查询  */
    SZHKTradeAmountSearch,    /**  深港通额度查询   */
    SZHKTradeExchangeRate,     /**   深港通汇率查询  */
};

typedef NS_ENUM(NSInteger, MarginTicketQuery){
    MarginTicketMoney,            /**   可融资证券查询  */
    MarginTicketSecurities,       /**   可融券证券查询  */
};

typedef NS_ENUM(NSInteger, RefundType){
    RefundDefaults,
    RefundSellTicket,   /**  卖券还款   */
    ReturnTicket,     /**   现券还券   */
    BuyTicketReturn,  /**   买券还券  */
};

typedef NS_ENUM(NSInteger, CollateralType){
    
    CollateralTypeIn,   /**   担保品转入   */
    CollateralTypeOut,  /**   担保品转出 */
};


typedef NS_ENUM(NSInteger, DetailTradeType){
    
    CommonType,   /**  普通交易对账单  */
    MarginType,  /**   两融  */
    HKStockType,   /**   港股详情  */
};

//还款页面的tab切换
//typedef NS_ENUM(NSInteger, ReturnMoneyType){
//    SellTicketRefundType,    /**   卖券还款   */
//    MyMonryRefundType,    /**  现金还款  */
//};
//
////还券页面的tab切换
//typedef NS_ENUM(NSInteger, ReturnTicketType) {
//    MyTicketRefundType,    /**   现券还券  */
//    BuyTicketRefundType,   /**   买券还券  */
//};

typedef enum : NSUInteger {
    MarginTradeSearchTypeTodayEntrust,                /**  当日委托 */
    MarginTradeSearchTypeTodayTurnover,               /** 当日成交*/
    MarginTradeSearchTypeTodayHistory,
}MarginTradeSearchType;


//6.17.0-- 科创板保价

typedef enum : NSUInteger {
    MarginProtectPriceMovedUp,
    MarginProtectPriceMovedDown,
} MarginProtectPriceType;

typedef void (^priceProtectBlock)();

/**
 *  两融交易
 */
@protocol  PAS_MarginTrade <PAS_tradeBase, PAS_Entrust>

@property (nonatomic) TradeType tradeType;

@end

/**
 *  两融交易查询
 */
@protocol  PAS_margintraderecord <PAS_tradeBase>

@property (nonatomic) TradeType tradeType;

@end


/**
 *  两融：更多服务
 */
@protocol PAS_MarginTradeMoreService <PAS_tradeBase>

@end
/**
 *  两融:还款还券
 */
@protocol PAS_MarginTradeRefund <PAS_tradeBase>

@end

/**
 *  两融：融资买入
 */
@protocol PAS_marginfinancingtrade <PAS_tradeBase,PAS_Entrust,PAS_Trade>

//@property (nonatomic) FinaningTradeType finaningTradeType;

@end
/**
 *  两融：还款还券 --- 现金还款
 */
@protocol PAS_marginmoneyrefund <PAS_Entrust,NSObject>

@end

/**
 *  两融：卖券还款 && 现券还券 && 买券还券    ----- 需要定义三个类型
 */
@protocol PAS_marginticketrefund <NSObject>

@end

/**
 *  两融：资产负债
 */
@protocol PAS_margindebt <NSObject>

@property (nonatomic) AssetLiabilityTab assetLiabilityTab;

@end

/**
 *  两融：资产负债的单个VC
 */
@protocol PAS_margindebtSingle <NSObject>

@property (nonatomic) AssetLiabilityTab assetLiabilityTab;
@end

/**
 *  两融：资产负债
 */
@protocol PAS_margindebtsynthesize <PAS_margindebtSingle>


@end

/**
 *  两融：还款还券--- 融资还款模式
 */
@protocol PAS_refundPattern <NSObject>
@end

/**
 *  两融：还款还券  ---  现券还券 && 买券还券 && 卖券还款
 */
@protocol PAS_refundticket <PAS_Entrust,NSObject,PAS_Trade>

@property(nonatomic) RefundType refundType;

@end

/**
 *  两融：可融资证券查询 ** 可融券证券查询
 */
@protocol PAS_refundTicketQuery <NSObject>
@end

/**
 *  两融：担保品划转
 */
@protocol PAS_collateralTransferred <NSObject>

@end

/**
 *  两融--更多服务---信用额度申请
 */
@protocol  PAS_lineOfCredit <NSObject>

@end

/**
 *  两融  -- 更多服务 -- 修改密码
 */
@protocol PAS_marginPasswordChange <NSObject>

@end

/**
 *  两融  查询明细页面
 */
@protocol PAS_margintradequerydetail <NSObject>

@end

//6.16.0 两融划转结果页
@protocol PAS_margincollatertranferquerydetail <NSObject>

@end

/**
 现金还款 -- 指定合约归还
 */
@protocol PAS_selectecontract <NSObject>

@end

/**
 6.10两融新资产负债
 */
@protocol PAS_assetLiability <NSObject>

@end

/**
 6.10两融综合查询
 */
@protocol PAS_marginQueryList <NSObject>

@end
/**
 6.10两融利率查询
 */
@protocol PAS_marginRateQuery <NSObject>

@end
/**
 6.10两融标的券查询
 */
@protocol PAS_marginTargetQuery <NSObject>

@end
/**
 6.10两融对账单
 */
@protocol PAS_marginAccBill <NSObject>

@end
/**
 6.10两融  -- 现金还款
 */
@protocol PAS_marginMoneyReturnMoney <NSObject>

@end
/**
 6.10两融  -- 现券还券
 */
@protocol PAS_marginTicketReturnTicket <PAS_Entrust,PAS_refundticket>

@end


/**
 6.17.0 ---科创板 -- 保护价上涨
 */
@protocol PAS_marginPriceMovedUp <NSObject>
@property(nonatomic) MarginProtectPriceType marginProtectPrice;
@property(nonatomic,copy)priceProtectBlock clickStrBlock;

@end


/**
 6.17.0 ---科创板 -- 保护价下浮
 */
@protocol PAS_marginPriceMovedDown <NSObject>


@end

#endif /* PASMarginTradeProtocols_h */
