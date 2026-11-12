//
//  RouterParam.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouterConstants.h"

NS_ASSUME_NONNULL_BEGIN


typedef void(^RouterSuccessBlock)(id);

typedef void(^RouterFailBlock)(NSError *);

@interface RouterParam : NSObject
/// 导航执行结果由执行器填写，由 Router 合并为一条诊断日志。
@property (nonatomic, copy, nullable) NSString *navigationResult;
/// 已配置页面只在创建请求到导航执行期间持有，注入参数前清空，避免循环引用。
@property (nonatomic, strong, nullable) id preparedDestination;
@property (nonatomic, assign) BOOL usesPreparedDestination;
@property (nonatomic, strong, nullable) NSNumber *navigationAnimated;
@property (nonatomic, copy, nullable) void (^presentationCompletion)(void);
@property (nonatomic, strong, nullable) NSNumber *tabSelectionIndex;

/**
 * 原始跳转的URL
 */
@property (nonatomic, copy) NSString *originUrl;
/**
 * 解析出的URL。看解析block解析.
 */
@property (nonatomic, copy) NSString *destURL;
/**
 * 参数
 */
@property (nonatomic, copy) NSDictionary *params;
/**
 * 路由y业务类型
 */
@property (nonatomic, assign) RouterType type;

/**
 * 上下文 （当前ViewController）
 */
@property (nonatomic, weak, nullable) id context;

//业务成功之后的回调
@property (nonatomic, copy, nullable) RouterSuccessBlock successBlock;

@property (nonatomic, copy,nullable) RouterFailBlock failBlock;


+ (instancetype)makeWith:(NSString*)originUrl
                 destURL:(NSString *)destURL
                  params:(NSDictionary *)params
                    type:(RouterType)type
                 context:(nullable id)context;

+ (instancetype)makeWith:(NSString*)originUrl
                 destURL:(NSString *)destURL
                  params:(NSDictionary *)params
                    type:(RouterType)type
                 context:(nullable id)context
                 success:(nullable RouterSuccessBlock)successBlock
                    fail:(nullable RouterFailBlock)failBlock;

@end

NS_ASSUME_NONNULL_END
