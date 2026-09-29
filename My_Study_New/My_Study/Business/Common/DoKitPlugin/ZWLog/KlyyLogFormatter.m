//
//  KlyyLogFormatter.m
//  NbcbBank
//
//  Created by nbcb on 2024/3/20.
//  Copyright © 2024 musheng zhangyan. All rights reserved.
//

#import "KlyyLogFormatter.h"

@implementation KlyyLogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    if ([self isOnAllowlist:logMessage->_context]) {
        NSString *resultString = [NSString stringWithFormat:@"%@-%@", [self getTimeStamp], logMessage.message];
        return resultString;
    } else {
        return nil;
    }
}

- (NSString *)getTimeStamp {
    static dispatch_once_t onceToken;
    static NSDateFormatter *dateFormatter;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"YYYY.MM.dd-HH:mm:ss"];
    });
    return [dateFormatter stringFromDate:NSDate.date];
}
@end
