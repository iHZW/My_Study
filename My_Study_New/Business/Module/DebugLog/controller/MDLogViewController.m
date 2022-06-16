//
//  MDLogViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/15.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "MDLogViewController.h"
#import "ZWBaseTableView.h"
#import "MDLogTableViewCell.h"
#import "MDLogManager.h"
#import "DebugLogHelper.h"
#import "LogDAO.h"
#import "DateUtil.h"
#import "UIColor+Ext.h"
#import "MDLogDetailViewController.h"

#define kLogViewCellIdentifier      @"kLogViewCellIdentifier"

@interface MDLogViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) ZWBaseTableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, assign) BOOL searching;

@property (nonatomic, strong) NSMutableArray *searchDataSource;

@end

@implementation MDLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    [self initData];
    [self loadSubViews];
}

- (void)initData
{
    switch (self.pageType) {
        case FromPageTypeDeault:
        {
            self.title = @"日志列表-Context";
            self.dataSource = [LogDAO queryAllGroups];
        }
            break;
            
        case FromPageTypeOne:
        {
            self.dataSource = [LogDAO queryLogs:self.context];
            self.title = @"日志列表-Flag";
        }
            break;
            
        case FromPageTypeTwo:
        {
            self.dataSource = [LogDAO queryAllLogs];
            self.title = @"所有日志";
        }
            break;
            
        default:
            break;
    }
}

- (void)setPageType:(FromPageType)pageType
{
    _pageType = pageType;
}

- (void)initRightNav
{
    [super initRightNav];
    
    UIBarButtonItem *allBarButton = [[UIBarButtonItem alloc] initWithTitle:@"全部" style:UIBarButtonItemStylePlain target:self action:@selector(allContextNavAction:)];
    UIBarButtonItem *clearBarButton = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(clearLogNavAction:)];
    self.navigationItem.rightBarButtonItems = @[allBarButton,clearBarButton];
}

- (void)allContextNavAction:(id)sender{
    MDLogViewController *vc = [[MDLogViewController alloc] init];
    vc.pageType = FromPageTypeTwo;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clearLogNavAction:(id)sender{
//    [LogDAO deleteAll:self.context];
    self.dataSource = @[];
//    [self.searchDataSource removeAllObjects];
    [self.tableView reloadData];
}


- (void)loadSubViews
{
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.mas_equalTo(kMainNavHeight + kSysStatusBarHeight);
    }];
}


#pragma mark - 处理 刷新/加载更多
- (void)dealWithRefresh
{
    [self.tableView endHeaderRefreshing];
}

- (void)dealWithLoadMore
{
    [self.tableView endFooterRefreshingWithHidden:YES];
}


#pragma mark - tableView delegate/dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return !self.searching ? self.dataSource.count : self.searchDataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MDLogTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLogViewCellIdentifier];
    
    LogModel *logModel = [!self.searching ? self.dataSource : self.searchDataSource objectAtIndex:indexPath.row];
    NSString *titleName = @"";
    NSString *subtitleName = @"";

    if (self.pageType == 0){
        titleName = logModel.context;
        subtitleName = [NSString stringWithFormat:@"%ld",logModel.count];
    } else if (self.pageType == 1) {
        titleName = [NSString stringWithFormat:@"%@",logModel.flag];
        subtitleName = [NSString stringWithFormat:@"[%@] %@",logModel.level,[DateUtil prettyDateStringForDate:logModel.createTime]];
    } else if (self.pageType == 2) {
        titleName = [NSString stringWithFormat:@"[%@] %@",logModel.context,logModel.flag];
        subtitleName = [NSString stringWithFormat:@"[%@] %@",logModel.level,[DateUtil prettyDateStringForDate:logModel.createTime]];
    }
    cell.titleName = TransToString(titleName);
    cell.subTitleName = TransToString(subtitleName);
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [[cell.contentView viewWithTag:1001] removeFromSuperview];
    if (indexPath.row < !self.searching ? self.dataSource.count : self.searchDataSource.count - 1) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, 74.5, [UIScreen mainScreen].bounds.size.width - 20, 0.5)];
        lineView.backgroundColor = [UIColor colorFromHexCode:@"e0e0e0"];
        [cell.contentView addSubview:lineView];
        lineView.tag = 1001;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LogModel *logModel = [!self.searching ? self.dataSource : self.searchDataSource objectAtIndex:indexPath.row];
    if (self.pageType == FromPageTypeDeault) {
        MDLogViewController *vc = [[MDLogViewController alloc] init];
        vc.pageType = FromPageTypeOne;
        vc.context = logModel.context;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        MDLogDetailViewController *vc = [[MDLogDetailViewController alloc] init];
        vc.identity = logModel.identifier;
        vc.index = indexPath.row;
        vc.queryIdentityBlock = ^NSUInteger(BOOL isUp,NSUInteger index) {
            LogModel *logModel = nil;
            
            if (isUp) {
                logModel = [!self.searching ? self.dataSource : self.searchDataSource objectAtIndex:index - 1];
            } else {
                logModel = [!self.searching ? self.dataSource : self.searchDataSource objectAtIndex:index + 1];
            }
            
            if (logModel) {
                return logModel.identifier;
            }
            
            return NSNotFound;
        };
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - lazyLoad
- (ZWBaseTableView *)tableView
{
    if (!_tableView) {
        _tableView = [[ZWBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[MDLogTableViewCell class] forCellReuseIdentifier:kLogViewCellIdentifier];
        @pas_weakify_self
        [_tableView loadFreshView:^{
            @pas_strongify_self
            [self dealWithRefresh];
        }];
        
//        [_tableView loadMoreView:^{
//           @pas_strongify_self
//            [self dealWithLoadMore];
//        }];
    }
    return _tableView;
}

- (NSMutableArray *)searchDataSource
{
    if (!_searchDataSource) {
        _searchDataSource = [NSMutableArray array];
    }
    return _searchDataSource;
}

- (void)dealloc {
//    if (self.dataSource) {
//        self.dataSource = nil;
//    }
//
//    [self.searchDataSource removeAllObjects];
//    self.searchDataSource = nil;
}

@end
