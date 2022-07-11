//
//  FileSelectViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "FileSelectViewController.h"
#import "FileItemCell.h"
#import "FileSelectManager.h"

#define kCellHeight             70

@interface FileSelectViewController ()

@property (nonatomic, strong) UIButton *addBtn;

@end

@implementation FileSelectViewController

-(void)initExtendedData
{
    [super initExtendedData];
    self.title = @"文件选择界面";
    self.dataArray = [NSMutableArray array];
    self.tableCellClass = [FileItemCell class];
    self.cellHeight = kCellHeight;
    self.sectionCount = 1;
}

- (void)loadUIData
{
    [super loadUIData];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kCellHeight)];
    footerView.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p1);
    [footerView addSubview:self.addBtn];
    self.tableView.tableFooterView = footerView;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    @pas_weakify_self
    self.cellConfigBlock = ^(NSIndexPath * _Nonnull indexPath, FileItemCell * _Nonnull cell) {
        @pas_strongify_self
        PHAssetModel *model = PASArrayAtIndex(self.dataArray, indexPath.row);
        cell.contentView.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p1);
        cell.index = indexPath.row;
        if (model) {
            [cell configItemModel:model];
        }
        
        cell.closeActoinBlock = ^(NSInteger index) {
            @pas_strongify_self
            if (index < self.dataArray.count) {
                [self.dataArray removeObjectAtIndex:index];
                [self.tableView reloadData];
            }
        };
    };
    
    self.cellClickBlock = ^(NSIndexPath * _Nonnull indexPath, FileItemCell * _Nonnull cell) {
        @pas_strongify_self

    };
}


- (void)addAction
{
    [[FileSelectManager sharedFileSelectManager] openFileSelectVc];
    @pas_weakify_self
    [FileSelectManager sharedFileSelectManager].selectFileComplete = ^(NSArray<PHAssetModel *> * _Nonnull modelArr)
    {
        @pas_strongify_self
        if (ValidArray(modelArr)) {
            [self.dataArray addObjectsFromArray:modelArr];
            [self.tableView reloadData];
        }
    };
}




#pragma mark - lazyLoad
- (UIButton *)addBtn
{
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addBtn.zh_backgroundColorPicker =  ThemePickerColorKey(ZWColorKey_p8);
        _addBtn.frame = CGRectMake(10, 5, kMainScreenWidth - 20, kCellHeight - 10);
        _addBtn.cornerRadius = 8;
        [_addBtn setImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
        [_addBtn addTarget:self action:@selector(addAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addBtn;
}


@end
