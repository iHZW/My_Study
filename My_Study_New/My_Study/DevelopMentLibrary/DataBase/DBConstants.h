//
//  DBConstants.h
//  StarterApp
//
//  Created by js on 2019/7/12.
//  Copyright © 2019 js. All rights reserved.
//

#ifndef DBConstants_h
#define DBConstants_h

#import "DataBase.h"
#import "DataBaseManager.h"
#import "NSObject+DataBase.h"

#define DB_EXPORT_ID(identity) \
+ (NSString *)dbID { return identity; }
#endif /* DBConstants_h */


//通用的数据库ID （一般未登录使用）
#define DB_COMMON_ID @"common"
