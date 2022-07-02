//
//  PASTableViewController.m
//  PASecuritiesApp
//
//  Created by Weirdln on 16/5/3.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "PASTableViewController.h"
#import "UIViewCategory.h"

@interface PASTableViewController ()

@property (nonatomic, strong) PASBaseTableView *tableView;
@property (nonatomic, strong) ZWTableViewHeaderView *tableViewHeader;  /** 简单的header直接调用 */
@property (nonatomic, strong) ZWTipView *tipView;  /**   中间无记录的tipView  */
@property (nonatomic, strong) UIButton *refreshBtn; /**   刷新按钮  **/

@end

@implementation PASTableViewController

#pragma mark ----- Overload super methods

- (void)receiveLowMemoryWarning
{
    [super receiveLowMemoryWarning];
    self.tableView = nil;
}

- (void)initExtendedData
{
    [super initExtendedData];
    self.cellHeight = 44;
}

- (void)loadUIData
{
    [super loadUIData];
    
    self.tableView = [[PASBaseTableView alloc] initWithFrame:self.view.bounds style:self.style];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //ios11默认开启 Self-Sizing
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerClass:self.tableCellClass ?: [UITableViewCell class] forCellReuseIdentifier:pasDefaultCellIdentifier];
//    if (self.style == UITableViewStylePlain)
    
// 线条设置在对应子类中修改 在ios8中 先设置该属性再注册cell  在获取cell的时候 返回为空，会引发崩溃.
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view).priority(MASLayoutPriorityDefaultLow);
    }];
}

- (ZWTableViewHeaderView *)tableViewHeader
{
    if (!_tableViewHeader)
    {
        _tableViewHeader = [[ZWTableViewHeaderView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 30)];
        _tableViewHeader.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_tableViewHeader];
        
        [_tableViewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.view).priority(MASLayoutPriorityDefaultLow);
            make.height.mas_equalTo(30).priority(MASLayoutPriorityDefaultLow);
        }];
        
        [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(_tableViewHeader.mas_bottom).priority(MASLayoutPriorityDefaultLow);
        }];
    }
    return _tableViewHeader;
}

- (ZWTipView *)tipView
{
    if (!_tipView) {
        _tipView = [[ZWTipView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth * 0.8, PASFactor(115)) tipImage:[UIImage imageNamed:@"optional_bg"] tipInfo:@"没有记录"];
        [self.view addSubview:_tipView];
        [_tipView setHidden:YES];
        CGFloat headerViewHeight = self.tableView.tableHeaderView.height;
        CGFloat restHeight = self.view.height - headerViewHeight;
        CGFloat y = self.view.height - restHeight / 2;
        [_tipView setCenter:CGPointMake(kMainScreenWidth / 2, y)];
    }
    return _tipView;
}

- (UIButton *)refreshBtn
{
    if (!_refreshBtn) {
     
        CGFloat width = 130;
        CGFloat headerViewHeight = self.tableView.tableHeaderView.height;
        CGFloat restHeight = self.view.height - headerViewHeight;
        CGFloat y = self.view.height - restHeight / 2;
        _refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _refreshBtn.frame = CGRectMake((kMainScreenWidth - width) / 2,y + 30 , width, 44);
        [_refreshBtn setTitle:@"刷新" forState:UIControlStateNormal];
        [_refreshBtn.titleLabel setFont:PASFont(18)];
        [_refreshBtn setTitleColor:UIColorFromRGB(0xaf292e) forState:UIControlStateNormal];
        [_refreshBtn setBackgroundColor:[UIColor clearColor]];
        _refreshBtn.layer.cornerRadius = 5;
        _refreshBtn.layer.borderWidth = 1;
        _refreshBtn.layer.borderColor = UIColorFromRGB(0xaf292e).CGColor;
        
        [self.view addSubview:_refreshBtn];
        _refreshBtn.hidden = YES;
        
    }
    return _refreshBtn;
}

- (void)setupTableCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark ------ UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_dataArray count]&&[_dataArray[section] isKindOfClass:[NSArray class]]) {
        return [_dataArray[section] count];
    }
    return self.cellCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_dataArray) {
        return _dataArray.count;
    }
    return 1;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:pasDefaultCellIdentifier];
    cell.clipsToBounds = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self setupTableCell:cell atIndexPath:indexPath];
    if (self.cellConfigBlock)
    {
        self.cellConfigBlock(indexPath, cell);
    }
    return cell;
}

// 为了保证group的header不显示
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0;
    if (self.style == UITableViewStyleGrouped && section == 0) {
        height = 0.01;
    }
    if (section > 0 ) {
        height = _heightForHeader;
    }
    return height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return self.style == UITableViewStyleGrouped ? 0.01 : 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellClickBlock)
    {
        self.cellClickBlock(indexPath, [tableView cellForRowAtIndexPath:indexPath]);
    }
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    self.tableView = nil;
}

@end
