//
//  ActionModel.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/2.
//  Copyright © 2022 HZW. All rights reserved.
//
/** 通用的列表model  带名称和点击方法名的  */
#import "ZWHttpNetworkData.h"

NS_ASSUME_NONNULL_BEGIN

@interface ActionModel : ZWHttpNetworkData

/** 名称  */
@property (nonatomic, copy) NSString *title;
/** 跳转方法名  */
@property (nonatomic, copy) NSString *actionName;

/**
 *  创建一个ActionModel
 *
 *  @param title    名称
 *  @param actionName    方法名
 *
 */
+ (instancetype)initWithTitle:(NSString *)title actionName:(NSString *)actionName;

@end

NS_ASSUME_NONNULL_END
