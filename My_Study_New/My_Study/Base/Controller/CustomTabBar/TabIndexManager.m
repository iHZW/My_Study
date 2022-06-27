//
//  TabIndexManager.m
//  CRM
//
//  Created by js on 2021/11/18.
//  Copyright © 2021 CRM. All rights reserved.
//

#import "TabIndexManager.h"

@implementation PageIndexObject
+ (instancetype)initWith:(NSInteger)index showTab:(BOOL)showTab{
    PageIndexObject *object = [[PageIndexObject alloc] init];
    object.index = index;
    object.showTab = showTab;
    return object;
}
@end

@interface TabIndexManager()
@property (nonatomic, copy,readwrite) NSDictionary<NSString *,PageIndexObject*> *pageIndexMap;
@property (nonatomic, strong) NSMutableDictionary *tabIndexCallbackMap;
@end

@implementation TabIndexManager
+ (instancetype)shared{
    static TabIndexManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[TabIndexManager alloc] init];
    });
    return _instance;
}

- (NSMutableDictionary *)tabIndexCallbackMap{
    if (!_tabIndexCallbackMap){
        _tabIndexCallbackMap = [NSMutableDictionary dictionary];
    }
    return _tabIndexCallbackMap;
}
#pragma Tab Index
- (void)updatePageIndexMap:(NSDictionary *)map{
    self.pageIndexMap = map;
    [self notifyAllTabIndexChange];
}

/** 注册tab 顺序发生改变， 回调key 对应的页面， 在第几个*/
- (void)registerWebIndexChange:(NSString *)key callBack:(TabIndexChangeBlock)callBack{
    [self.tabIndexCallbackMap setObject:callBack forKey:key];
}

- (void)unRegisterWebIndexChange:(NSString *)key{
    [self.tabIndexCallbackMap removeObjectForKey:key];
}

- (void)unRegisterAllWebIndexChange{
    [self.tabIndexCallbackMap removeAllObjects];
}

//通知所有webview tab顺序发生了改变
- (void)notifyAllTabIndexChange{
    NSArray *allKeys = [self.tabIndexCallbackMap allKeys];
    for (NSString *key in allKeys){
        [self notifyTabIndexChange:key];
    }
}
//key 是vc 的内存地址
- (void)notifyTabIndexChange:(NSString *)key{
    TabIndexChangeBlock callback = [self.tabIndexCallbackMap objectForKey:key];
    if (callback){
        PageIndexObject *pageIndexObject = [self.pageIndexMap objectForKey:key];
        callback(pageIndexObject.index);
    }
    
}
@end
