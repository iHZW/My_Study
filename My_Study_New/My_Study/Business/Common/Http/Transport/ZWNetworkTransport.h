#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN
/// 传输层只负责 HTTP，不解析业务成功码、不弹窗、不自动重试写操作。
@interface ZWNetworkTransport : NSObject
+ (AFHTTPSessionManager *)defaultManager;
/// 请求创建后以快照发送，回调固定在主线程；返回任务可直接取消。
+ (NSURLSessionDataTask *)sendRequest:(NSURLRequest *)request
                             manager:(AFHTTPSessionManager *)manager
                             taskKey:(nullable NSString *)taskKey
                      uploadProgress:(nullable void (^)(NSProgress *progress))uploadProgress
                    downloadProgress:(nullable void (^)(NSProgress *progress))downloadProgress
                          completion:(void (^)(NSURLSessionDataTask *task, id _Nullable data, NSError * _Nullable error))completion;
+ (void)cancelTasksForManager:(AFHTTPSessionManager *)manager key:(nullable NSString *)key;
@end
NS_ASSUME_NONNULL_END
