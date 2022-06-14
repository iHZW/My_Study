//
//  PASHKStockProtocol.h
//  PASecuritiesApp
//
//  Created by 沐雨立 on 16/8/23.
//  Copyright © 2016年 PAS. All rights reserved.
//

#ifndef PASHKStockProtocol_h
#define PASHKStockProtocol_h

/**
 *  港股交易
 */
@protocol PAS_hkstock <PAS_Trade,PAS_Entrust>

@end

/**
 *  港股交易委托
 */
@protocol PAS_hkentrust <PAS_Entrust>

@end

/**
 *  持仓
 */
@protocol PAS_hkmyposition <PAS_myposition>

@end

/**
 *  交易查询
 */
@protocol PAS_hktraderecord <PAS_tradeRecord>

@end

/**
 申报
 */
@protocol PAS_hkdeclare <NSObject>

@end



#endif /* PASHKStockProtocol_h */
