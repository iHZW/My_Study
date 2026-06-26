//
//  CustomSwipingView.h
//  My_Study
//
//  Created by hzw on 2025/1/22.
//  Copyright © 2025 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// Protocol for views that can be updated
@protocol SwiperViewUpdatable <NSObject>
- (void)updateWithData:(id)data;
@end

@interface CustomSwipingView : UIView

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray<UIView<SwiperViewUpdatable> *> *views;
@property(nonatomic, strong) NSTimer  * _Nullable autoScrollTimer;
@property(nonatomic, assign) CGFloat autoScrollInterval;
@property(nonatomic, strong) UIPageControl *pageControl;

- (instancetype)initWithFrame:(CGRect)frame
                        views:(NSArray<UIView<SwiperViewUpdatable> *> *)views
           autoScrollInterval:(CGFloat)interval;

- (void)replaceView:(UIView<SwiperViewUpdatable> *)view atIndex:(NSInteger)index;

- (void)replaceAllViews:(NSArray<UIView<SwiperViewUpdatable> *> *)views;

- (void)updateData:(id)data forViewAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
