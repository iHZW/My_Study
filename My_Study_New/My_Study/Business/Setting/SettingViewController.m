//
//  SettingViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/30.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "SettingViewController.h"
#import "ZWBaseTableView.h"
#import "ZWHttpNetworkData.h"
#import "AlertHead.h"
#import "zhThemeOperator.h"
#import "PASIndicatorTableViewCell.h"
#import "ActionModel.h"
#import "CommonSelectedConfig.h"


#define kSectionViewHeight              20

@interface SettingViewController () <UITableViewDelegate, UITableViewDataSource>


@end

@implementation SettingViewController

- (void)initExtendedData
{
    [super initExtendedData];
    
    self.dataArray = [NSMutableArray arrayWithArray:[self getDataArray]];
    self.style = UITableViewStylePlain;
    self.tableCellClass = [PASIndicatorTableViewCell class];
    self.heightForHeader = kSectionViewHeight;
    self.cellHeight = 60;
    self.title = @"设置";

}

- (void)loadUIData
{
    [super loadUIData];
    
//    self.tableView.tableHeaderView = [self getHeaderView];
    self.tableView.tableFooterView = [UIView new];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(kMainNavHeight + kSysStatusBarHeight);
    }];

    @pas_weakify_self
    self.cellConfigBlock = ^(NSIndexPath * _Nonnull indexPath, PASIndicatorTableViewCell *cell) {
        @pas_strongify_self
        cell.isShowRightArrow = YES;

//        cell.borderOption = PASBorderOptionBottom | PASBorderOptionRight;
//        @weakify(cell)
//        [cell zh_themeUpdateCallback:^(id  _Nonnull target) {
//            @strongify(cell)
//            [cell setShortColor:ThemePickerColorKey(ZWColorKey_p9).color];
//            cell.backgroundColor = ThemePickerColorKey(ZWColorKey_p8).color;
//        }];

        NSArray *tempArray = PASArrayAtIndex(self.dataArray, indexPath.section);
        ActionModel *model = PASArrayAtIndex(tempArray, indexPath.row);
        cell.leftLabel.text = TransToString(model.title);
        cell.leftLabel.font = PASFont(18);
        cell.leftLabel.zh_textColorPicker = ThemePickerColorKey(ZWColorKey_p5);
    };
    
    self.cellClickBlock = ^(NSIndexPath * _Nonnull indexPath, id  _Nonnull cell) {
        @pas_strongify_self
        ActionModel *model = self.dataArray[indexPath.section][indexPath.row];
        NSString *selectAction = model.actionName;
        if (selectAction.length >0) {
            SEL seletor = NSSelectorFromString(selectAction);
            ((void (*)(id, SEL))objc_msgSend)(self,seletor);
        }
    };

}


- (NSArray *)getDataArray
{
    NSArray *sec1Arr = @[[ActionModel initWithTitle:@"个人信息" actionName:@"accountInfoSetting"],
                         [ActionModel initWithTitle:@"账户与安全" actionName:@"accountsAndSecurity"]];
   
    NSArray *sec2Arr = @[[ActionModel initWithTitle:@"Alert提示框" actionName:@"alertViewAction"],
                         [ActionModel initWithTitle:@"单选页面" actionName:@"selectedPageAction"],
                         [ActionModel initWithTitle:@"切换皮肤" actionName:@"changeTheme"],
                         [ActionModel initWithTitle:@"切换环境" actionName:@"changeEnv"]];
    
    NSArray *sec3Arr = @[[ActionModel initWithTitle:@"打开首页底部广告" actionName:@""]];
    
    NSArray *sec4Arr = @[[ActionModel initWithTitle:@"清除缓存" actionName:@"cleanCacheData"],
                         [ActionModel initWithTitle:@"意见反馈" actionName:@"feedBackDetailInfo"],
                         [ActionModel initWithTitle:@"关于" actionName:@"aboutDetailInfo"]];
    
    NSArray *sec5Arr = @[[ActionModel initWithTitle:@"用户隐私协议" actionName:@"go2PrivicyAgreement"],
                         [ActionModel initWithTitle:@"交易风险提示" actionName:@"go2TradeRiskTip"]];
    
    return @[sec1Arr,sec2Arr,sec3Arr,sec4Arr,sec5Arr];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kSectionViewHeight)];
    sectionHeader.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p1);
    return sectionHeader;
}



- (UIView *)getHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 80)];
    headerView.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p8);
    [headerView addSubview:self.tableViewHeader];
    self.tableViewHeader.leftLabel.text = @"设置相关信息";
    self.tableViewHeader.rightLabel2.text = @"🚓";
    [self.tableViewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(headerView);
    }];
    return headerView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}



#pragma mark - action
/**
 *  个人信息
 */
- (void)accountInfoSetting
{
    
}

/**
 *  账户与安全
 */
- (void)accountsAndSecurity
{
    
}

/**
 *  Alert提示框
 */
- (void)alertViewAction
{
    
    [ZWM.router executeURLNoCallBack: ZWRouterPageShowAlertViewController];
    
}

/**
 *  切换皮肤
 */
- (void)changeTheme
{
    NSArray *themeAray = @[AppThemeLight, AppThemeNight, AppThemeStyle1, AppThemeStyle2, AppThemeStyle3];
    [UIAlertUtil showAlertTitle:@"切换皮肤" message:@"" cancelButtonTitle:@"取消" otherButtonTitles:themeAray alertControllerStyle:UIAlertControllerStyleActionSheet actionBlock:^(NSInteger index) {
        if (index > 0) {
            NSString *themeKey = PASArrayAtIndex(themeAray, index - 1);
            [zhThemeOperator changeThemeStyleWithKey:themeKey];
        }
    } superVC:self];
}

/**
 *  切换环境
 */
- (void)changeEnv
{
    [ZWM.router executeURLNoCallBack:ZWRouterPageChangeEnvViewController];
}

/**
 *  清除缓存
 */
- (void)cleanCacheData
{
    
}

/**
 *  意见反馈
 */
- (void)feedBackDetailInfo
{
    
}

/**
 *  关于
 */
- (void)aboutDetailInfo
{
    
}

/**
 *  用户隐私协议
 */
- (void)go2PrivicyAgreement
{
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    mutDict[kIsLoadSureBtn] = @(YES);
    mutDict[kDataList] = @[@{kSelectName : @"111", @"type": @"1"},
                           @{kSelectName : @"222", @"type": @"2"},
                           @{kSelectName : @"333", @"type": @"3"},
                           @{kSelectName : @"444", @"type": @"4"}];
    mutDict[kSelectName] = @"111";
    
    RouterParam *param = [RouterParam makeWith:ZWRouterPageChangeEnvViewController destURL:@"SelectedViewController" params:mutDict.copy type:RouterTypeNavigate context:nil success:^(NSDictionary *result) {
        if ([result isKindOfClass:NSDictionary.class]){
            NSLog(@"result = %@", result);
        }
        
    } fail:^(NSError * error) {
        
    }];
    
    [ZWM.router executeRouterParam:param];
}

/**
 *  交易风险提示
 */
- (void)go2TradeRiskTip
{
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    mutDict[kIsLoadSureBtn] = @(NO);
    mutDict[kDataList] = @[@{kSelectName : @"111", @"type": @"1"},
                           @{kSelectName : @"222", @"type": @"2"},
                           @{kSelectName : @"333", @"type": @"3"},
                           @{kSelectName : @"444", @"type": @"4"}];
    mutDict[kSelectName] = @"222";
    mutDict[kTitleName] = @"交易风险提示选择页";
    
    RouterParam *param = [RouterParam makeWith:ZWRouterPageChangeEnvViewController destURL:@"SelectedViewController" params:mutDict.copy type:RouterTypeNavigate context:nil success:^(NSDictionary *result) {
        if ([result isKindOfClass:NSDictionary.class]){
            NSLog(@"result = %@", result);
        }
        
    } fail:^(NSError * error) {
        
    }];
    
    [ZWM.router executeRouterParam:param];
}

/**
 *  单选界面
 */
- (void)selectedPageAction
{
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    mutDict[kIsLoadSureBtn] = @(NO);
    mutDict[kDataList] = @[@{kSelectName : @"111", @"type": @"1"},
                           @{kSelectName : @"222", @"type": @"2"},
                           @{kSelectName : @"333", @"type": @"3"},
                           @{kSelectName : @"444", @"type": @"4"}];
    mutDict[kSelectName] = @"444";
    
    RouterParam *param = [RouterParam makeWith:ZWRouterPageChangeEnvViewController destURL:@"SelectedViewController" params:mutDict.copy type:RouterTypeNavigate context:nil success:^(NSDictionary *result) {
        if ([result isKindOfClass:NSDictionary.class]){
            NSLog(@"result = %@", result);
        }
        
    } fail:^(NSError * error) {
        
    }];
    
    [ZWM.router executeRouterParam:param];
}


@end
