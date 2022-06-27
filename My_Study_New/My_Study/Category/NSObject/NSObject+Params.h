//
//  NSObject+Params.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouterParam.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Params)

@property (nonatomic, strong) RouterParam *routerParamObject;

@property (nonatomic, copy) NSDictionary *routerParams;

@end

NS_ASSUME_NONNULL_END
