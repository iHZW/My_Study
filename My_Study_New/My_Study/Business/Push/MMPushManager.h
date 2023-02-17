//
//  MMPushManager.h
//  My_Study
//
//  Created by hzw on 2023/2/17.
//  Copyright © 2023 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMPushManager : NSObject

+ (instancetype)sharedInstance;

- (void)startGTSDKOptions:(NSDictionary *)launchOptions;




@end

NS_ASSUME_NONNULL_END
