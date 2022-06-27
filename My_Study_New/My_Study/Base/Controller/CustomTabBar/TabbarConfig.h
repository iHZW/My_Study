//
//  TabbarConfig.h
//  CRM
//
//  Created by js on 2021/11/2.
//  Copyright © 2021 CRM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZWHttpNetworkData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TabbarConfig : ZWHttpNetworkData<NSCopying>
@property (nonatomic, assign) long long tabType;
@property (nonatomic, copy) NSString *bizType;
@property (nonatomic, copy) NSArray *displayList;
@property (nonatomic, copy) NSArray *hiddenList;

+ (void)saveTabListConfig:(TabbarConfig *)config;
+ (TabbarConfig *)loadTabListConfig;
+ (TabbarConfig *)defaultTabbarConfig;
@end

NS_ASSUME_NONNULL_END
