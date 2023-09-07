//
//  TestKLineViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2023/9/7.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "AskKlineTableViewCell.h"
#import "NSNumber+Tool.h"
#import "TestKLineViewController.h"

static NSString *const askCellIdentifier = @"askCellIdentifier";

@interface TestKLineViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UITableView *askTableView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation TestKLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;

    [self _setUI];
    [self _setData];
}

- (void)_setUI {
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"KLinePage";

    [self.view addSubview:self.askTableView];
}

- (void)_setData {
    
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [self.askTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(NSNumber.eh_safeTop);
    }];
}

#pragma mark - UITableViewDelegate/UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AskKlineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:askCellIdentifier];

    return cell;
}

#pragma mark -  Lazy loading
- (UITableView *)askTableView {
    if (!_askTableView) {
        _askTableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _askTableView.delegate = self;
        _askTableView.dataSource = self;
        [_askTableView registerClass:[AskKlineTableViewCell class] forCellReuseIdentifier:askCellIdentifier];
    }
    return _askTableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


@end
