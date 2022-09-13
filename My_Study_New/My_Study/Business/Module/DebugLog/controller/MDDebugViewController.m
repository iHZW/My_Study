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
#import "TABAnimated.h"
#import "FileItemView.h"
#import "LineTableViewHeaderFooterView.h"
#import "CardTableViewCell.h"
#import "TestCardTableViewCell.h"

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
    
//    self.tableView.tabAnimated = [TABTableAnimated animatedWithCellClass:[TrimAddressCell class] cellHeight:100];
}

/* 初始化数据 */
- (void)initData
{
//    self.dataSource = @[[SectionData sectionData:@"日志" items:@[@"日志列表"]],
//                        [SectionData sectionData:@"开发" items:@[@"测试页面",@"网页测试 (销售推)",@"网页测试 (ip)",@"切换环境"]]];
    self.dataSource = @[
                        [SectionData sectionData:@"开发" items:@[@"测试页面",@"网页测试 (销售推)",@"网页测试 (ip)",@"切换环境"]]];
}



/* 加载子视图 */
- (void)loadSubViews
{
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
    
    // 设置tabAnimated相关属性
    // 部分section有动画
    self.tableView.tabAnimated =
//    [TABTableAnimated animatedWithCellClassArray:@[[MDLogTableViewCell class], [CardTableViewCell class]]
//                                 cellHeightArray:@[@(60.0), @([CardTableViewCell cellHeight])]
//                              animatedCountArray:@[@1, @4]];
    [TABTableAnimated animatedInRowModeWithCellClassArray:@[[MDLogTableViewCell class],
                                                            [TestCardTableViewCell class],
                                                            [CardTableViewCell class],
                                                            [TestCardTableViewCell class],
                                                            [CardTableViewCell class],
                                                            [CardTableViewCell class],
                                                            [CardTableViewCell class]]
                                          cellHeightArray:@[@(60.0),
                                                            @([TestCardTableViewCell cellHeight]),
                                                            @([CardTableViewCell cellHeight]),
                                                            @(80.0),
                                                            @([CardTableViewCell cellHeight]),
                                                            @([CardTableViewCell cellHeight]),
                                                            @([CardTableViewCell cellHeight])]
                                                 rowArray:@[@(0),
                                                            @1,
                                                            @2,
                                                            @3,
                                                            @4,
                                                            @5,
                                                            @6]];
    self.tableView.tabAnimated.animatedCount = 10;
//    [self.tableView.tabAnimated addHeaderViewClass:[LineTableViewHeaderFooterView class] viewHeight:60 toSection:0];
//    [self.tableView.tabAnimated addHeaderViewClass:[LineTableViewHeaderFooterView class] viewHeight:60 toSection:1];

    self.tableView.tabAnimated.adjustWithClassBlock = ^(TABComponentManager *manager, __unsafe_unretained Class targetClass) {
        if (targetClass == MDLogTableViewCell.class) {
//            manager.animation(0).remove();
//            manager.animation(1).up(25).height(40).width(100).reducedWidth(-30).toShortAnimation();
//            manager.animation(2).right(-15).height(40).width(40);
        }
    };
    
//    FileItemView *itemView = [[FileItemView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 80)];
    UIView *headView = [UIView viewWithFrame:CGRectMake(0, 0, kMainScreenWidth, 80)];
    UILabel *titleLabelOne = [UILabel labelWithFrame:CGRectMake(kContentSideHorizSpace, 20, 100, 40) text:@"你好李焕英" textColor:UIColor.redColor];
    [headView addSubview:titleLabelOne];
    
    UIView *rightView = [UIView viewForColor:UIColor.greenColor withFrame:CGRectMake(kMainScreenWidth - 80, 10, 60, 60)];
    [headView addSubview:rightView];
    
//    self.tableView.tableHeaderView = headView;
    
    

    
//    headView.tabAnimated = [TABViewAnimated new];
//    headView.tabAnimated.animatedColor = UIColor.redColor;
//    headView.tabAnimated.animatedBackgroundColor = UIColor.greenColor;
//    headView.tabAnimated.adjustBlock = ^(TABComponentManager * _Nonnull manager) {
////        manager.animation(0).left(100).reducedWidth(30).toLongAnimation();
//        manager.animation(0).remove();
//        manager.animation(1).radius(10);
//        manager.create(3).left(-kContentSideHorizSpace).down(20).width(200).height(40).radius(10).reducedWidth(-30).toShortAnimation();
//    };
//    
//    [headView tab_startAnimationWithCompletion:^{
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [headView tab_endAnimationEaseOut];
//        });
//    }];
    [self.tableView tab_startAnimation];

}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
        
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView tab_endAnimationEaseOut];
    });
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *str = @"LineTableViewHeaderFooterView";
    LineTableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:str];

    if (!headerView) {
        headerView = [[LineTableViewHeaderFooterView alloc] initWithReuseIdentifier:str];
    }
    return headerView;
    
//    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 30)];
//    [headView addSubview:[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)]];
//    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60.0;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    SectionData *sectionData = PASArrayAtIndex(self.dataSource, section);
//    return TransToString(sectionData.title);
//}

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
