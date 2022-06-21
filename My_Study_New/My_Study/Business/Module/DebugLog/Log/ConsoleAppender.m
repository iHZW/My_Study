//
//  ConsoleAppender.m
//  StarterApp
//
//  Created by js on 2019/7/12.
//  Copyright © 2019 js. All rights reserved.
//

#import "ConsoleAppender.h"
#import "DateUtil.h"

@implementation ConsoleAppender

+ (NSString *)formate:(NSString *)msg level:(LogLevel)logLevel flag:(NSString *)flag context:(id)context{
    NSString *log = [[NSString alloc] initWithFormat:@"[%@]-[%@]-[%@]-[%@]-[%@] : %@",
                     logLevelString(logLevel),
                     [DateUtil prettyDateString],
                     flag,
                     NSStringFromClass([context class]),
                     [NSThread mainThread],
                     msg];
    return log;
}

- (void)log:(NSString *)msg level:(LogLevel)logLevel flag:(NSString *)flag context:(id)context{
    NSString *log = [ConsoleAppender formate:msg level:logLevel flag:flag context:context];
    NSLog(@"%@",log);
}
@end
