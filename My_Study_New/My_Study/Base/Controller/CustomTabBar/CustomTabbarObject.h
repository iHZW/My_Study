//
//  CustomTabbarObject.h
//  CRM
//
//  Created by js on 2021/11/2.
//  Copyright © 2021 CRM. All rights reserved.
//
/** tabBar  数据模型  */
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomTabbarObject : NSObject
@property (nonatomic, assign) long long code;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy,nullable) NSString *iconUrl;
@property (nonatomic, copy,nullable) NSString *selectedIconUrl;
@property (nonatomic, copy,nullable) NSString *editingIconUrl;

@property (nonatomic, copy) NSString *fontColor;
@property (nonatomic, copy) NSString *selectedFontColor;
@property (nonatomic, copy) NSString *route;

@property (nonatomic, strong,nullable) UIImage *icon;
+ (instancetype)initWith:(NSString *)title iconURL:(nullable NSString *)iconURL icon:(nullable UIImage *)icon color:(NSString *)color selectedColor:(NSString *)selectedColor;

- (NSString *)displayColor;
@end

NS_ASSUME_NONNULL_END
