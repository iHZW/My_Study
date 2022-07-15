//
//  CRC32.h
//  PASecuritiesApp
//
//  Created by Howard on 16/8/8.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CRC32 : NSObject

+ (unsigned int)getCRC32ValueByData:(NSData *)data;

@end
