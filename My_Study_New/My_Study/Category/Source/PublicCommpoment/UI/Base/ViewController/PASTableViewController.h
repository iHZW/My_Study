//
//  PASTableViewController.h
//  PASecuritiesApp
//
//  Created by Weirdln on 16/5/3.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "PASBaseViewController.h"
#import "PASBaseTableView.h"
#import "ZWTableViewHeaderView.h"
#import "ZWTipView.h"

// 默认的cell重用标签
static NSString *pasDefaultCellIdentifier = @"pasDefaultCellIdentifier";

@interface PASTableViewController : PASBaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong, readonly) PASBaseTableView *tableView;
@property (nonatomic, strong, readonly) ZWTableViewHeaderView *tableViewHeader;  /** 简单的header直接调用 */
@property (nonatomic, strong, readonly) ZWTipView *tipView;  /**   中间无记录的tipView  */
@property (nonatomic, strong, readonly) UIButton *refreshBtn; /**   刷新按钮  **/

@property (nonatomic) UITableViewStyle style;  /** 设置tableview样式，需要在viewdidload之前 */
@property (nonatomic, strong) Class tableCellClass; /** 设置统一tableCellClass，需要在viewdidload之前 */

@property (nonatomic) NSInteger cellCount;
@property (nonatomic) CGFloat cellHeight;
@property (nonatomic) CGFloat heightForHeader;
@property (nonatomic, strong) NSMutableArray *dataArray;  /**   有分组时候，把每组数据的数组放到dataArray里     */
@property (nonatomic) NSInteger sectionCount;

@property (nonatomic, copy) void (^cellConfigBlock)(NSIndexPath *, id cell);
@property (nonatomic, copy) void (^cellClickBlock)(NSIndexPath *, id cell);

// 继承的时候可以重写此方法直接设置tablecell
- (void)setupTableCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
