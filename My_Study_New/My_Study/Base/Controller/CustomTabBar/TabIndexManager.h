//
//  TabIndexManager.h
//  CRM
//
//  Created by js on 2021/11/18.
//  Copyright © 2021 CRM. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
    每一个网页VC 对应在tab 中的第位置
 */
@interface PageIndexObject: NSObject
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL showTab;

+ (instancetype)initWith:(NSInteger)index showTab:(BOOL)showTab;
@end

typedef void(^TabIndexChangeBlock)(NSInteger);
@interface TabIndexManager : NSObject
@property (nonatomic, copy,readonly) NSDictionary<NSString *,PageIndexObject*> *pageIndexMap;
+ (instancetype)shared;

/** 记录tab 显示的页面处于第几个tab */
- (void)updatePageIndexMap:(NSDictionary *)map;

#pragma TabIndex Event
/** 注册tab 顺序发生改变， 回调key 对应的页面， 在第几个*/
- (void)registerWebIndexChange:(NSString *)key callBack:(TabIndexChangeBlock)callBack;
- (void)unRegisterWebIndexChange:(NSString *)key;
- (void)unRegisterAllWebIndexChange;
//通知所有webview tab顺序发生了改变
- (void)notifyAllTabIndexChange;
//key 是vc 的内存地址
- (void)notifyTabIndexChange:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
