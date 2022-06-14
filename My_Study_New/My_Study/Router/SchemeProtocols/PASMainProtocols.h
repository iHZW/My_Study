//
//  PASMainProtocols.h
//  PASecuritiesApp
//
//  Created by Howard on 16/4/14.
//  Copyright © 2016年 PAS. All rights reserved.
//

#ifndef PASMainProtocols_h
#define PASMainProtocols_h
/**
 *  资讯页面tab选择  6.3版本增加类型 以后版本如果增加type 应到对应页面进行映射来进行版本向上兼容
 */
typedef NS_ENUM(NSInteger, PASInfoPageTabType) {
    /**< 要闻 */
    PASInfoPageTabType_ImportanNews,
    /**< 直播 */
    PASInfoPageTabType_Live,
    /**< 推荐 */
    PASInfoPageTabType_RecomendBoth,
    /**< 自选 */
    PASInfoPageTabType_InfoOptional,
    /**< 机会 */
    PASInfoPageTabType_Chance,
    /**< 基金 */
    PASInfoPageTabType_LicaiNews,
    /**< 研报 */
    PASInfoPageTabType_ResearchReport
};


/**
 6.6 资讯页面顶部tab选择
 */
typedef NS_ENUM(NSInteger, PASInfoPageNewsTabType){
    // 资讯tab
    PASInfoPageNewsTabType_newsInfo,
    // 数据中心tab
    PASInfoPageNewsTabType_dataCenter
};

/**
 *  首页
 */
@protocol PAS_homepage <NSObject>

@end
/**
 *  消息中心
 */
@protocol PAS_notificationcenter <NSObject>

@end


/**
 *  理财
 */
@protocol PAS_licaipage <NSObject>

@end


@protocol PAS_InfoPage <NSObject>

@property (nonatomic, assign) PASInfoPageTabType tabType;
// 6.6 新增 资讯顶部tabType
@property (nonatomic, assign) PASInfoPageNewsTabType newstabtype;
@end

/**
 *  首页信息流
 */
@protocol PAS_homeflowInform <NSObject>

@end

/**
 *  首页搜索一级页面
 */
@protocol PAS_searchfirst <NSObject>

@end

/**
 *  搜索 二级页面
 */
@protocol PAS_searchsecond <NSObject>

@end

/**
 *  新首页搜索一级页面
 */
@protocol PAS_newsearchfirst <NSObject>

@end



/**
 *  首页 开户
 */
@protocol PAS_homeopenaccount <NSObject>

@end

/**
 *  VH视频列表页
 */
@protocol PAS_livelist <NSObject>
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *funcType;
@property (nonatomic, copy) NSString *liveType;
@property (nonatomic, copy) NSString *livefrom;
@end

/**
 *  首页 在线咨询
 */
@protocol PAS_consultonline <NSObject>

@end

/**
 *  分享 跳转 内嵌webview页面
 */
@protocol PAS_share <NSObject>

@end
/**
 *  微吼直播 跳转鉴权签署协议 结果回调处理
 */
@protocol PAS_vhauthoritysdk <NSObject>

@end
/**
 *  休眠户激活
 */
@protocol PAS_sleepaccount <NSObject>

@end

/**
 *  带Method方法的scheme跳转，公共类协议（scheme链接中公共“path”路径）
 */
@protocol PAS_openaccount <NSObject>

@end

/**
 *  带Method方法的scheme跳转，公共类协议（scheme链接中公共“path”路径）
 */
@protocol PAS_shareholderCard <NSObject>

@end

/**
 *  后续的开户业务可以用这个来对接 6.7.1
 */
@protocol PAS_openAccountSDK <NSObject>

@end

/**
 *  大智慧的 数据中心  需要用到dzh的webview来跳转
 */
@protocol PAS_dzhdatacenter <NSObject>

@end

/**
 *  大智慧的链接地址 需要用到dzh的webview来跳转
 */
@protocol PAS_dzhwebv <NSObject>

@end

/**
 *  Method方法的scheme跳转，公共类协议（scheme链接中公共“path”路径）---两融预约开户跳转页
 */
@protocol PAS_prerzkh <NSObject>

@end

/**
 6.15.0version 添加本地日历提醒
 */
@protocol PAS_MemorandumAdding <NSObject>

@end

#endif /* PASMainProtocols_h */
