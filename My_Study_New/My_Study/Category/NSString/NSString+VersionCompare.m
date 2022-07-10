//
//  NSString+VersionCompare.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "NSString+VersionCompare.h"

@implementation NSString (VersionCompare)

//YES:  newestAppVersion > localVersion
+ (BOOL)compareVersion:(NSString *)newestAppVersion localVersion:(NSString *)localVersion
{
    if (newestAppVersion.length == 0){
        return NO;
    }
    
    NSArray *newestAppVersionComponents = [newestAppVersion componentsSeparatedByString:@"."];
    NSArray *localVersionComponents = [localVersion componentsSeparatedByString:@"."];
    for (NSInteger i = 0; i < localVersionComponents.count; i++){
        NSString *local = [localVersionComponents objectAtIndex:i];
        NSString *server = [newestAppVersionComponents objectAtIndex:i];
        if ([local integerValue] < [server integerValue]){
            return YES;
        } else if ([local integerValue] > [server integerValue]){
            return NO;
        }
    }
    return NO;
}


//版本比较 version > otherVersion : 1  ; version = otherVersion : 0; version < otherVersion : -1
+ (NSInteger)compareVersion:(NSString *)version otherVersion:(NSString *)otherVersion
{
    NSArray *versionComponents = [version componentsSeparatedByString:@"."];
    NSArray *otherVersionComponents = [otherVersion componentsSeparatedByString:@"."];
    if (versionComponents.count == otherVersionComponents.count){
        for (NSInteger i = 0; i < otherVersionComponents.count; i++){
            NSString *left = [versionComponents objectAtIndex:i];
            NSString *right = [otherVersionComponents objectAtIndex:i];
            if ([left integerValue] > [right integerValue]){
                return 1;
            } else if ([left integerValue] < [right integerValue]){
                return -1;
            }
        }
    }
    return 0;
}

@end
