//
//  ZWMemberManageModule.m
//  My_Study
//

#import "ZWMemberManageModule.h"
#import "RouterPageConfig.h"
#import "PersonalHeader.h"
#import "ModuleContainer.h"

@implementation ZWMemberManageModule

- (id)initWithData:(NSDictionary *)data
{
    if (self = [super init]) {
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
    return 84;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndex:(NSInteger)row
{
    static NSString *const identifier = @"ZWMemberManageEntryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"会员管理";
        cell.textLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
        cell.textLabel.textColor = UIColorFromRGB(0x294B46);
        cell.detailTextLabel.text = @"会员档案 / 消费记录 / 积分储值（本地会员系统）";
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.textColor = UIColorFromRGB(0x8B9894);
        cell.detailTextLabel.numberOfLines = 2;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSInteger)row
{
    [ZWM.router executeURLNoCallBack:ZWRouterPageMemberListViewController];
}

@end
