//
//  MDDebugViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/15.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "MDDebugViewController.h"
#import "MDLogTableViewCell.h"
#import "MDLogViewController.h"
#import "ZWBaseTableView.h"
#import "TestWebViewController.h"

#define kLogTabViewCellIdentifier   @"kLogTabViewCellIdentifier"

#pragma mark - SectionData 数据
@interface SectionData: NSObject
    @property (nonatomic, copy) NSString *title;
    @property (nonatomic, strong) NSArray *items;
@end

@implementation SectionData
+ (instancetype)sectionData:(NSString *)title items:(NSArray *)items{
    SectionData *object = [[SectionData alloc] init];
    object.title = title;
    object.items = items;
    return object;
}
@end


@interface MDDebugViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) ZWBaseTableView *tableView;

@property (nonatomic, strong) NSArray<SectionData *> *dataSource;

@end

@implementation MDDebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    self.title = @"开发";
    
    [self initLeftNav];
    [self initData];
    
    [self loadSubViews];
}

/* 初始化数据 */
- (void)initData
{
    self.dataSource = @[[SectionData sectionData:@"日志" items:@[@"日志列表"]],
                        [SectionData sectionData:@"开发" items:@[@"测试页面",@"网页测试 (销售推)",@"网页测试 (ip)",@"切换环境"]]];
}



/* 加载子视图 */
- (void)loadSubViews
{
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
}



#pragma mark -  tableView delegate/dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SectionData *sectionData = PASArrayAtIndex(self.dataSource, section);
    return  sectionData && sectionData.items ? sectionData.items.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    SectionData *sectionData = PASArrayAtIndex(self.dataSource, section);
    return TransToString(sectionData.title);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MDLogTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLogTabViewCellIdentifier];
    
    SectionData *sectionData = PASArrayAtIndex(self.dataSource, indexPath.section);
    NSString *titleName = PASArrayAtIndex(sectionData.items, indexPath.row);
    cell.titleName = TransToString(titleName);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0){
                MDLogViewController *vc = [[MDLogViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
        }
        case 1:{
            if (indexPath.row == 0){
//                TestViewController *vc = [[TestViewController alloc] init];
//                [self.navigationController pushViewController:vc animated:YES];
            } else if (indexPath.row == 1){
                TestWebViewController *vc = [[TestWebViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            } else if (indexPath.row == 2){
//                TestWebIpViewController *vc = [[TestWebIpViewController alloc] init];
//                [self.navigationController pushViewController:vc animated:YES];
            } else if (indexPath.row == 3){
                [ZWM.router executeURLNoCallBack:ZWRouterPageChangeEnvViewController];
            }
            break;
        }
        default:
            break;
    }
}


#pragma mark - lazyLoad
- (ZWBaseTableView *)tableView
{
    if (!_tableView) {
        _tableView = [[ZWBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[MDLogTableViewCell class] forCellReuseIdentifier:kLogTabViewCellIdentifier];
    }
    return _tableView;
}

@end
