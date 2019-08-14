//
//  PASSZHKStockProtocol.h
//  PASecuritiesApp
//
//  Created by zhoujiexin on 16/10/18.
//  Copyright © 2016年 PAS. All rights reserved.
//

#ifndef PASSZHKStockProtocol_h
#define PASSZHKStockProtocol_h

/**
 *  港股交易
 */
@protocol PAS_szhkstock <PAS_Trade,PAS_Entrust>

@end

/**
 *  港股交易委托
 */
@protocol PAS_szhkentrust <PAS_Entrust>

@end

/**
 *  持仓
 */
@protocol PAS_szhkmyposition <PAS_myposition>

@end

/**
 *  交易查询
 */
@protocol PAS_szhktraderecord <PAS_tradeRecord>

@end


/**
 申报
 */
@protocol PAS_szhkdeclare <NSObject>

@end



#endif /* PASSZHKStockProtocol_h */
