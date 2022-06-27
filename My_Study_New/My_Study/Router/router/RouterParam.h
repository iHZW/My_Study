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
@property (nonatomic, strong) NSDictionary *params;
/**
 * 路由y业务类型
 */
@property (nonatomic, assign) RouterType type;

/**
 * 上下文 （当前ViewController）
 */
@property (nonatomic, strong) id context;

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
