//
//  ZWAlbumPopView.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/12.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWAlbumPopView.h"
#import "ZWAlbumCell.h"
#import "UIColor+Ext.h"

#define kCellIdentifier   @"kPopViewCellIdentifier"

@interface ZWAlbumPopView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) UITableView * tableView;

@property (nonatomic ,strong) UIView * backgroundVc;

@property (nonatomic ,strong) NSArray <PHAssetCollection *> * dataList;

@property (nonatomic ,assign) NSInteger selectIndex;

@end

@implementation ZWAlbumPopView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame])
    {
        self.selectIndex = 0;
        [self initViews];
        [self configDataList];
    }
    return self;
}

- (void)initViews{
    [self addSubview:self.backgroundVc];
    [self addSubview:self.tableView];
}

- (void)configDataList{
    @pas_weakify_self
    [[ZWAlbumManager manager] systemAlbumList:^(NSArray<PHAssetCollection *> * _Nonnull list) {
        @pas_strongify_self
        self.dataList = list;
        [self.tableView reloadData];
    }];
}

- (CGFloat)getPopViewHeight{
    CGFloat maxHeight = kMainScreenHeight - kSysStatusBarHeight;
    CGFloat height = self.dataList.count * 56 + 16;
    return height > maxHeight ? maxHeight : height;
}

- (void)showAnimation{
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundVc.alpha = 0.4f;
        self.tableView.frame = CGRectMake(0, 0, self.frame.size.width, [self getPopViewHeight]);
    }];
}

- (void)dismissAnimation{
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundVc.alpha = 0;
        self.tableView.frame = CGRectMake(0, -[self getPopViewHeight], self.frame.size.width, [self getPopViewHeight]);
    } completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(popViewDidDismiss)]) {
            [self.delegate popViewDidDismiss];
        }
        [self removeFromSuperview];
    }];
}

- (void)clickBackground{
    [self dismissAnimation];
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectIndex = indexPath.row;
    PHAssetCollection * collection = [self.dataList objectAtIndex:indexPath.row];
    if (_delegate && [_delegate respondsToSelector:@selector(popViewSelect:)]) {
        [_delegate popViewSelect:collection];
        [self.tableView reloadData];
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZWAlbumCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    PHAssetCollection * collection = [self.dataList objectAtIndex:indexPath.row];
    if (collection) {
        [cell update:collection];
    }
    
    if (indexPath.row == self.selectIndex) {
        [cell selectStatus];
    }else{
        [cell unSelectStatus];
    }
    
    return cell;
}

#pragma mark lazyLoad

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, -[self getPopViewHeight], self.frame.size.width, [self getPopViewHeight]) style:UITableViewStyleGrouped];
        _tableView.contentInset = UIEdgeInsetsMake(8, 0, 8, 0);
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[ZWAlbumCell class] forCellReuseIdentifier:kCellIdentifier];
    }
    return _tableView;
}

- (UIView *)backgroundVc{
    if (!_backgroundVc) {
        _backgroundVc = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _backgroundVc.userInteractionEnabled = YES;
        _backgroundVc.alpha = 0.4;
        _backgroundVc.backgroundColor = [UIColor colorFromHexCode:@"#000000"];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]init];
        [tap addTarget:self action:@selector(clickBackground)];
        [_backgroundVc addGestureRecognizer:tap];
    }
    return _backgroundVc;
}


@end
