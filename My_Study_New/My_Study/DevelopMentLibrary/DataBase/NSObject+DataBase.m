//
//  NSObject+DataBase.m
//  StarterApp
//
//  Created by js on 2019/7/12.
//  Copyright © 2019 js. All rights reserved.
//

#import "NSObject+DataBase.h"
#import "DataBaseManager.h"
@implementation NSObject (DataBase)

+ (DataBase *)dataBase{
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([self respondsToSelector:@selector(dbID)]){
            NSString *dbId = [self performSelector:@selector(dbID)];
            DataBase *dataBase = [[DataBaseManager sharedManager] getDataBase:dbId];
            return dataBase;
        }
        return nil;
    #pragma clang diagnostic pop
}
@end
