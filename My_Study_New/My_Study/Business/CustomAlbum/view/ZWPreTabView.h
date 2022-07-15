//
//  ZWPreTabView.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/12.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWBaseView.h"

@class PHAssetModel;
NS_ASSUME_NONNULL_BEGIN

@protocol ZWPreTabViewDelegate <NSObject>

- (void)zwPreTabView:(UIView *)preView didScroll:(NSInteger)index;

@end

@interface ZWPreTabView : ZWBaseView

@property (nonatomic ,weak) id <ZWPreTabViewDelegate> delegate;

@property (nonatomic ,strong ,nullable) PHAssetModel * currentItem;

@property (nonatomic ,strong) NSArray <PHAssetModel *> * selectArr;

@end

NS_ASSUME_NONNULL_END
