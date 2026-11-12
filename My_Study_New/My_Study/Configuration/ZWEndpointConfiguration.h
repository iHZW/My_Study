#import <Foundation/Foundation.h>
#import "EnvironmentType.h"

NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXPORT NSString *const ZWEndpointErrorDomain;
/// 纯配置与 URL 校验，不发起网络请求，不依赖 UIKit 或业务单例。
@interface ZWEndpointConfiguration : NSObject
+ (NSString *)nameForEnvironment:(EnvironmentType)environment;
+ (EnvironmentType)environmentForName:(NSString *)name;
+ (nullable NSURL *)validatedBaseURL:(NSString *)baseURL allowHTTP:(BOOL)allowHTTP error:(NSError * _Nullable * _Nullable)error;
+ (nullable NSURL *)resolvePath:(NSString *)path baseURL:(NSString *)baseURL allowHTTP:(BOOL)allowHTTP error:(NSError * _Nullable * _Nullable)error;
@end
NS_ASSUME_NONNULL_END
