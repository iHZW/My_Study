//
//  ZWMemberApi.h
//  My_Study
//
//  会员管理模块的网络层：直连本地 NestJS 服务（member-system/server）。
//  独立于 App 现有网络层，避免污染其它接口的请求配置。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** data 为接口返回的 data 字段；失败时 error 的 localizedDescription 为服务端 errmsg */
typedef void (^ZWMemberApiCompletion)(NSDictionary *_Nullable data, NSError *_Nullable error);

@interface ZWMemberApi : NSObject

/** 服务器地址，默认 http://127.0.0.1:3000（模拟器）；真机请改为电脑局域网 IP */
+ (NSString *)baseURL;
+ (void)setBaseURL:(NSString *)baseURL;

+ (BOOL)hasToken;
+ (void)clearToken;

/** 当前登录用户信息（id/username/realName/role），未登录为 nil */
+ (nullable NSDictionary *)currentUser;
/** 退出登录：清除 token 与当前用户信息 */
+ (void)logout;

/** 登录（默认账号 admin/admin123），成功后自动保存 token 与用户信息 */
+ (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
               completion:(ZWMemberApiCompletion)completion;

/** 会员分页列表 */
+ (void)fetchMembersWithPage:(NSInteger)page
                        size:(NSInteger)size
                     keyword:(nullable NSString *)keyword
                  completion:(ZWMemberApiCompletion)completion;

/** 会员详情 */
+ (void)fetchMemberDetail:(NSInteger)memberId completion:(ZWMemberApiCompletion)completion;

/** 会员消费订单 */
+ (void)fetchMemberOrders:(NSInteger)memberId completion:(ZWMemberApiCompletion)completion;

/** 新增会员（仅需姓名 + 手机号） */
+ (void)createMemberWithName:(NSString *)name
                       phone:(NSString *)phone
                  completion:(ZWMemberApiCompletion)completion;

@end

NS_ASSUME_NONNULL_END
