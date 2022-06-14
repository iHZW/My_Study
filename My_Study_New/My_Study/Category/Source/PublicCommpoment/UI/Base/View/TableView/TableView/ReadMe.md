PASTwoListView *listView = [[PASTwoListView alloc] initWithFrame:CGRectMake(0, 40,CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-50)];
[self.view addSubview:listView];
NSArray *rightTopArr = @[@{@"title":@"量1"},@{@"title":@"量2"},@{@"title":@"量3"},@{@"title":@"量4"},@{@"title":@"量5"},@{@"title":@"量6"},@{@"title":@"量7"},@{@"title":@"量8"},@{@"title":@"量9"},@{@"title":@"量10",@"enable":@"0"},@{@"title":@"量11"},@{@"title":@"量12"}];

[listView setLeftTopTitle:@"股票代码" rightTopTitles:rightTopArr rightTopTitleWidths:nil topTitleWidth:0 topTitleImage:@{@"up":@"",@"down":@""}];

__weak typeof(&*listView) wListView = listView;
//刷新请求
[listView loadFreshView:^{
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
[wListView endHeaderRefreshing];
});

}];

//加载更多请求
[listView loadMoreView:^{
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
[wListView endFooterRefreshingWithHidden:NO];
});

}];

listView.clickTitleBlock = ^(NSInteger index,BOOL isDown){

};

NSMutableArray *leftData = [NSMutableArray array];
NSMutableArray *rightData = [NSMutableArray array];
for (NSInteger i = 0; i < 5; i++) {

[leftData addObject:@{@"title":@"杭萧钢构",@"code":[NSString stringWithFormat:@"60000%ld",i]}];

NSMutableArray *tempArr = [NSMutableArray array];
for (NSInteger j = 0 ; j< rightTopArr.count; j++) {
PASListRightItem *item = [[PASListRightItem alloc] init];
item.contentStr = [NSString stringWithFormat:@"内容%ld",j+1];
item.contentColor = [UIColor colorWithWhite:(j%10)/10.0+0.2 alpha:1];\
[tempArr addObject:item];
}
[rightData addObject:tempArr];
}
[listView appendLeftTableData:leftData rightTableData:rightData];