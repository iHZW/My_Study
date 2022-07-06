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
#import "PathConstants.h"

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
        cell.leftLabel.text = [DataFormatterFunc strValueForKey:kEnvName ofDict:dict];
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
- (void)sureAction:(id)sender
{
    EnvironmentType type = self.selectedType;
    
//    NSString *toSubEnvLabel = self.subEnvTextField.text;
//
//    BOOL isSubEnvOn = self.subEnvCheckButton.isSelected;
//
//    BOOL isImOfflineOn = self.imofflineButton.isSelected;
    
//    SubEnvInfo *subEnv = [SubEnvInfo init:toSubEnvLabel on:isSubEnvOn];
//    [Environment.sharedInstance saveSubEnv:subEnv];
    
    /** 保存当前环境  */
    [Environment.sharedEnvironment updateEnvironment:type];
    
    BOOL isImOfflineOn = YES;
    [Environment.sharedEnvironment saveIMForceOffline:isImOfflineOn];
    
//    if (Session.userSession.token.length > 0){
//        //已登录
//        [UserManager.sharedInstance logout];
//    } else {
        [self clearAfterChangeEnvDone];
//    }
}


- (void)clearAfterChangeEnvDone
{
    [self deleteCache];
    
    AlertView *alertView = [[AlertView alloc] init];
    alertView.title = @"提示";
    alertView.message = @"切换环境需要手动重启App，如遇黑屏或白屏请忽略！";
    alertView.disableBgTap = YES;
    alertView.actions = @[
       [AlertAction defaultConfirmAction:@"我知道了" clickCallback:^{
           exit(0);
       }]
    ];
    [alertView show];
}

/** 清除缓存  */
- (void)deleteCache
{
    NSString *dataPath = [PathConstants appDataDirectory];
    NSError *error = nil;
    [NSFileManager.defaultManager removeItemAtPath:dataPath error:&error];
    NSLog(@"12");
}


/**
 *  切换环境点击
 */
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
             }];
}

@end
