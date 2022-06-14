//
//  PASMyStockProtocols.h
//  PASecuritiesApp
//
//  Created by Howard on 16/5/4.
//  Copyright © 2016年 PAS. All rights reserved.
//

#ifndef PASMyStockProtocols_h
#define PASMyStockProtocols_h

/**
 *  自选
 */
@protocol PAS_mystock <NSObject>

@end

/**< 自选编辑页面 */
@protocol PAS_mystockedit <NSObject>

@end

/**< 新建分组页面 */
@protocol PAS_buildgroup <NSObject>

@end

/**< 资金页面 */
@protocol PAS_analysis <NSObject>

@end

/**< 多股同列页面 */
@protocol PAS_multiMinute <NSObject>

@end

/**< 短线精灵页面 */
@protocol PAS_shortSpirit <NSObject>

@end

/**< 短线精灵设置页面 */
@protocol PAS_shortSpiritSetting <NSObject>

@end

/**< 自选回测搜索页面 */
@protocol PAS_myStockRetestSearch <NSObject>

@end

/**< 自选回测编辑页面 */
@protocol PAS_myStockRetestEdit <NSObject>

@end

/**< 自选回测页面 */
@protocol PAS_myStockRetest <NSObject>

@end

/**< 指数设置页面 */
@protocol PAS_MyStockIndexSetting <NSObject>

@end

/**< 行情指数设置页面 */
@protocol PAS_MarketIndexSetting <NSObject>

@end

/**< 分时叠加搜索页面 6.15*/
@protocol PAS_minuteOverlaySearch <NSObject>

@end

/**< 自选股识别导入页面  6.16*/
@protocol PAS_importStock <NSObject>

@end

/**< 行情 》更多可编辑 关注section  6.16*/
@protocol PAS_marketmoreedited <NSObject>

@end
#endif /* PASMyStockProtocols_h */
