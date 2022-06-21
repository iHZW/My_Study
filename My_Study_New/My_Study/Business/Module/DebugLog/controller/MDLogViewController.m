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
#import "MDLogSearchView.h"
#import "GCDCommon.h"

#define kLogViewCellIdentifier      @"kLogViewCellIdentifier"

@interface MDLogViewController ()<UITableViewDelegate, UITableViewDataSource>
/* 搜索框 */
@property (nonatomic, strong) MDLogSearchView *searchView;

@property (nonatomic, copy) NSString *searchKeyword;

@property (nonatomic, assign) NSInteger requestCount; /**< 防止重复请求过多 */

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
    [LogDAO deleteAll:self.context];
    self.dataSource = @[];
    [self.searchDataSource removeAllObjects];
    [self.tableView reloadData];
}


- (void)loadSubViews
{
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.mas_equalTo(kMainNavHeight + kSysStatusBarHeight);
    }];
    
    self.tableView.tableHeaderView = self.searchView;
    
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainScreenWidth, PASFactor(60)));
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

#pragma mark - 处理搜索后调
- (void)detailWithSearchNameBlock:(NSString *)searchName
{
    self.searchKeyword = searchName;
    if (self.searchKeyword.length > 0) {
        [self dealWithSearchChange];
    }
}

- (void)detailWithSearchStatusblock:(SearchStatusType)searchStatus
{
    if (searchStatus == SearchStatusTypeResign) {
        self.searchKeyword = @"";
        [self dealWithSearchChange];
    }
}

- (void)dealWithSearchChange
{
    self.requestCount++;
    NSInteger nowCount = self.requestCount;
    @pas_weakify_self
    performBlockDelay(dispatch_get_main_queue(), .3, ^{
        @pas_strongify_self
        if (nowCount == self.requestCount)
        {
            [self dealWithSearchDataSource];
        }
    });
}

- (void)dealWithSearchDataSource
{
    NSPredicate *predicate = nil;
    NSString *searchText = self.searchKeyword;
    if (self.searchKeyword.length > 0) {
        self.searching = YES;
        if (self.pageType == FromPageTypeDeault) {
            predicate = [NSPredicate predicateWithFormat:@"SELF.context CONTAINS[c] %@", searchText];
        } else if (self.pageType == FromPageTypeOne) {
            predicate = [NSPredicate predicateWithFormat:@"SELF.msg CONTAINS[c] %@", searchText];
        } else if (self.pageType == FromPageTypeTwo) {
            predicate = [NSPredicate predicateWithFormat:@"SELF.msg CONTAINS[c] %@", searchText];
        }
        if (predicate) {
            [self.searchDataSource removeAllObjects];
            NSArray *filteredArray = [self.dataSource filteredArrayUsingPredicate:predicate];
            [self.searchDataSource addObjectsFromArray:TransToArray(filteredArray)];
        }
    } else {
        self.searching = NO;
        [self.searchDataSource removeAllObjects];
    }
    [self.tableView reloadData];
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
    return self.pageType == FromPageTypeDeault ? 60.0 : 80.0;
}

- (void)dealWithTitleName:(NSString **)titleName
             subTitleName:(NSString **)subTitleName
                 logModel:(LogModel *)logModel
{
    switch (self.pageType) {
        case FromPageTypeDeault:
        {
            *titleName = logModel.context;
            *subTitleName = [NSString stringWithFormat:@"%ld",logModel.count];
        }
            break;
        case FromPageTypeOne:
        {
            *titleName = [NSString stringWithFormat:@"%@",logModel.flag];
            *subTitleName = [NSString stringWithFormat:@"[%@] %@",logModel.level,[DateUtil prettyDateStringForDate:logModel.createTime]];
        }
            break;
        case FromPageTypeTwo:
        {
            *titleName = [NSString stringWithFormat:@"[%@] %@",logModel.context,logModel.flag];
            *subTitleName = [NSString stringWithFormat:@"[%@] %@",logModel.level,[DateUtil prettyDateStringForDate:logModel.createTime]];
        }
            break;
        default:
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MDLogTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLogViewCellIdentifier];
    
    LogModel *logModel = [!self.searching ? self.dataSource : self.searchDataSource objectAtIndex:indexPath.row];
    NSString *titleName = @"";
    NSString *subtitleName = @"";
    [self dealWithTitleName:&titleName subTitleName:&subtitleName logModel:logModel];
//    if (self.pageType == FromPageTypeDeault){
//        titleName = logModel.context;
//        subtitleName = [NSString stringWithFormat:@"%ld",logModel.count];
//    } else if (self.pageType == FromPageTypeOne) {
//        titleName = [NSString stringWithFormat:@"%@",logModel.flag];
//        subtitleName = [NSString stringWithFormat:@"[%@] %@",logModel.level,[DateUtil prettyDateStringForDate:logModel.createTime]];
//    } else if (self.pageType == FromPageTypeTwo) {
//        titleName = [NSString stringWithFormat:@"[%@] %@",logModel.context,logModel.flag];
//        subtitleName = [NSString stringWithFormat:@"[%@] %@",logModel.level,[DateUtil prettyDateStringForDate:logModel.createTime]];
//    }
    cell.titleName = TransToString(titleName);
    cell.subTitleName = TransToString(subtitleName);
    
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
//    [[cell.contentView viewWithTag:1001] removeFromSuperview];
//    if (indexPath.row < !self.searching ? self.dataSource.count : self.searchDataSource.count - 1) {
//        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, 74.5, [UIScreen mainScreen].bounds.size.width - 20, 0.5)];
//        lineView.backgroundColor = [UIColor colorFromHexCode:@"e0e0e0"];
//        [cell.contentView addSubview:lineView];
//        lineView.tag = 1001;
//    }
    
    
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
                logModel = PASArrayAtIndex(!self.searching ? self.dataSource : self.searchDataSource, index-1);
                
//                [!self.searching ? self.dataSource : self.searchDataSource objectAtIndex:index - 1];
            } else {
//                logModel = [!self.searching ? self.dataSource : self.searchDataSource objectAtIndex:index + 1];
                logModel = PASArrayAtIndex(!self.searching ? self.dataSource : self.searchDataSource, index+1);

                
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
//        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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

- (MDLogSearchView *)searchView
{
    if (!_searchView) {
        _searchView = [[MDLogSearchView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, PASFactor(60))];

        @pas_weakify_self
        _searchView.searchNameBlock = ^(NSString * _Nonnull searchName) {
            @pas_strongify_self
            [self detailWithSearchNameBlock:searchName];
        };
        _searchView.searchStatusBlock = ^(SearchStatusType type) {
            @pas_strongify_self
            [self detailWithSearchStatusblock:type];
        };
    }
    return _searchView;
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
