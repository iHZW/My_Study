//
//  ZWSettingLogoutModule.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/29.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWSettingLogoutModule.h"
#import "ZWSettingContainerViewModel.h"
#import "ZWBaseTableViewCell.h"

@interface ZWSettingLogoutModule ()

@property (nonatomic, strong) ZWSettingContainerViewModel *viewModel;

@end

@implementation ZWSettingLogoutModule

- (id)initWithData:(NSDictionary *)data
{
    if (self = [super init]) {
        self.viewModel = [[ZWSettingContainerViewModel alloc] init];
    }
    return self;
}


#pragma mark - ZWTableViewAdapter
- (NSInteger)numberOfRows
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndex:(NSInteger)row
{
    CGFloat height = [self.viewModel heightView];;

    return height;
}

//返回需要展示的cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndex:(NSInteger)row
{
    ZWBaseTableViewCell *cell;
    switch (row) {
        case 0:
            cell = [self tableView:tableView reuseIdentifier:[self.viewModel reuseIdentifier]];
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            [cell addViewModel:self.viewModel];
            break;
        default:
            cell = [self tableView:tableView reuseIdentifier:emptyCellReuseIdentify];
            cell.contentView.backgroundColor = UIColorFromRGB(0xF2F2F2);
            break;
    }
    
    return cell;
}

- (ZWBaseTableViewCell *)tableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier
{
    ZWBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[ZWBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    return cell;
}



@end
