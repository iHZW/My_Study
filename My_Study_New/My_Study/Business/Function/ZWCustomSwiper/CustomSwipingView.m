//
//  CustomSwipingView.m
//  My_Study
//
//  Created by hzw on 2025/1/22.
//  Copyright © 2025 HZW. All rights reserved.
//

#import "CustomSwipingView.h"

static NSString * const kZWCustomSwiperCellId = @"ZWCustomSwiperCellId";

@interface CustomSwipingView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation CustomSwipingView

- (instancetype)initWithFrame:(CGRect)frame 
                        views:(NSArray<UIView<SwiperViewUpdatable> *> *)views
           autoScrollInterval:(CGFloat)interval {
    self = [super initWithFrame:frame];
    if (self) {
        self.views = [views mutableCopy];
        self.autoScrollInterval = interval;

        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.itemSize = frame.size;

        self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.pagingEnabled = YES;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kZWCustomSwiperCellId];
        [self addSubview:self.collectionView];

        // Initialize page control
        
        self.pageControl.numberOfPages = views.count;
        [self addSubview:self.pageControl];
        [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self);
            make.height.mas_equalTo(30);
        }];
        
        [self startAutoScroll];
    }
    return self;
}

- (void)startAutoScroll {
    if (self.autoScrollInterval > 0) {
        self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollInterval target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
    }
}

- (void)stopAutoScroll {
    [self.autoScrollTimer invalidate];
    self.autoScrollTimer = nil;
}

- (void)autoScroll {
    NSInteger currentIndex = self.collectionView.contentOffset.x / self.collectionView.frame.size.width;
    NSInteger nextIndex = currentIndex + 1;
    if (nextIndex >= self.views.count * 1000) {
        nextIndex = self.views.count * 500; // Reset to middle
    }
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:nextIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    [self updatePageControlForIndex:nextIndex];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.views.count * 1000; // Large number for infinite scrolling
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZWCustomSwiperCellId forIndexPath:indexPath];
    UIView<SwiperViewUpdatable> *view = self.views[indexPath.item % self.views.count];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell.contentView addSubview:view];
    view.frame = cell.contentView.bounds;
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopAutoScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self resetPositionIfNeeded];
    [self updatePageControlForIndex:self.collectionView.contentOffset.x / self.collectionView.frame.size.width];
    [self startAutoScroll];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self resetPositionIfNeeded];
}

- (void)resetPositionIfNeeded {
    NSInteger currentIndex = self.collectionView.contentOffset.x / self.collectionView.frame.size.width;
    if (currentIndex == 0 || currentIndex == [self.collectionView numberOfItemsInSection:0] - 1) {
        NSInteger middleIndex = self.views.count * 500;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:middleIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
}

- (void)updatePageControlForIndex:(NSInteger)index {
    self.pageControl.currentPage = index % self.views.count;
}

- (void)replaceView:(UIView<SwiperViewUpdatable> *)view atIndex:(NSInteger)index {
    if (index < 0 || index >= self.views.count) {
        return; // Index out of bounds
    }
    self.views[index] = view;
    [self.collectionView reloadData];
}

- (void)replaceAllViews:(NSArray<UIView<SwiperViewUpdatable> *> *)views {
    self.views = [views mutableCopy];
    [self.collectionView reloadData];
}

- (void)updateData:(id)data forViewAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.views.count) {
        return; // Index out of bounds
    }
    UIView<SwiperViewUpdatable> *view = self.views[index];
    [view updateWithData:data];
}

- (void)pageControlTapped:(UIPageControl *)sender {
    NSInteger page = sender.currentPage;
    NSInteger targetIndex = page + self.views.count * 500; // Adjust to middle
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

#pragma mark -  Lazy loading
- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
        _pageControl.currentPage = 0;
        _pageControl.currentPageIndicatorTintColor = UIColor.redColor;
        _pageControl.pageIndicatorTintColor = UIColor.grayColor;
        [_pageControl addTarget:self action:@selector(pageControlTapped:) forControlEvents:UIControlEventValueChanged];
    }
    return _pageControl;
}

@end
