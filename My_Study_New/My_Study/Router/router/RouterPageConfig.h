//
//  RouterPageConfig.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouterConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface RouterPageConfig : NSObject

@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *clsName;
/**
 * 路由y业务类型
 */
@property (nonatomic, assign) RouterType type;
/**
 * 附加值
 * 解决：不同路由跳转到同一个类的时候，可以追加自己需要的参数。
 */
@property (nonatomic, strong) NSDictionary *attachValue;


+ (instancetype)makeWithUrl:(NSString *)url
                    clsName:(NSString *)clsName
                       type:(RouterType)type
                attachValue:(nullable NSDictionary *)value;

@end

NS_ASSUME_NONNULL_END
