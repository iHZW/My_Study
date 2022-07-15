//
//  ZWAlbumDetailsViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/12.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWAlbumDetailsViewController.h"
#import "ZWToolBar.h"
#import "ZWCacheManager.h"
#import "ZWToolBar.h"
#import "ZWImageUtil.h"
#import "ZWImageCell.h"
#import "ZWAlbumPopView.h"
#import "ZWAlbumCropViewController.h"
#import "ZWAlbumPreViewController.h"

#define kCellIdentify @"zlmdsb"

@interface ZWAlbumDetailsViewController ()
<UICollectionViewDelegate,
UICollectionViewDataSource,
ZWImageCellDelegate,
ZWToolBarDelegate,
ZWAlbumPreViewControllerDelegate,
ZWAlbumPopViewDelegate >

@property (nonatomic ,strong) UICollectionView * collectview;

@property (nonatomic ,strong) ZWAlbumPopView * popVc;

@property (nonatomic ,strong) UIView * titleVc;

@property (nonatomic ,strong) UILabel * titleLabel;

@property (nonatomic ,strong) UIImageView * titleArrow;

@property (nonatomic ,strong) ZWToolBar * toolBar;

@property (nonatomic ,strong) NSArray <PHAssetModel *> * imageList;

@property (nonatomic ,strong) NSMutableArray <PHAssetModel *> * selectArr;

@property (nonatomic ,assign) BOOL hasSelectMax;

@property (nonatomic ,assign) BOOL hasShowPop;

@end

@implementation ZWAlbumDetailsViewController

- (void)dealloc{
    [[ZWCacheManager shared] stopCachingImagesForAllAssets];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
        
    [self initNav];
    
    [self initViews];
    
    self.hasSelectMax = NO;
    
    self.hasShowPop = NO;
    
    self.imageList = [[ZWAlbumManager manager] photoList:self.collection];
    
    [self reloadList];
    
    // 预先缓存相册列表
    [[ZWAlbumManager manager] updateSystemAlbumList:nil];
}

- (void)goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initNav{
    
    _titleVc = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [self caculateTitleSize].width + 7 + 12, 24)];
    _titleVc.userInteractionEnabled = YES;
    
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [self caculateTitleSize].width, 24)];
    _titleLabel.font = PASFont(17);
    _titleLabel.text = self.collection.localizedTitle;
    [_titleVc addSubview:_titleLabel];
    
    _titleArrow = [[UIImageView alloc]initWithFrame:CGRectMake(_titleVc.frame.size.width - 12, 6, 12, 12)];
    _titleArrow.image = [UIImage imageNamed:@"icon_screen_arrow_down"];
    _titleArrow.contentMode = UIViewContentModeScaleAspectFill;
    [_titleVc addSubview:_titleArrow];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]init];
    [tap addTarget:self action:@selector(clickTitleView)];
    [_titleVc addGestureRecognizer:tap];
    
    self.navigationItem.titleView = _titleVc;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
}

- (CGSize)caculateTitleSize{
    UILabel * label = [[UILabel alloc]init];
    label.font = PASFont(17);
    label.text = self.collection.localizedTitle;
    CGSize size = [label sizeThatFits:CGSizeMake(MAXFLOAT, 24)];
    return size;
}

- (void)initViews{
    [self.view addSubview:self.collectview];
    if ([ZWAlbumManager manager].selectType == ZWAlbumSelectTypeMore) {
        [self.view addSubview:self.toolBar];
    }else{
        self.collectview.frame = CGRectMake(0,0, kMainScreenWidth, kMainScreenHeight - (kSysStatusBarHeight + kMainNavHeight));
    }
}

- (void)reloadList{
    _titleLabel.text = self.collection.localizedTitle;
    _titleLabel.frame = CGRectMake(0, 0, [self caculateTitleSize].width, 24);
    _titleVc.frame = CGRectMake(0, 0, [self caculateTitleSize].width + 7 + 12, 24);
    _titleArrow.frame = CGRectMake(_titleVc.frame.size.width - 12, 6, 12, 12);

    [self.collectview reloadData];
    [self.collectview layoutIfNeeded];
//    dispatch_async(dispatch_get_main_queue(),^{
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.imageList.count - 1 inSection:0];
        [self.collectview scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
//    });
    [self cacheLastImages];
}

- (void)updateTitleViewStatus{
    if (self.hasShowPop == NO) {
        self.titleArrow.image = [UIImage imageNamed:@"icon_screen_arrow_up"];
        self.hasShowPop = YES;
    }else{
        self.titleArrow.image = [UIImage imageNamed:@"icon_screen_arrow_down"];
        self.hasShowPop = NO;
    }
}

#pragma mark actions

- (void)clickTitleView{
    if (self.hasShowPop) {
        [self.popVc dismissAnimation];
    }else{
        [self.view addSubview:self.popVc];
        [self.popVc showAnimation];
        [self updateTitleViewStatus];
    }
}

- (void)preImage:(PHAssetModel *)model{
    ZWAlbumPreViewController * vc = [[ZWAlbumPreViewController alloc]init];
    vc.isOriginal = self.toolBar.isOriginal;
    vc.delegate = self;
    if (model) {
        vc.index = [self.imageList indexOfObject:model];
        [vc.imageList addObjectsFromArray:self.imageList];
    }else{
        vc.index = 0;
        [vc.imageList addObjectsFromArray:self.selectArr];
    }
    vc.selectArr = self.selectArr;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cacheThumImages{
    NSMutableArray * indexArr = [NSMutableArray array];
    [self.collectview.indexPathsForVisibleItems enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [indexArr addObject:[self.imageList objectAtIndex:obj.row].asset];
    }];
    [ZWCacheManager shared].allowsCachingHighQualityImages = NO;
    [[ZWAlbumManager manager] cacheAssetList:indexArr option:[ZWAlbumManager manager].thumOption];
}

- (void)cancelCacheThumImage{
    NSMutableArray * indexArr = [NSMutableArray array];
    NSInteger count = self.collectview.indexPathsForVisibleItems.count;
    if (self.collectview.indexPathsForVisibleItems.firstObject.row > self.collectview.indexPathsForVisibleItems.lastObject.row) {
        NSIndexPath * indexPath = self.collectview.indexPathsForVisibleItems.firstObject;
        NSInteger min = (indexPath.row - 2 * count) > 0 ? (indexPath.row - 2 * count) : 0;
        NSInteger orign = (indexPath.row - count) > 0 ? (indexPath.row - count) : 0;
        for (NSInteger i = orign; i > min; i--) {
            [indexArr addObject:[self.imageList objectAtIndex:i].asset];
        }
//        NSLog(@"向上滚动");
    }else{
        NSIndexPath * indexPath = self.collectview.indexPathsForVisibleItems.lastObject;
        NSInteger max = (indexPath.row + 2 * count) > (self.imageList.count - 1) ? (self.imageList.count - 1) : (indexPath.row + 2 * count);
        NSInteger orign = (indexPath.row + count) > (self.imageList.count - 1) ? (self.imageList.count - 1) : (indexPath.row + count);
        for (NSInteger i = orign; i < max; i++) {
            [indexArr addObject:[self.imageList objectAtIndex:i].asset];
        }
//        NSLog(@"向下滚动");
    }
    [[ZWAlbumManager manager] stopCacheAssetList:indexArr option:[ZWAlbumManager manager].thumOption];
}

- (void)cacheLastImages{
    NSMutableArray * indexArr = [NSMutableArray array];
    for (NSInteger i = self.imageList.count - 1; i > self.imageList.count - 1 - 28; i--) {
        PHAssetModel *model = PASArrayAtIndex(self.imageList, i);
        PHAsset *asset = model.asset;
        if (asset) {
            [indexArr addObject:[self.imageList objectAtIndex:i].asset];
        }
    }
    [ZWCacheManager shared].allowsCachingHighQualityImages = NO;
    [[ZWAlbumManager manager] cacheAssetList:indexArr option:[ZWAlbumManager manager].thumOption];
}

#pragma mark ZWAlbumPopViewDelegate

- (void)popViewSelect:(PHAssetCollection *)collection{
    self.collection = collection;
    self.imageList = [[ZWAlbumManager manager] photoList:self.collection];
    [self reloadList];
    [self.popVc dismissAnimation];
}

- (void)popViewDidDismiss{
    [self updateTitleViewStatus];
}

#pragma mark ZWImageCellDelegate

- (void)zwImageCellDidChangeStatus:(UIView *)cell data:(PHAssetModel *)data{
    NSIndexPath * indexPath = [self.collectview indexPathForCell:(UICollectionViewCell *)cell];
    if (!self.hasSelectMax) {
        if (data.selStatus == 0) {
            data.selStatus = 1;
            [self.selectArr addObject:data];
            if (self.selectArr.count >= [ZWAlbumManager manager].maxSelectCount) {
                self.hasSelectMax = YES;
                [UIView performWithoutAnimation:^{
                    [self.collectview reloadItemsAtIndexPaths:self.collectview.indexPathsForVisibleItems];
                }];
            }else{
                [UIView performWithoutAnimation:^{
                    [self.collectview reloadItemsAtIndexPaths:@[indexPath]];
                }];
            }
        }else if (data.selStatus == 1){
            data.selStatus = 0;
            [self.selectArr removeObject:data];
            [UIView performWithoutAnimation:^{
                [self.collectview reloadItemsAtIndexPaths:self.collectview.indexPathsForVisibleItems];
            }];
        }
    }else{
        if (data.selStatus == 1){
            data.selStatus = 0;
            self.hasSelectMax = NO;
            [self.selectArr removeObject:data];
            [UIView performWithoutAnimation:^{
                [self.collectview reloadItemsAtIndexPaths:self.collectview.indexPathsForVisibleItems];
            }];
        }else{
            [Toast show:[NSString stringWithFormat:@"你最多只能选择%@张照片",@([ZWAlbumManager manager].maxSelectCount)]];
        }
    }
    [self.toolBar updateCount:self.selectArr.count];
}

#pragma mark ToolBarDelegate

- (void)toolBarDidClick:(UIView *)toolBar index:(NSInteger)index{
    if (index == 0) {
        [self preImage:nil];
    }else if (index == 1){
        __weak ZWAlbumDetailsViewController * weakSelf = self;
        [ZWImageUtil configPathWithModel:self.selectArr complete:^(NSArray<PHAssetModel *> * _Nonnull arr) {
            BlockSafeRun([ZWAlbumManager manager].selectImageComplete,arr,weakSelf.toolBar.isOriginal);
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

#pragma mark ZWAlbumPreViewControllerDelegate

- (void)isOriginalDidChange:(BOOL)isOriginal{
    self.toolBar.isOriginal = isOriginal;
}

- (void)imageDidSelect:(UIViewController *)vc selectArr:(NSArray <PHAssetModel *> *)selectArr{
    self.hasSelectMax = self.selectArr.count >= [ZWAlbumManager manager].maxSelectCount ? YES:NO;
    [self.collectview reloadData];
    [self.toolBar updateCount:self.selectArr.count];
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PHAssetModel * model = [self.imageList objectAtIndex:indexPath.row];
    if ([ZWAlbumManager manager].selectType == ZWAlbumSelectTypeSingle) {
        if ([ZWAlbumManager manager].isCrop) {
            ZWAlbumCropViewController * vc = [[ZWAlbumCropViewController alloc]init];
            vc.data = model;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
//            if ([ZWAlbumManager manager].allowPre) {
//                PHAssetModel * model = [self.imageList objectAtIndex:indexPath.row];
//                [self preImage:model];
//            }else{
                [self.selectArr addObject:model];
                __weak ZWAlbumDetailsViewController * weakSelf = self;
                [ZWImageUtil configPathWithModel:self.selectArr complete:^(NSArray<PHAssetModel *> * _Nonnull arr) {
                    BlockSafeRun([ZWAlbumManager manager].selectImageComplete,arr,weakSelf.toolBar.isOriginal);
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                }];
//            }
        }
    }else if ([ZWAlbumManager manager].selectType == ZWAlbumSelectTypeMore){
        if ([ZWAlbumManager manager].allowPre) {
            PHAssetModel * model = [self.imageList objectAtIndex:indexPath.row];
            [self preImage:model];
        }
    }
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self cacheThumImages];
    [self cancelCacheThumImage];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imageList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ZWImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentify forIndexPath:indexPath];
    cell.delegate = self;
    PHAssetModel * set = [self.imageList objectAtIndex:indexPath.row];
    NSInteger selIndex;
    if ([self.selectArr containsObject:set]) {
        selIndex = [self.selectArr indexOfObject:set] + 1;
    }else{
        selIndex = 0;
    }
    [cell update:set selIndex:selIndex hasSelectMax:self.hasSelectMax];
    return cell;
}

#pragma mark lazyLoad

- (UICollectionView *)collectview{
    if (!_collectview) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake((kMainScreenWidth - 3) / 4, (kMainScreenWidth - 3) / 4);
        layout.minimumLineSpacing = 1;
        layout.minimumInteritemSpacing = 1;
        
        _collectview = [[UICollectionView alloc]initWithFrame:CGRectMake(0,0, kMainScreenWidth, kMainScreenHeight - (kSysStatusBarHeight + kMainNavHeight) - SafeAreaBottomAreaHeight - 45) collectionViewLayout:layout];
//        _collectview.contentInset = UIEdgeInsetsMake(UISTATUS_BAR_HEIGHT + 44, 0, 0, 0);
        _collectview.alwaysBounceVertical = YES;
        _collectview.showsVerticalScrollIndicator = NO;
        _collectview.backgroundColor = [UIColor whiteColor];
        _collectview.delegate = self;
        _collectview.dataSource = self;
        [_collectview registerClass:[ZWImageCell class] forCellWithReuseIdentifier:kCellIdentify];
    }
    return _collectview;
}

- (NSMutableArray *)selectArr{
    if (!_selectArr) {
        _selectArr = [NSMutableArray array];
    }
    return _selectArr;
}

- (ZWToolBar *)toolBar{
    if (!_toolBar) {
        _toolBar = [[ZWToolBar alloc]initWithFrame:CGRectMake(0, kMainScreenHeight  - (kSysStatusBarHeight + kMainNavHeight) -  SafeAreaBottomAreaHeight - 44, kMainScreenWidth, 44 + SafeAreaBottomAreaHeight)];
        [_toolBar updateCount:0];
        _toolBar.isOriginal = NO;
        _toolBar.isHightLight = NO;
        _toolBar.delegate = self;
    }
    return _toolBar;
}

- (ZWAlbumPopView *)popVc{
    if (!_popVc) {
        _popVc = [[ZWAlbumPopView alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight - (kSysStatusBarHeight + kMainNavHeight))];
        _popVc.delegate = self;
    }
    return _popVc;
}


@end
