//
//  LogDAO.h
//  CRM
//
//  Created by js on 2019/8/27.
//  Copyright © 2019 js. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface LogDAO : NSObject

+ (NSArray *)queryAllGroups;

+ (NSArray *)queryLogs:(nullable NSString *)flag;

+ (NSArray *)queryAllLogs;

+ (LogModel *)queryLogDetails:(NSUInteger)identity;

+ (void)deleteAll:(NSString *)context;
@end

NS_ASSUME_NONNULL_END
