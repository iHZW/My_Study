//
//  CMNetLayerNotificationCenter.m
//  PASecuritiesApp
//
//  Created by Howard on 16/2/3.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "CMNetLayerNotificationCenter.h"

@implementation CMNetLayerNotificationCenter

+ (id)defaultCenter
{
    // The shared "default" instance created as needed
    static id sharedNotificationCenter;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedNotificationCenter = [[CMNetLayerNotificationCenter alloc] init];
    });

    return sharedNotificationCenter;
}

@end