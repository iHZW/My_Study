//
//  StoreUtil.m
//  CRM
//
//  Created by js on 2020/4/21.
//  Copyright © 2020 js. All rights reserved.
//

#import "StoreUtil.h"
#import <SAMKeychain/SAMKeychain.h>

@implementation StoreUtil
+ (void)setString:(NSString *)object forKey:(NSString *)key isPermanent:(BOOL)isPermanent{
    if (key.length == 0){
        return;
    }
    if (object == nil){
        [self removeForKey:key isPermanent:isPermanent];
    }
    
    if (isPermanent){
        NSString *service = [NSString stringWithFormat:@"app.store.service"];
        [SAMKeychain setPassword:object forService:service account:key];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)removeForKey:(NSString *)key isPermanent:(BOOL)isPermanent{
    if (key.length == 0){
        return;
    }
    
    if (isPermanent){
        NSString *service = [NSString stringWithFormat:@"app.store.service"];
        [SAMKeychain deletePasswordForService:service account:key];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSString *)stringForKey:(NSString *)key isPermanent:(BOOL)isPermanent{
    if (key.length == 0){
        return nil;
    }
    
    if (isPermanent){
        NSString *service = [NSString stringWithFormat:@"app.store.service"];
        NSString *value = [SAMKeychain passwordForService:service account:key];
        return value;
    } else {
        NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:key];
        return value;
    }
}
@end
