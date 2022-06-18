//
//  ModuleContainer.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/17.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ModuleContainer.h"
#import "DataBaseManager.h"
#import "PathConstants.h"
#import "ConsoleAppender.h"
#import "DatabaseAppender.h"

@interface ModuleContainer ()

@property (nonatomic, strong, readwrite) HttpClient *http;


@end


@implementation ModuleContainer
DEFINE_SINGLETON_T_FOR_CLASS(ModuleContainer)



- (void)registerConfig
{
    //数据库
    [self registerDB];
    
    //日志配置
    [self registerLog];
        
}

#pragma mark - DB
- (void)registerDB
{
    [DataBaseManager registerRootDirectory:[PathConstants appDataDirectory]];
}

#pragma mark - Log
- (void)registerLog{

    NSArray *logAppenders = @[[ConsoleAppender new],[DatabaseAppender new]];
    [LogUtil setLogAppenders:logAppenders];

    //开发的时候，不想打印某一个模块的日志，可以在这里添加忽略
    [LogUtil configIgnoreFlagsLog:@[@"Socket"]];
}


#pragma mark - lazyLoad
- (HttpClient *)http
{
    if (!_http) {
        _http = [HttpClient defaultClient];
    }
    return _http;
}

@end
