//
//  ShareClient.h
//  My_Study
//
//  Created by Zhiwei Han on 2023/2/7.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "ShareObject+Platform.h"
#import "ShareObject.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CompressImageType) {
    CompressImageTypeThumb = 0,
    CompressImageTypeBig,
    CompressImageTypeMiniProgramHD,
    CompressImageTypeMiniThumb
};

typedef void (^ShareCompleteBlock)(BOOL, NSError *_Nullable);

typedef void (^ShareDownloadImageCompleteBlock)(UIImage *_Nullable, NSError *_Nullable);

typedef void (^WXLoginCompleteBlock)(NSString *_Nullable, NSError *_Nullable);

typedef void (^OpenMiniAppCompleteBlock)(BOOL, NSString *_Nullable, NSError *_Nullable);

@class MMShareManager;

@protocol ShareClientDelegte <NSObject>

- (void)downloadImage:(ShareObject *)shareObject complete:(ShareDownloadImageCompleteBlock)completeBlock;

- (NSData *)compressImage:(ShareObject *)shareObject source:(UIImage *)source type:(CompressImageType)type;

- (UIViewController *)topOfRootViewController;

- (void)handleMiniProgramExtMsg:(MMShareManager *)shareClient extMsg:(NSString *_Nullable)extMsg;

@end

@interface MMShareManager : NSObject

@property (nonatomic, weak, readonly) id<ShareClientDelegte> delegate;

+ (instancetype)sharedInstance;

+ (void)registerDelegate:(id<ShareClientDelegte>)delegate;

+ (void)registerWechat:(NSString *)appid universalLink:(NSString *)universalLink;

+ (void)shareObject:(ShareObject *)shareObject
           complete:(ShareCompleteBlock)completeBlock;

// 是否支持的分享 (默认YES)
+ (BOOL)isSupportShare:(ShareObject *)shareObject;


/// 打开小程序
/// - Parameters:
///   - shareObject: <#shareObject description#>
///   - completeBlock: <#completeBlock description#>
+ (void)openMiniApp:(ShareObject *)shareObject
           complete:(ShareCompleteBlock)completeBlock;


/// 微信登录
/// - Parameter completeBlock: 回调
+ (void)wxLogin:(WXLoginCompleteBlock)completeBlock;


/// 处理打开链接
/// - Parameter url: 链接
+ (BOOL)handleOpenURL:(NSURL *)url;

#pragma mark - Util

/// 检查微信是否已被用户安装
+ (BOOL)isWXAppInstalled;

/// 检测是否已安装QQ
+ (BOOL)isQQInstalled;

@end

NS_ASSUME_NONNULL_END
