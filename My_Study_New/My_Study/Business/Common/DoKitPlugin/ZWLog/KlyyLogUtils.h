//
//  LogUtils.h
//  NbcbBank
//
//  Created by nbcb on 2024/3/20.
//  Copyright © 2024 musheng zhangyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KlyyLogs.h"

NSString *DOC_OF_PATH(NSString *path);

@interface KlyyLogUtils : NSObject
+ (void)addLog:(NSString *)path logType:(KlyyLogType)logType;
@end
