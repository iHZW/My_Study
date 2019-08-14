//
//  PASTransferProtocols.h
//  PASecuritiesApp
//
//  Created by Howard on 16/4/14.
//  Copyright © 2016年 PAS. All rights reserved.
//

#ifndef PASTransferProtocols_h
#define PASTransferProtocols_h


/** 交易页面tab类型 */
typedef NS_ENUM(NSInteger, BankTransferType) {
    BankTransferToAccount, /** 银行转证券（转入） */
    BankTransferToBank, /** 证券转银行（转出） */
    BankTransferFlow, /** 转帐流水 */
};

/** 交易页面tab类型 */
typedef NS_ENUM(NSInteger, BankTransferCurrencyType) {
    BankTransferCurrencyType_RMB, //人民币
     BankTransferCurrencyType_HK, //港币
    BankTransferCurrencyType_US, //美元
};

/**< 银转类型(老银证) */
typedef NS_ENUM(NSInteger ,HsBankTransferType)
{
    kHsBankTransferTypeToStock = 0,
    kHsBankTransferTypeToBank,
    kHsBankBalanceAmount
};


/**
 6.3配号中签类型
 */
typedef NS_ENUM(NSInteger,PeihaoBallotType)
{
    PeihaoBallotTypeNo = 0,/* 未中签 */
    PeihaoBallotTypeYes,   /*  已中签 */
    PeihaoBallotTypeWaitPublish,  /* 未公布*/
};


// 6.18.0 新股g中心
typedef NS_ENUM (NSUInteger,TradeNewStockType){
    TradeNewStockTypeSubscribe = 0,                /**  新股申购 - 申购 */
    TradeNewStockTypeCheck,               /** 新股申购 - 查询*/
};

/**
 *  银证首页
 */
@protocol PAS_transferpage <NSObject>

@property (nonatomic, assign) BankTransferCurrencyType currencyType;
@property (nonatomic) BankTransferType transferType;
@property (nonatomic, copy) NSString *channelType;  //渠道类型

@end
/**
 *  两融 银证首页
 */
@protocol PAS_margintransferpage <NSObject>

@end

/**
 *  行情测试页面
 */
@protocol PAS_OptionTradePage <NSObject>

@property (nonatomic, copy) NSString *optionType;  //6.14 交易行情

@end
/**
 *  我的银行账户
 */
@protocol PAS_MyBankAccount <NSObject>

@property (nonatomic, copy) NSString *channelType;  //6.12 渠道类型

@end

/**
 *  添加银行卡
 */
@protocol PAS_bindbankcard <NSObject>

@property (nonatomic, copy) NSString *channelType;  //6.12 渠道类型

@end

/**
 *  银证互转
 */
@protocol PAS_BankInterTransfer <NSObject>

@end

/**
 *  银证查询
 */
@protocol PAS_BankQuery <NSObject>

@end

/**
 *  银证查询详情
 */
@protocol PAS_BankQueryDetail <NSObject>

@end

/**
 *  银证预约详情
 */
@protocol PAS_ReseverationListDetail <NSObject>

@end

/**
 *  所有银行卡列表
 */
@protocol PAS_AllBankList <NSObject>

@end

/**
 *  转入转出 结果页面
 */
@protocol PAS_bankresult <NSObject>

@end

/**
 *  新股中心
 */
@protocol PAS_onekeyapply <NSObject>

@property (nonatomic,copy) NSString *subscribe;  /*  预约申购6.2.0.1  */
@property (nonatomic) TradeNewStockType newStockType;
@end

/**
 *  配号中签查询
 */
@protocol PAS_distribution <NSObject>

@end


/**
 6.3配号中签页面改版
 */
@protocol PAS_peihaoballot <NSObject>

@end


/**
 中签比对页面（对外提供这个scheme  6.3先跳至中签列表页）
 */
@protocol PAS_zhongqiancomparison <NSObject>

@end


/**
 中签比对页面
 */
@protocol PAS_zqcomparison  <NSObject>

@end


/**
 *  更多交易
 */
@protocol PAS_moreTrade <NSObject>

@end

/**
 *  老的银证首页
 */
@protocol PAS_margintranstostock <NSObject>

//@property (nonatomic) BankTransferAccountType transferAccountType;

@end

/**
 *  老的多银行界面
 */
@protocol PAS_moreBankList <NSObject>

@end

/**
 *  银转详情页
 */
@protocol PAS_oldBankTransferDetail <NSObject>

@property (nonatomic) HsBankTransferType oldTransferType; /**< 转账类型 */
@property (nonatomic) BOOL isMultiBank;  /**< 判断是否是多银行 */

@end

/**
 *  主辅资金资金划转
 */
@protocol PAS_mainAssistTransfer <NSObject>


@end


/**
 *  转账流水查询
 */
@protocol PAS_oldBankTransferFlowing <NSObject>


@end


/**
 *  详情页
 */
@protocol PAS_oldBankTransferFlowingDetail <NSObject>


@end


/**
 *  存管银行查询
 */
@protocol PAS_depositBankQuery <NSObject>


@end


/**
 *  一键汇集界面
 */
@protocol PAS_oneKeyCollect <NSObject>


@end
/**
*  6.14.1  跳转到tradeOption
*/
@protocol PAS_tradeOptionWebView <NSObject>
@end


/**
 6.15.1 限售股票查询
 */
@protocol PAS_tradeRestrictedStock <NSObject>
@end

#endif /* PASTransferProtocols_h */
