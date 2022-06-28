//
//  MDLogManager.h
//  WeiKe
//
//  Created by WuShiHai on 3/16/16.
//  Copyright © 2016 WeiMob. All rights reserved.
//
#if DOKIT
#import <Foundation/Foundation.h>

@interface MDLogManager : NSObject

+ (MDLogManager *)standardLogManager;

+ (void)logFile:(NSString *)response
        request:(NSString *)request
           method:(NSString *)method;

+ (NSArray *)todayLogFiles;

+ (NSString *)todayFilePath;

+ (BOOL)clearLog;

@end
#endif
