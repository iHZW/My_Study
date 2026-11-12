//
//  ZWChangeEnvViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/5.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWChangeEnvViewController.h"
#import "PASIndicatorTableViewCell.h"
#import "Environment.h"
#import "AlertView.h"
#import "Config.h"
#import "ZWEndpointConfiguration.h"

#define kEnvName  @"name"
#define kEnvType  @"type"

@interface ZWChangeEnvViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) EnvironmentType selectedType;


@end

@implementation ZWChangeEnvViewController

- (void)initExtendedData
{
    [super initExtendedData];
    self.title = @"切换环境";
    self.dataArray = [NSMutableArray arrayWithArray:[self getArray]];
    self.style = UITableViewStylePlain;
    self.tableCellClass = PASIndicatorTableViewCell.class;
    self.cellHeight = 60;
    self.selectedType = Environment.sharedEnvironment.currentEnvironmentType;
}

- (void)loadUIData
{
    [super loadUIData];
    
    @pas_weakify_self
    self.cellConfigBlock = ^(NSIndexPath * _Nonnull indexPath, PASIndicatorTableViewCell * _Nonnull cell) {
        @pas_strongify_self
        cell.isShowRightArrow = NO;
        cell.currentIndexPath = indexPath;
        [cell.button setImage:[UIImage imageNamed:@"icon_unselected"] forState:UIControlStateNormal];
        [cell.button setImage:[UIImage imageNamed:@"icon_selected"] forState:UIControlStateSelected];
        
        cell.buttonActionBlock = ^(NSIndexPath *indexPath) {
            @pas_strongify_self
            [self changeEnvAction:indexPath];
        };
        
        [cell.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(cell.contentView);
            make.right.equalTo(cell.contentView.mas_right).offset(- kContentSideHorizSpace);
            make.width.mas_equalTo(60);
        }];
        
        NSDictionary *dict = PASArrayAtIndex(self.dataArray, indexPath.row);
        NSString *name = [DataFormatterFunc strValueForKey:kEnvName ofDict:dict];
        NSString *address = NSBundle.mainBundle.infoDictionary[@"NetworkConfiguration"][@"BaseURLs"][name];
        cell.leftLabel.text = [NSString stringWithFormat:@"%@%@", name, address.length ? @"" : @"（未配置 API 地址）"];
        cell.leftLabel.font = PASFont(18);
        cell.leftLabel.zh_textColorPicker = ThemePickerColorKey(ZWColorKey_p5);
        
        NSInteger type = [[DataFormatterFunc strValueForKey:kEnvType ofDict:dict] integerValue];
        cell.button.selected = self.selectedType == type ? YES : NO;
    };
    
    self.cellClickBlock = ^(NSIndexPath * _Nonnull indexPath, PASIndicatorTableViewCell * _Nonnull cell) {
        @pas_strongify_self
        [self changeEnvAction:indexPath];
    };

}

- (void)initRightNav
{
    [super initRightNav];
    
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn setTitleColor:UIColorFromRGB(0x6495ED) forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureAction:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *allBarButton = [[UIBarButtonItem alloc] initWithCustomView:sureBtn];

    self.navigationItem.rightBarButtonItems = @[allBarButton];
}

/**
 *  确定按钮点击
 */
- (void)sureAction:(id)sender {
    NSError *error = nil;
    if (![Environment.sharedEnvironment updateEnvironment:self.selectedType error:&error]) {
        [Toast show:error.localizedDescription];
        return;
    }
    AlertView *alertView = [AlertView new];
    alertView.title = @"环境已保存";
    alertView.message = @"下次启动应用时生效。当前会话继续使用原环境，请自行关闭并重新打开应用。";
    alertView.actions = @[[AlertAction defaultConfirmAction:@"知道了" clickCallback:^{}]];
    [alertView show];
}

- (void)changeEnvAction:(NSIndexPath *)indexPath
{
    NSDictionary *dict = PASArrayAtIndex(self.dataArray, indexPath.row);
    NSInteger type = [[DataFormatterFunc strValueForKey:kEnvType ofDict:dict] integerValue];
    self.selectedType = type;
    [self.tableView reloadData];
}


- (NSArray *)getArray
{
    return @[@{kEnvName: @"dev",
               kEnvType: @(EnvironmentTypeDev)
             },
             @{kEnvName: @"qa",
               kEnvType: @(EnvironmentTypeQA)
             },
             @{kEnvName: @"pl",
               kEnvType: @(EnvironmentTypePL)
             },
             @{kEnvName: @"online", kEnvType: @(EnvironmentTypeOnline)}];
}

@end
