//
//  SelectedViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/5.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "SelectedViewController.h"
#import "PASIndicatorTableViewCell.h"
#import "CommonSelectedConfig.h"
#import "GCDCommon.h"

@interface SelectedViewController ()

@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation SelectedViewController


- (void)initExtendedData
{
    [super initExtendedData];
    
    self.tableCellClass = PASIndicatorTableViewCell.class;
    self.dataArray = [NSMutableArray array];
    self.selectedIndex = -1;
    self.cellHeight = 60;
    self.title = @"选择页";
}

- (void)loadUIData
{
    [super loadUIData];
    
    if (ValidString(self.titleName)) {
        self.title = TransToString(self.titleName);
    }
    
    if (self.isLoadSureBtn) {
        [self loadSureBtn];
    }
    
    if (ValidArray(self.dataList)) {
        self.dataArray = [NSMutableArray arrayWithArray:TransToArray(self.dataList)];
    }
    
    /** 处理选中  */
    if (ValidString(self.selectedName) && ValidArray(self.dataArray)) {
        [self.dataArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSString *name = [DataFormatterFunc strValueForKey:kSelectName ofDict:obj];
                if ([name isEqualToString:self.selectedName]) {
                    self.selectedIndex = idx;
                    *stop = YES;
                }
            } else{
                *stop = YES;
            }
        }];
    }
    
    
    @pas_weakify_self
    self.cellConfigBlock = ^(NSIndexPath * _Nonnull indexPath, PASIndicatorTableViewCell * _Nonnull cell) {
        @pas_strongify_self
        cell.isShowRightArrow = NO;
        cell.currentIndexPath = indexPath;
        [cell.button setImage:[UIImage imageNamed:@"icon_unselected"] forState:UIControlStateNormal];
        [cell.button setImage:[UIImage imageNamed:@"icon_selected"] forState:UIControlStateSelected];
                
        cell.buttonActionBlock = ^(NSIndexPath *indexPath) {
            @pas_strongify_self
            [self changeSelectedAction:indexPath];
        };
        
        [cell.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(cell.contentView);
            make.right.equalTo(cell.contentView.mas_right).offset(- kContentSideHorizSpace);
            make.width.mas_equalTo(60);
        }];
        cell.button.selected = self.selectedIndex == indexPath.row ? YES : NO;
        
        NSDictionary *dict = PASArrayAtIndex(self.dataArray, indexPath.row);
        if ([dict isKindOfClass:[NSDictionary class]]) {
            cell.leftLabel.text = [DataFormatterFunc strValueForKey:kSelectName ofDict:dict];
            cell.leftLabel.font = PASFont(18);
            cell.leftLabel.zh_textColorPicker = ThemePickerColorKey(ZWColorKey_p5);
        }
    };
    
    self.cellClickBlock = ^(NSIndexPath * _Nonnull indexPath, PASIndicatorTableViewCell * _Nonnull cell) {
        @pas_strongify_self
        [self changeSelectedAction:indexPath];
    };
}

#pragma mark - setter
- (void)setDataList:(NSArray<NSDictionary *> *)dataList
{
    _dataList = dataList;
}

- (void)setSelectedName:(NSString *)selectedName
{
    _selectedName = selectedName;
}

- (void)setIsLoadSureBtn:(BOOL)isLoadSureBtn
{
    _isLoadSureBtn = isLoadSureBtn;
}

#pragma mark - dealWith action

- (void)loadSureBtn
{
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
    if (self.selectedIndex != NSNotFound) {
        NSDictionary *dict = PASArrayAtIndex(self.dataArray, self.selectedIndex);
        [self executeBlock:dict];
    }
    performBlockDelay(dispatch_get_main_queue(), .1, ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

/** 执行回调,  点击 / 确定按钮    */
- (void)executeBlock:(NSDictionary *)dict
{
    /** 当前类选中回调  */
    BlockSafeRun(self.selectedActionBlock, dict);
    /** 这个是通过路由挑转, 路由里的successblock  回调  */
    BlockSafeRun(self.routerParamObject.successBlock, dict);
}

/**
 *  改变选中selected
 *
 *  @param indexPath    选中的iindexPath
 */
- (void)changeSelectedAction:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.row;
    [self.tableView reloadData];
    
    if (!self.isLoadSureBtn) {
        if (self.selectedIndex != NSNotFound) {
            NSDictionary *dict = PASArrayAtIndex(self.dataArray, self.selectedIndex);
            [self executeBlock:dict];
        }
        performBlockDelay(dispatch_get_main_queue(), .1, ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}




/* 处理路由传参 */
- (void)decodeRouterParams:(NSDictionary *)routerParams
{
    [super decodeRouterParams:routerParams];
    
    if (routerParams) {
        self.selectedName = [DataFormatterFunc strValueForKey:kSelectName ofDict:routerParams];
        self.dataList = [DataFormatterFunc arrayValueForKey:kDataList ofDict:routerParams];
        self.isLoadSureBtn = [[DataFormatterFunc numberValueForKey:kIsLoadSureBtn ofDict:routerParams] boolValue];
        self.titleName = [DataFormatterFunc strValueForKey:kTitleName ofDict:routerParams];
    }
}

#pragma mark - 获取路由中的参数
//- (NSString *)getRouterUrl{
//    return __String_Not_Nil([self.routerParams objectForKey:@"url"]);
//}



@end
