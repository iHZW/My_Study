//
//  SelectedViewController.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/5.
//  Copyright © 2022 HZW. All rights reserved.
//

/**
 *  使用说明
 *
 *  @param dataList    列表数据
 *  @param  selectedName    选中项名称
 *  @param  isLoadSureBtn   是否需要顶部确认按钮,  YES: 需要, 点击按钮才会触发回调并返回    NO: 不需要, 选中之后直接返回上级界面并回调
 *
 */

#import "ZWBaseTableViewController.h"


typedef void (^SelectedActionBlock) (id _Nullable data);

NS_ASSUME_NONNULL_BEGIN

@interface SelectedViewController : ZWBaseTableViewController
/** 列表数据  dataList 中是  NSDictionary ,  字典中至少包含一个 selectName 的key */
@property (nonatomic, copy) NSArray<NSDictionary *> *dataList;
/** 选中回调, 回调选中项信息  */
@property (nonatomic, copy) SelectedActionBlock selectedActionBlock;
/** 选中项name  匹配选中index使用  */
@property (nonatomic, copy) NSString *selectedName;
/** 标题名称 , 默认选择页 */
@property (nonatomic, copy) NSString *titleName;

/** 是否加载确认按钮, 默认不加载,  选中之后就会返回上一级,  设置为YES之后, 需要点击确认按钮才返回上级并触发回调  */
@property (nonatomic, assign) BOOL isLoadSureBtn;


@end

NS_ASSUME_NONNULL_END
