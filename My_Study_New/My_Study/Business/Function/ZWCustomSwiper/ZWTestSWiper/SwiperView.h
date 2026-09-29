//
//  SwiperView.h
//  My_Study
//
//  Created by hzw on 2025/2/26.
//  Copyright © 2025 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SwiperCell : UICollectionViewCell
@property(nonatomic, strong) UIView *customView;
@end

@protocol SwiperViewDelegate <NSObject>
@optional
- (UIView *)swiperView:(UIView *)swiperView viewForItemAtIndex:(NSInteger)index;
- (void)swiperView:(UIView *)swiperView didSelectItemAtIndex:(NSInteger)index;
@end

@interface SwiperView : UIView
@property(nonatomic, weak) id<SwiperViewDelegate> delegate;
@property(nonatomic, assign) BOOL autoScrollEnabled;               // 是否自动滚动
@property(nonatomic, assign) NSTimeInterval autoScrollInterval;    // 自动滚动间隔，默认3秒
@property(nonatomic, strong, readonly) UIPageControl *pageControl; // 页面指示器
@property(nonatomic, strong, readonly) NSArray *items;


- (instancetype)initWithFrame:(CGRect)frame;
- (void)reloadDataWithItems:(NSArray *)items;                                           // 全量更新数据
- (void)updateItemsAtIndexes:(NSArray<NSNumber *> *)indexes withItems:(NSArray *)items; // 更新指定索引的数据
@end

NS_ASSUME_NONNULL_END
