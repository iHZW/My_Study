//
//  MDFileManager.m
//  WeiKe
//
//  Created by WuShiHai on 3/16/16.
//  Copyright © 2016 WeiMob. All rights reserved.
//
#if APPLOGOPEN
#import "MDFileManager.h"

@implementation MDFileManager

+ (BOOL)wirteFile:(NSString *)path data:(NSDictionary *)data{
    return [data writeToFile:path atomically:YES];
}

+ (NSDictionary *)dictionaryOfFile:(NSString *)path{
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:path];
    return dic;
}


@end
#endif
