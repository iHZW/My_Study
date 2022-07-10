//
//  NSString+VersionCompare.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (VersionCompare)

//YES:  newestAppVersion > localVersion
+ (BOOL)compareVersion:(NSString *)newestAppVersion localVersion:(NSString *)localVersion;

//版本比较 version > otherVersion : 1  ; version = otherVersion : 0; version < otherVersion : -1
+ (NSInteger)compareVersion:(NSString *)version otherVersion:(NSString *)otherVersion;

@end

NS_ASSUME_NONNULL_END
