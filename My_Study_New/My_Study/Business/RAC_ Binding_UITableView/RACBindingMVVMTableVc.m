//
//  RACBindingMVVMTableVc.m
//  My_Study
//
//  Created by hzw on 2024/1/17.
//  Copyright © 2024 HZW. All rights reserved.
//

#import "RACBindingMVVMTableVc.h"
#import "ZWBindingViewModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "NSNumber+Tool.h"

static NSString *const kBindingMVVMCellId = @"kBindingMVVMCellId";

@interface RACBindingMVVMTableVc ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) ZWBindingViewModel *viewModel;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation RACBindingMVVMTableVc

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;

    [self _setUI];
    
    [self loadBinding];
    
}


- (void)_setUI {
    [self.view addSubview:self.tableView];
    
}


- (void)loadBinding {
    __weak __typeof(self)weakSelf = self;
    [RACObserve(self.viewModel, data) subscribeNext:^(id x) {
        __strong __typeof(weakSelf)self = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBindingMVVMCellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kBindingMVVMCellId];
    }
    // 配置单元格
    ZWBindingItem *item = self.viewModel.data[indexPath.row];
    cell.textLabel.text = item.itemName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.viewModel _handleCellAction:indexPath];
}


#pragma mark -  Lazy loading
- (ZWBindingViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZWBindingViewModel alloc] init];
        [_viewModel fetchData];
    }
    return _viewModel;
}

- (UITableView *)tableView {
    if (!_tableView) {
        CGRect rect = CGRectMake(0, [NSNumber eh_safeTopToNavBar], kMainScreenWidth, kMainScreenHeight - [NSNumber eh_safeTopToNavBar]);
        _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end
