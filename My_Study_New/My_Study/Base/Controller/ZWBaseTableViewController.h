//
//  ZWBaseTableViewController.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/2.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWBaseViewController.h"
#import "ZWBaseTableView.h"
#import "ZWTableViewHeaderView.h"
#import "ZWTipView.h"
#import "BaseCellModel.h"

NS_ASSUME_NONNULL_BEGIN

// 默认的cell重用标签
static NSString *zwDefaultCellIdentifier = @"zwDefaultCellIdentifier";

@interface ZWBaseTableViewController : ZWBaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong, readonly) ZWBaseTableView *tableView;
/** 简单的header直接调用 */
@property (nonatomic, strong, readonly) ZWTableViewHeaderView *tableViewHeader;
/** 中间无记录的tipView  */
@property (nonatomic, strong, readonly) ZWTipView *tipView;
/** 刷新按钮  **/
@property (nonatomic, strong, readonly) UIButton *refreshBtn;
/** 设置tableview样式，需要在viewdidload之前 */
@property (nonatomic) UITableViewStyle style;
/** 设置统一tableCellClass，需要在viewdidload之前 */
@property (nonatomic, strong) Class tableCellClass;
/** cell个数  */
@property (nonatomic) NSInteger cellCount;
/** cell 高度  */
@property (nonatomic) CGFloat cellHeight;
/** 这个是设置每个headersection的高度, 从第二个section开始生效  */
@property (nonatomic) CGFloat heightForHeader;
/** 有分组时候，把每组数据的数组放到dataArray里    */
@property (nonatomic, strong) NSMutableArray *dataArray;
/** section个数  */
@property (nonatomic) NSInteger sectionCount;
/** 加载cell的回调  */
@property (nonatomic, copy) void (^cellConfigBlock)(NSIndexPath *indexPath, id cell);
/** 点击cell的回调  */
@property (nonatomic, copy) void (^cellClickBlock)(NSIndexPath *indexPath, id cell);


/**
 *  继承的时候可以重写此方法直接设置tablecell
 *
 *  @param cell    cell
 *  @param  indexPath    位置
 *
 */
- (void)setupTableCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
