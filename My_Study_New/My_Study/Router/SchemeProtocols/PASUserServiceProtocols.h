//
//  PASUserServiceProtocols.h
//  PASecuritiesApp
//
//  Created by Howard on 16/4/14.
//  Copyright © 2016年 PAS. All rights reserved.
//

#ifndef PASUserServiceProtocols_h
#define PASUserServiceProtocols_h

/**
 *  用户中心首页
 */
@protocol PAS_usercenter <NSObject>

@end

/**
 *  账户体系登录
 */

/**
 *  登录状态
 */
typedef NS_ENUM(NSInteger, PASLoginStatusType) {
    /**
     *  取消登录操作
     */
    PASLoginStatus_Cancel,
    /**
     *  登录成功
     */
    PASLoginStatus_Success,
    /**
     *  登录报错
     */
    PASLoginStatus_OtherInfo,
    
    /**
     *  去登录
     */
    PASLoginStatus_GotoLogin,
    
};

/**
 *  登录页面展示类型
 */
typedef NS_ENUM(NSInteger, PASLoginDispalyType) {
    /**
     *  一级登录态页面类型
     */
    PASLoginStatus_FirstLevel,
    /**
     *  二级登录态页面类型
     */
    PASLoginStatus_SecondLevel,
};

/**
 *  登录页面tab类型
 */
typedef NS_ENUM(NSInteger, PASLoginPageType) {
    /**
     *  普通登录
     */
    PASLoginPageType_CommonLogin,
    /**
     *  短信验证码登录
     */
    PASLoginPageType_OTPLogin
};

/**
 *  登录页面展示类型
 */
typedef NS_ENUM(NSInteger, PASMyAssetHoldingType) {
    /**
     *  人民币
     */
    PASMyAssetHoldingType_CNY,
    /**
     *  港币
     */
    PASMyAssetHoldingType_HKDollar,
    /**
     *  美元
     */
    PASMyAssetHoldingType_Dollar,
};

typedef NS_ENUM(NSInteger, PASCapitalAccountType) {
    PASCapitalAccountTypeStock,     // 股票账户
    PASCapitalAccountTypeFund,      // 理财账户
};
typedef NS_ENUM(NSInteger, PASStockOrderType) {
    OrderRecord,     // 成交记录
    OrderEnturst,      // 委托单
    OrderNewStock,  //打新记录
    OrderBill   //对账单
};

typedef void (^PASLoginActionBlock)(PASLoginStatusType status, NSInteger errCode);


@protocol PAS_login <NSObject>

@property (nonatomic, copy) NSString *currentAccount;//当前要显示用户，h5调用
@property (nonatomic, copy) NSString *referUrl; //h5页面跳转
@property (nonatomic, assign) NSInteger useclipboard;//是否使用剪切板作为账号
@property (nonatomic, copy) PASLoginActionBlock loginActionBlock;   //< 登录操作回调

@property (nonatomic) PASLoginStatusType displayType;               //< 登录页面显示类型
@property (nonatomic, assign) BOOL bolNoDissmissAnimated;//消失时是否没动画
@property (nonatomic, assign) BOOL bolTokenInvalid;//是否是token失效

@property (nonatomic, assign) PASLoginPageType pageType; /**<0 普通登录 1 验证码登录 */
@property (nonatomic, copy) NSString *aid;
@property (nonatomic, copy) NSString *sid;
@property (nonatomic, copy) NSString *ouid;
@property (nonatomic, copy) NSString *hdid;
@property (nonatomic, copy) NSString *mc_id;

@end


@protocol PAS_secondLogin <NSObject>

@property (nonatomic, copy) PASLoginActionBlock loginActionBlock;   //< 登录操作回调
@property (nonatomic, copy) NSString *currentAccount;//当前要显示用户，h5调用

@property (nonatomic) PASLoginStatusType displayType;               //< 登录页面显示类型
@property (nonatomic, assign) BOOL bolNoDissmissAnimated;//消失时是否没动画
@property (nonatomic, assign) BOOL bolTokenInvalid;//是否是token失效
@end


@protocol PAS_regist <NSObject>

@property (nonatomic, copy) NSString *promtionid;

@end

@protocol PAS_updateyztaccount <NSObject>

@end

@protocol PAS_quicklyregist <NSObject>

@end


@protocol PAS_setpassword <NSObject>

@end

@protocol PAS_setting <NSObject>


@end

@protocol PAS_systemsetup <NSObject>

@end

@protocol PAS_lockTradeTime <NSObject>


@end

@protocol PAS_about <NSObject>


@end

@protocol PAS_backdoor <NSObject>


@end

@protocol PAS_business <NSObject>


@end

@protocol PAS_service <NSObject>


@end

@protocol PAS_uploadidcard <NSObject>


@end

/**< 上传身份证 -- 修改密码 */
@protocol PAS_uploadidcardforchangepwd <NSObject>


@end

/**< 上传身份证 -- 要求界面 */
@protocol PAS_uploadidcardrequest <NSObject>


@end

/**< 视频认证界面 */
@protocol PAS_resetpassword <NSObject>

@end

@protocol PAS_modifyCardInfo <NSObject>

@property (nonatomic, strong) NSDictionary *dataDict;
@end

@protocol PAS_zhongdengList <NSObject>

@property (nonatomic, strong) NSArray *dataArr;

@end

@protocol PAS_myinformation <NSObject>


@end

@protocol PAS_completemyinfopage <NSObject>



@end


@protocol PAS_gotoMyAssetPage <NSObject>


@end

@protocol PAS_gotoMyAssetDetailsPage <NSObject>


@end

@protocol PAS_gotoassetdetail <NSObject>

@end

@protocol PAS_MyOrder <NSObject>


@end

@protocol PAS_MyStockOrder <NSObject>

@end

@protocol PAS_AccountSetting <NSObject>

@end

@protocol PAS_AccountSecurity <NSObject>

@end

@protocol PAS_PasswordManager <NSObject>

@end

@protocol PAS_StockAccount <NSObject>

@end

@protocol PAS_bindAccount <NSObject>

@end

@protocol PAS_BankCardManager <NSObject>


@end

@protocol PAS_wxBind <NSObject>

@end

@protocol PAS_yizhangtongBind <NSObject>

@end

/**
 *  业务办理  三方变更首页
 */
@protocol PAS_thirdcard <NSObject>

@end

/**
 *  业务办理 三方变更 处理流程页
 */
@protocol PAS_cardprocess <NSObject>

@end

/**
 *  登录时长
 */
@protocol PAS_loginLongTime <NSObject>


@end

/**
 *  站点选择
 */
@protocol PAS_chooseSite <NSObject>


@end

/**
 *  合格投资者资产认证  图片资料上传
 */
@protocol PAS_gotoassetevaluate <NSObject>


@end
/**
 *  合格投资者资产认证  审核进度
 */
@protocol PAS_assetauditproceeding <NSObject>


@end
/**
 *  合格投资者资产认证  审核结果
 */
@protocol PAS_assetauditresults <NSObject>


@end

/**
 *  聊天
 */
@protocol PAS_chatpage <NSObject>


@end

/**
 通讯录加好友
 */
@protocol PAS_invitecontacts <NSObject>

@end

/**
 6.3身份证有效期及升位原始信息确认，及流程页面
 */
@protocol PAS_expandidcardvalid <NSObject>

@end

/**
 6.3身份证有效期及升位，身份证识别信息确认页面
 */
@protocol PAS_expendIDCertainMsg <NSObject>

@end

/**
 6.3身份证有效期及升位，身份证正反面上传页面
 */
@protocol PAS_expendUploadIDImg <NSObject>

@end
/**
 6.3身份证有效期及升位，视频认证页面
 */
@protocol PAS_videoAuthentID <NSObject>

@end
/**
 6.3身份证有效期及升位，结果页
 */
@protocol PAS_expendIDCardResult <NSObject>

@end

/**
 6.3vh直播间界面承载页面
 */
@protocol PAS_vhlivevideocover <NSObject>

@end

/**
 6.5可信设备列表页
 */
@protocol PAS_credibledevicemanager <NSObject>

@end
/**
 6.5可信设备列表中某一设备详情页
 */
@protocol PAS_devicedetailinfo <NSObject>

@end
/**
 6.5设备可信认证页面
 */
@protocol PAS_authorcredible <NSObject>

@end
/**
 6.5设备可信认证结果页
 */
@protocol PAS_authorizeresult <NSObject>

@end

@protocol PAS_assetholdingstock <NSObject>

@property (nonatomic, assign) PASMyAssetHoldingType myAssetHoldingType;

@end

/**
 6.6新增股票订单
 */
@protocol PAS_stockorder <NSObject>

@property (nonatomic, assign) PASStockOrderType type;

@end

/**
 6.13业务办理-在线修改开户手机号
 */
@protocol PAS_changestockphonenumber <NSObject>

@end

@protocol PAS_changestockphonenumberresult <NSObject>

@end

@protocol PAS_feedback <NSObject>

@end

@protocol PAS_intelloginsetting <NSObject>


@end

@protocol PAS_intelloginagreee <NSObject>

@property (nonatomic, copy) NSString *account;

@end

@protocol PAS_intelloginbind <NSObject>

@property (nonatomic, copy) NSString *account;

@end

typedef void(^VerfifySuccessBlock)(void);

@protocol PAS_fingerverify <NSObject>

@property (nonatomic, assign) NSInteger pageType;
@property (nonatomic, copy) VerfifySuccessBlock successBlock;

@end
#endif /* PASUserServiceProtocols_h */
