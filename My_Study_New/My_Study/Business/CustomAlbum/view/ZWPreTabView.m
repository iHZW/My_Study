//
//  ZWPreTabView.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/12.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWPreTabView.h"
#import "PHAssetModel.h"
#import "UIColor+Ext.h"
#import "ZWAlbumManager.h"

#pragma mark - FvPreTabCell
#define kCellIdentify @"ZZZZZZZ"

@interface ZWPreTabCell : UICollectionViewCell

@property (nonatomic ,strong) UIImageView * imageVc;

@end

@implementation ZWPreTabCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initViews];
    }
    return self;
}

- (void)initViews{
    _imageVc = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    _imageVc.contentMode = UIViewContentModeScaleAspectFill;
    _imageVc.clipsToBounds = YES;
    [self.contentView addSubview:_imageVc];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _imageVc.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
}

- (void)update:(PHAssetModel *)data{
    __weak ZWPreTabCell * weakSelf = self;
    [[ZWAlbumManager manager] thumbnail:data.asset complete:^(UIImage * _Nonnull result) {
        weakSelf.imageVc.image  = result;
    }];
}

- (void)selectStatus{
    self.imageVc.layer.borderWidth = 3.5;
    self.imageVc.layer.borderColor = [UIColor colorFromHexCode:@"#4F7AFD"].CGColor;
}

- (void)unSelectStatus{
    self.imageVc.layer.borderWidth = 0;
    self.imageVc.layer.borderColor = [UIColor colorFromHexCode:@"#4F7AFD"].CGColor;
}

@end




#pragma mark - ZWPreTabView

@interface ZWPreTabView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic ,strong) UICollectionView * collectview;


@end

@implementation ZWPreTabView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initViews];
    }
    return self;
}

- (void)initViews{
    [self addSubview:self.collectview];
    [self.collectview reloadData];
}

- (void)setCurrentItem:(PHAssetModel *)currentItem{
    _currentItem = currentItem;
    [self.collectview reloadData];
    if ([self checkCurrentItem] >= 0) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[self checkCurrentItem] inSection:0];
        [self.collectview scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
}

- (NSInteger)checkCurrentItem{
    if ([self.selectArr containsObject:self.currentItem]) {
        return [self.selectArr indexOfObject:self.currentItem];
    }
    return -10;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_delegate && [_delegate respondsToSelector:@selector(zwPreTabView:didScroll:)]) {
        [_delegate zwPreTabView:self didScroll:indexPath.row];
    }
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.selectArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ZWPreTabCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentify forIndexPath:indexPath];
    PHAssetModel * model = [self.selectArr objectAtIndex:indexPath.row];
    [cell update:model];
    if ([self checkCurrentItem] >= 0) {
        if (indexPath.row == [self checkCurrentItem]) {
            [cell selectStatus];
        }else{
            [cell unSelectStatus];
        }
    }else{
        [cell unSelectStatus];
    }
    return cell;
}

#pragma mark lazyLoad

- (UICollectionView *)collectview{
    if (!_collectview) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(64, 64);
        layout.minimumLineSpacing = 12;
        layout.minimumInteritemSpacing = 12;
        layout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

        _collectview = [[UICollectionView alloc]initWithFrame:CGRectMake(0,0, self.frame.size.width, self.frame.size.height) collectionViewLayout:layout];
        _collectview.showsVerticalScrollIndicator = NO;
        _collectview.showsHorizontalScrollIndicator = NO;
        _collectview.backgroundColor = [UIColor whiteColor];
        _collectview.delegate = self;
        _collectview.dataSource = self;
        [_collectview registerClass:[ZWPreTabCell class] forCellWithReuseIdentifier:kCellIdentify];
    }
    return _collectview;
}

@end
