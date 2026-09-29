//
//  ZWOneKey.h
//  My_Study
//
//  Created by Zhiwei Han on 2023/2/4.
//  Copyright © 2023 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CL_ShanYanSDK/CL_ShanYanSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZWOneKey : NSObject<CLShanYanSDKManagerDelegate>

+ (instancetype)staticInstance;

@end

NS_ASSUME_NONNULL_END
