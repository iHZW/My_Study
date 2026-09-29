//
//  MMLoginModel.h
//  My_Study
//
//  Created by Zhiwei Han on 2023/1/7.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "ZWHttpNetworkData.h"

NS_ASSUME_NONNULL_BEGIN

@interface MMLoginModel : ZWHttpNetworkData

/** 错误码  */
@property (nonatomic, copy) NSString *errorCode;
/** 错误信息  */
@property (nonatomic, copy) NSString *errorMsg;
/** data: token  */
@property (nonatomic, copy) NSString *data;

@end

NS_ASSUME_NONNULL_END
