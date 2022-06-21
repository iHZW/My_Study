//
//  LogAppender.h
//  StarterApp
//
//  Created by js on 2019/7/12.
//  Copyright © 2019 js. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogConstants.h"
NS_ASSUME_NONNULL_BEGIN

@interface LogAppender : NSObject
- (void)log:(NSString *)msg level:(LogLevel)logLevel flag:(nullable NSString *)flag context:(id)context;
@end

NS_ASSUME_NONNULL_END
