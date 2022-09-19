//
//  ZWAlbumPreViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/12.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWAlbumPreViewController.h"
#import "ZWNavCountButton.h"
#import "ZWToolBar.h"
#import "ZWPreTabView.h"
#import "ZWImageUtil.h"
#import "ZWAlbumManager.h"
#import "ZWPreCell.h"
#import "ZWCardLayout.h"

#define kCellIdentify @"zhenglimingdashabi"

@interface ZWAlbumPreViewController ()
<UICollectionViewDelegate,
UICollectionViewDataSource,
ZWToolBarDelegate,
ZWPreTabViewDelegate>

@property (nonatomic ,strong) UICollectionView * collectionview;

@property (nonatomic ,strong) ZWToolBar * toolBar;

@property (nonatomic ,strong) ZWNavCountButton * navButton;

@property (nonatomic ,strong) ZWPreTabView * preTabView;

@end

@implementation ZWAlbumPreViewController

- (void)loadUIData
{
    [super loadUIData];
    
    if (@available(iOS 11.0, *)) {
        self.collectionview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
//    self.navigationController.navigationBar.translucent = YES;
    [self initViews];
    
//    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.index inSection:0];
//    [self.collectionview scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
//    [self.collectionview reloadData];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.index inSection:0];
    [self.collectionview scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    [self.collectionview reloadData];
}

- (void)initRightNav
{
    _navButton = [[ZWNavCountButton alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];

    [_navButton addTarget:self action:@selector(rightBtnAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * chooseItem = [[UIBarButtonItem alloc]initWithCustomView:_navButton];
    self.navigationItem.rightBarButtonItem = chooseItem;
}

/** 重写返回按钮事件  */
- (void)goBack
{
    if (_delegate && [_delegate respondsToSelector:@selector(isOriginalDidChange:)]) {
        [_delegate isOriginalDidChange:self.toolBar.isOriginal];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updatePageStatus{
    PHAssetModel * model = [self.imageList objectAtIndex:self.index];
    if ([[ZWAlbumManager manager] checkIsVideo:model.asset]) {
        self.navigationItem.rightBarButtonItem.customView.hidden = YES;
    }else{
        self.navigationItem.rightBarButtonItem.customView.hidden = NO;
    }
    if (model.selStatus == 1) {
        NSInteger selIndex;
        if ([self.selectArr containsObject:model]) {
            selIndex = [self.selectArr indexOfObject:model] + 1;
        }else{
            selIndex = 0;
        }
        [self.navButton updateTextCount:selIndex];
    }else{
        [self.navButton updateTextCount:0];
    }
    [self.toolBar updateCount:self.selectArr.count];
}

- (void)initViews{
    [self.view addSubview:self.collectionview];
    [self.view addSubview:self.toolBar];
    if (self.selectArr.count > 0) {
        [self.view addSubview:self.preTabView];
        self.preTabView.selectArr = self.selectArr;
        self.preTabView.currentItem = [self.imageList objectAtIndex:self.index];
    }
    
    [self.collectionview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self updatePageStatus];

}



- (void)rightBtnAction{
    PHAssetModel * model = [self.imageList objectAtIndex:self.index];
    if (model.selStatus == 1) {
        model.selStatus = 0;
        [self.selectArr removeObject:model];
        if (self.selectArr.count <= 0) {
            self.preTabView.currentItem = nil;
            [self.preTabView removeFromSuperview];
        }else{
            self.preTabView.currentItem = self.selectArr.lastObject;
            NSInteger idx = [self.imageList indexOfObject:self.selectArr.lastObject];
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            [self.collectionview scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    }else{
        if (self.selectArr.count >= [ZWAlbumManager manager].maxSelectCount) {
            [Toast show:[NSString stringWithFormat:@"你最多只能选择%@张照片", @([ZWAlbumManager manager].maxSelectCount)]];
        }else{
            model.selStatus = 1;
            [self.selectArr addObject:model];
            if (![self.view.subviews containsObject:self.preTabView]) {
                [self.view addSubview:self.preTabView];
                self.preTabView.selectArr = self.selectArr;
            }
            self.preTabView.currentItem = model;
        }
    }
    [self updatePageStatus];
    if (_delegate && [_delegate respondsToSelector:@selector(imageDidSelect:selectArr:)]) {
        [_delegate imageDidSelect:self selectArr:self.selectArr];
    }
}

- (void)backAction{
    if (_delegate && [_delegate respondsToSelector:@selector(isOriginalDidChange:)]) {
        [_delegate isOriginalDidChange:self.toolBar.isOriginal];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)checkSelect{
    PHAssetModel * model = [self.imageList objectAtIndex:self.index];
    if ([self.selectArr containsObject:model]) {
        return YES;
    }
    return NO;
}

- (void)hidenNavAndToorBar{
    if (self.navigationController.navigationBar.hidden == YES) {
        self.navigationController.navigationBar.hidden = NO;
        self.toolBar.hidden = NO;
        self.preTabView.hidden = NO;
    }else{
        self.navigationController.navigationBar.hidden = YES;
        self.toolBar.hidden = YES;
        self.preTabView.hidden = YES;
    }
}

#pragma mark ZWPreTabViewDelegate

- (void)zwPreTabView:(UIView *)preView didScroll:(NSInteger)index{
    PHAssetModel * current = [self.selectArr objectAtIndex:index];
    if ([self.imageList containsObject:current]) {
        NSInteger idx = [self.imageList indexOfObject:current];
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        [self.collectionview scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

#pragma mark ZWToolBarDelegate

- (void)toolBarDidClick:(UIView *)toolBar index:(NSInteger)index{
    if (index == 1) {
        __weak ZWAlbumPreViewController * weakSelf = self;
        [ZWImageUtil configPathWithModel:self.selectArr complete:^(NSArray<PHAssetModel *> * _Nonnull arr) {
            BlockSafeRun([ZWAlbumManager manager].selectImageComplete,arr,weakSelf.toolBar.isOriginal);
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

#pragma mark UIScrollDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    self.index = roundf(scrollView.contentOffset.x / kMainScreenWidth);
    [self updatePageStatus];
    self.preTabView.currentItem = [self.imageList objectAtIndex:self.index];
}

#pragma mark - UICollectionViewDelegate
// 将要消失的cell还原它的scale
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    ZWPreCell * LLCell = (ZWPreCell *)cell;
    [LLCell.imageView resetScale];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imageList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ZWPreCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentify forIndexPath:indexPath];
    __weak ZWAlbumPreViewController * weakSelf = self;
    [cell.imageView setTapAction:^{
        [weakSelf hidenNavAndToorBar];
    }];
    PHAssetModel * model = [self.imageList objectAtIndex:indexPath.row];
    [cell update:model];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
}

#pragma lazyLoad

- (UICollectionView *)collectionview{
    if (!_collectionview) {
        ZWCardLayout * layout = [[ZWCardLayout alloc]init];
        layout.minimumLineSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionview = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight - kMainNavHeight - kSysStatusBarHeight) collectionViewLayout:layout];
        _collectionview.pagingEnabled = YES;
        _collectionview.dataSource = self;
        _collectionview.delegate = self;
        _collectionview.alwaysBounceHorizontal = YES;
        [_collectionview registerClass:[ZWPreCell class] forCellWithReuseIdentifier:kCellIdentify];
    }
    return _collectionview;
}

- (ZWToolBar *)toolBar{
    if (!_toolBar) {
        _toolBar = [[ZWToolBar alloc]initWithFrame:CGRectMake(0, kMainScreenHeight -  SafeAreaBottomAreaHeight - 44, kMainScreenWidth, 44 + SafeAreaBottomAreaHeight)];
        [_toolBar updateCount:0];
        _toolBar.isOriginal = self.isOriginal;
        _toolBar.isHightLight = NO;
        _toolBar.isPre = YES;
        _toolBar.delegate = self;
        
    }
    return _toolBar;
}

- (NSMutableArray <PHAssetModel *> *)imageList{
    if (!_imageList) {
        _imageList = [NSMutableArray array];
    }
    return _imageList;
}

- (ZWPreTabView *)preTabView{
    if (!_preTabView) {
        _preTabView = [[ZWPreTabView alloc]initWithFrame:CGRectMake(0, kMainScreenHeight - kMainNavHeight - kSysStatusBarHeight - SafeAreaBottomAreaHeight - 87.5, kMainScreenWidth, 87.5 + SafeAreaBottomAreaHeight)];
        _preTabView.delegate = self;
    }
    return _preTabView;
}


@end
