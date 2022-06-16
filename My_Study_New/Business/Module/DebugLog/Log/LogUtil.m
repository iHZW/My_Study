//
//  LogUtil.m
//  StarterApp
//
//  Created by js on 2019/6/11.
//  Copyright © 2019 js. All rights reserved.
//

#import "LogUtil.h"
#import "LogAppender.h"

@interface LogUtil()
@property (nonatomic, assign) LogLevel logLevel;
@property (nonatomic, strong) NSArray *logAppenders;
@property (nonatomic, strong) NSArray *ignoreFlags;
@end

@implementation LogUtil

#pragma mark - Public

+ (void)setLogLevel:(LogLevel)logLevel{
    [[LogUtil shardInstace] setLogLevel:logLevel];
}

+ (void)setLogAppenders:(NSArray *)logAppenders{
    [[LogUtil shardInstace] setLogAppenders:logAppenders];
}

+ (void)configIgnoreFlagsLog:(NSArray *)flags{
    [[LogUtil shardInstace] setIgnoreFlags:flags];
}

+ (void)debug:(NSString *)msg flag:(nullable NSString *)flag context:(id)context{
    [[LogUtil shardInstace] log:msg level:LogLevelDebug flag:flag context:context];
}
    
+ (void)info:(NSString *)msg flag:(nullable NSString *)flag context:(id)context{
    [[LogUtil shardInstace] log:msg level:LogLevelInfo flag:flag context:context];
}
+ (void)warn:(NSString *)msg flag:(nullable NSString *)flag context:(id)context{
    [[LogUtil shardInstace] log:msg level:LogLevelWarn flag:flag context:context];
}
+ (void)error:(NSString *)msg flag:(nullable NSString *)flag context:(id)context{
    [[LogUtil shardInstace] log:msg level:LogLevelError flag:flag context:context];
}


#pragma mark - Private

+ (instancetype)shardInstace{
    static LogUtil *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LogUtil alloc] init];
        instance.logLevel = LogLevelDebug;
    });
    return instance;
}


- (void)log:(NSString *)msg level:(LogLevel)logLevel flag:(nullable NSString *)flag context:(id)context{
    
    if (flag && [self.ignoreFlags containsObject:flag]){
        return;
    }
    
    if (logLevel < self.logLevel){
        return;
    }
    
    for (LogAppender *appender in self.logAppenders){
        [appender log:msg level:logLevel flag:flag context:context];
    }
}

@end
