//
//  PASMarketProtocols.h
//  PASecuritiesApp
//
//  Created by Howard on 16/4/14.
//  Copyright © 2016年 PAS. All rights reserved.
//

#ifndef PASMarketProtocols_h
#define PASMarketProtocols_h

/**
 *  个股行情页面类型
 */
typedef NS_ENUM(NSInteger, StockMarketDetailType) {
    /**
     *  分时页面(默认)
     */
    StockMarketDetail_Minute,
    /**
     *  k线页面
     */
    StockMarketDetail_KLine,
};

 /** 市场行情首页tab类型 */
typedef NS_ENUM(NSInteger, MarketHomeType) {
    MarketHomeTypeHS = 0, /** 沪深 */
    MarketHomeTypeKCB = 5, /**< 科创板 */
    MarketHomeTypePlate = 1, /** 板块 */
    MarketHomeTypeGZ = 2, /**< 股指 */
    MarketHomeTypeHK = 3, /** 港美股 */
    MarketHomeTypeGlobal = 4, /** 全球 */
    MarketHomeTypeMore = 6, /** 更多 */
};

/** 评论页面类型 */
typedef enum : NSUInteger {
    CommentTypeDefault,     /** 默认进入评论页面 */
    CommentTypePost,        /** 发帖 */
}CommentType;

 /** 股票行情首页（组合页） */
@protocol PAS_market <NSObject>

 /** 市场行情首页tab类型 */
@property (nonatomic) MarketHomeType marketHomeType;

@end

/**< 行业板块 */
@protocol PAS_marketplate <NSObject>


@end

/**< 五分钟涨幅榜 */
@protocol PAS_marketfiveminzf <NSObject>


@end

/**< 次新股 */
@protocol PAS_nextnewstock <NSObject>

@end

/**< 资金净流量 */
@protocol PAS_marketzjl <NSObject>

@end




 /** 个股行情页面 */
@protocol PAS_stockdetail <NSObject>

/**证券代码(需要带SH，SZ市场类型等，scheme会将纯代码转成完整的)*/
@property (nonatomic, copy) NSString *code;

@optional
@property (nonatomic, copy) NSString *isScrollTop; /**< 1表示置顶  6.10大盘异动 */
/**证券名称*/
@property (nonatomic, copy) NSString *name;
/** 股票市场类型，SH，SZ等；6。0之前版本，对应恒生代码数字类型*/
@property (nonatomic, copy) NSString *codeType;
/** 股票类型,对应DZH_StkType */
@property (nonatomic, copy) NSString *stkType;
/** 页面显示类型(默认分时页面) */
@property (nonatomic) StockMarketDetailType type;
/** scheme来源渠道 */
@property (nonatomic, copy) NSString *channel;

// 列表使用
/**股票上下文数据，上一个、下一个时使用*/
@property (nonatomic, retain) NSArray *switchCodeList;
/**当前股票在股票上下文中的索引，上一个、下一个时使用*/
@property (nonatomic, assign) NSUInteger codeIndex;

@end

// /** 股票列表页面 */
//@protocol PAS_market <NSObject>
//
//@end

/** 股票组合列表页面 */
@protocol PAS_MarketGroupList <NSObject>

@end

/** 热评页面*/
@protocol PAS_hotcommentpage <NSObject>

@end

/**
 6.8.0version 新增股吧二级股票帖子列表页
 */
@protocol PAS_stockbarpage <NSObject>
@property (nonatomic, copy) NSString *stkcode;
@property (nonatomic, copy) NSString *stkname;
@property (nonatomic, copy) NSString *marketstktype;
@end

/** 评论页面*/
@protocol PAS_commentpage <NSObject>
@property (nonatomic) CommentType commentType;

@end
/**< 6.12新增多图发帖页面 */
@protocol PAS_postmessage <NSObject>

@property (nonatomic) CommentType commentType;

@end

/**<发帖话题 圈子列表页  */
@protocol PAS_postlist <NSObject>

@end


/**< 股票预警 */
@protocol PAS_stockremind <NSObject>

@end

/**< 新闻 公告 研报 */
@protocol PAS_marketnews <NSObject>

@end

/**<  公告 研报  详情页*/
@protocol PAS_marketnewsdetail <NSObject>

@end

/**<  板块联动 */
@protocol PAS_marketplatelink <NSObject>

@end

/** 个股研报 */
@protocol PAS_stockReport <NSObject>

/**证券代码(需要带SH，SZ市场类型等，scheme会将纯代码转成完整的)*/
@property (nonatomic, copy) NSString *code;
/** 股票市场类型，SH，SZ等；6。0之前版本，对应恒生代码数字类型*/
@property (nonatomic, copy) NSString *codeType;

@optional
/**证券名称*/
@property (nonatomic, copy) NSString *name;

@end

/** 个股公告 */
@protocol PAS_stockNotice <PAS_stockReport>

@end

/** 成交明细更多页*/
@protocol PAS_mingviewmore <NSObject>

@end

/** 6.19 新版成交明细更多页*/
@protocol PAS_trademingviewmore <NSObject>

@end

/** 自选股推送-热门股票页*/
@protocol PAS_marketHotStock <NSObject>

@end

/** 6.18 跟踪基金更多页面 */
@protocol PAS_marketIndexFundMore <NSObject>

@end

#endif /* PASMarketProtocols_h */
