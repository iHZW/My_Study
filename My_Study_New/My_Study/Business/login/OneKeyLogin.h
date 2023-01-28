//
//  OneKeyLogin.h
//  My_Study
//
//  Created by Zhiwei Han on 2023/1/17.
//  Copyright © 2023 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OneKeyLoginDelegate <NSObject>
/** 预登录结果*/
- (void)oneKeyPreGetPhonenumberResult:(NSError *)error;
/** 拉起授权页结果 */
- (void)oneKeyAuthResult:(NSError *)error;
/** 登录结果 */
- (void)oneKeyLoginResult:(nullable NSDictionary *)data error:(nullable NSError *)error;
/** 登录结果监听 */
- (void)oneKeyLoginActionListener:(NSInteger)type code:(NSInteger)code;
@end

@interface OneKeyLogin : NSObject
DEFINE_SINGLETON_T_FOR_HEADER(OneKeyLogin)

@property (nonatomic, weak) UIViewController *viewController;

@property (nonatomic, weak) id<OneKeyLoginDelegate> delegate;

@property (nonatomic, assign) BOOL isBinding;

- (void)config:(NSString *)appId;
// 预取号
- (void)preGetPhonenumber;

- (void)quickAuthLogin:(NSString *)loginButtonText;
// 关闭授权页
- (void)finishAuthControllerCompletion:(nullable dispatch_block_t)completeBlock;
/** 登录按钮  */
- (void)performLogin;

@end

NS_ASSUME_NONNULL_END
