//
//  SwiperView.m
//  My_Study
//
//  Created by hzw on 2025/2/26.
//  Copyright © 2025 HZW. All rights reserved.
//

#import "SwiperView.h"

@interface SwiperCell ()
@end
@implementation SwiperCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _customView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        _customView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_customView];
    }
    return self;
}
@end

@interface SwiperView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UIPageControl *pageControl;
@property(nonatomic, strong) NSArray *items;
@property(nonatomic, strong) NSTimer *autoScrollTimer;
@end

@implementation SwiperView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        _autoScrollEnabled = YES;
        _autoScrollInterval = 3.0;
        _items = @[];
    }
    return self;
}

- (void)setupUI {
    // 设置CollectionView
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;

    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerClass:[SwiperCell class] forCellWithReuseIdentifier:@"SwiperCell"];
    [self addSubview:_collectionView];

    // 设置PageControl
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    [self addSubview:_pageControl];

    // 布局
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_collectionView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [_collectionView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [_collectionView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_collectionView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],

        [_pageControl.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [_pageControl.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10]
    ]];
}

#pragma mark - Public Methods

- (void)reloadDataWithItems:(NSArray *)items {
    self.items = [items copy];
    self.pageControl.numberOfPages = items.count;
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
    [self restartAutoScroll];
}

- (void)updateItemsAtIndexes:(NSArray<NSNumber *> *)indexes withItems:(NSArray *)items {
    if (indexes.count != items.count || indexes.count > self.items.count) return;

    NSMutableArray *newItems = [self.items mutableCopy];
    for (NSInteger i = 0; i < indexes.count; i++) {
        NSInteger index = [indexes[i] integerValue];
        if (index < newItems.count) {
            newItems[index] = items[i];
        }
    }
    self.items = [newItems copy];
    
    NSMutableArray *dataArr = [NSMutableArray array];
    for (NSNumber *number in indexes) {
        NSIndexPath *tempIndexPath = [NSIndexPath indexPathForItem:number.integerValue inSection:0];
        [dataArr addObject:tempIndexPath];
    }
    [self.collectionView reloadItemsAtIndexPaths:dataArr];
}

#pragma mark - Auto Scroll

- (void)restartAutoScroll {
    if (!self.autoScrollEnabled || self.items.count <= 1) return;

    [self stopAutoScroll];
    self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollInterval
                                                            target:self
                                                          selector:@selector(autoScrollNext)
                                                          userInfo:nil
                                                           repeats:YES];
}

- (void)stopAutoScroll {
    [self.autoScrollTimer invalidate];
    self.autoScrollTimer = nil;
}

- (void)autoScrollNext {
    NSInteger currentIndex = self.collectionView.contentOffset.x / self.collectionView.bounds.size.width;
    NSInteger nextIndex = (currentIndex + 1) % self.items.count;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:nextIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:YES];
}

#pragma mark - UICollectionView DataSource & Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SwiperCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SwiperCell" forIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(swiperView:viewForItemAtIndex:)]) {
        UIView *customView = [self.delegate swiperView:self viewForItemAtIndex:indexPath.item];
        [cell.customView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [cell.customView addSubview:customView];
        customView.frame = cell.customView.bounds;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.bounds.size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(swiperView:didSelectItemAtIndex:)]) {
        [self.delegate swiperView:self didSelectItemAtIndex:indexPath.item];
    }
}

#pragma mark - Scroll Handling

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger currentPage = round(scrollView.contentOffset.x / scrollView.bounds.size.width);
    self.pageControl.currentPage = currentPage;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopAutoScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self restartAutoScroll];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self restartAutoScroll];
}

@end
