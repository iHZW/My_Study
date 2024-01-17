//
//  RACBindingTableVc.m
//  My_Study
//
//  Created by hzw on 2024/1/17.
//  Copyright © 2024 HZW. All rights reserved.
//

#import "RACBindingTableVc.h"
#import "ZWBindingViewModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "NSNumber+Tool.h"

@interface RACBindingTableVc ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) ZWBindingViewModel *viewModel;

@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation RACBindingTableVc

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;

    self.viewModel = [[ZWBindingViewModel alloc] init];
    [self.viewModel fetchData];

    CGRect rect = CGRectMake(0, [NSNumber eh_safeTopToNavBar] + 50, kMainScreenWidth, kMainScreenHeight - ([NSNumber eh_safeTopToNavBar] + 50));
    // 创建UITableView
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];

    // 创建UITextField
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(15, [NSNumber eh_safeTopToNavBar] + 5, kMainScreenWidth-15*2, 40)];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.textField];
    
    [self _handleDataBinding];
}


//#pragma mark - UITableViewDataSource Methods
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.viewModel.data.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
//    
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
//    }
//    
//    // 配置单元格
//    ZWBindingItem *item = self.viewModel.data[indexPath.row];
//    cell.textLabel.text = item.itemName;
//    
//    return cell;
//}


- (void)_handleDataBinding {
    // 使用RAC实现双向绑定
    RAC(self, data) = [[self.textField.rac_textSignal
                         map:^id(NSString *text) {
                             // 在这里可以对输入进行处理
                             return [self processInput:text];
                         }]
                        distinctUntilChanged];

    RAC(self.textField, text) = [RACObserve(self, data) map:^id(NSArray *array) {
        // 在这里可以对数据进行处理
        return [self processArray:array];
    }];
    
    __weak __typeof(self)weakSelf = self;
    [RACObserve(self, data) subscribeNext:^(id x) {
        __strong __typeof(weakSelf)self = weakSelf;
        [self.tableView reloadData];
    }];
}


- (NSArray *)processInput:(NSString *)text {
    // 在这里可以对输入进行处理
    NSLog(@"Input: %@", text);
    NSArray *dataArray = [text componentsSeparatedByString:@","];
    if ([text isEqualToString:@""]) {
        return self.data;
    }
    return dataArray;
}

- (NSString *)processArray:(NSArray *)array {
    // 在这里可以对数据进行处理
    NSLog(@"Data: %@", array);
    return [array componentsJoinedByString:@","];
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }

    cell.textLabel.text = self.data[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *tempArray = [NSMutableArray array];
    [self.data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx != indexPath.row) {
            [tempArray addObject:obj];
        }
    }];
    self.data = [tempArray copy];
    [self.tableView reloadData];
}


@end
