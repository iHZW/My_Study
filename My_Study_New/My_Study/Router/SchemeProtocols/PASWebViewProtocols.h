//
//  PASWebViewProtocols.h
//  PASecuritiesApp
//
//  Created by Howard on 16/5/25.
//  Copyright © 2016年 PAS. All rights reserved.
//

#ifndef PASWebViewProtocols_h
#define PASWebViewProtocols_h

/**
 *  内嵌Webview
 */
@protocol PAS_webv <NSObject>

@property (nonatomic, copy) NSString *requestURL;       //< 内嵌webview要打开的链接地址

@property (nonatomic, copy) NSString *webTitle;         //< 内嵌web view页面导航栏展示的title信息

@property (nonatomic, strong) NSString *htmlContent;    //< 内嵌web view页面显示的html信息

@property (nonatomic, strong) NSString *htmlPath;       //< 内嵌web view页面显示的本地html文件路径

@property (nonatomic) NSInteger strongAcc;              //< 登录类型 0:无需登录1:弱登录 2:强登录

@end


/**
 *  非单例内嵌Webview
 */

@protocol PAS_webvns <NSObject>

@property (nonatomic, copy) NSString *requestURL;       //< 内嵌webview要打开的链接地址

@property (nonatomic, copy) NSString *webTitle;         //< 内嵌web view页面导航栏展示的title信息

@property (nonatomic, strong) NSString *htmlContent;    //< 内嵌web view页面显示的html信息

@property (nonatomic) NSInteger strongAcc;              //< 登录类型 0:无需登录1:弱登录 2:强登录

@end


/**
 *  非单例内嵌Webview(支持横屏,pdf)
 */

@protocol PAS_gotopdf <PAS_webvns>

@property (nonatomic) NSInteger autorotate;              //< 是否支持横屏  0:不支持  1:支持

@end


@protocol PAS_recommend <PAS_webv>

@end

/**
 *  旧恒生框架Hybrid
 */
@protocol PAS_Hybrid <NSObject>

@property (nonatomic, copy) NSString *startPage;        // 起始页

@property (nonatomic, copy) NSString *targetName;       // 目标名称

@end


#endif /* PASWebViewProtocols_h */
