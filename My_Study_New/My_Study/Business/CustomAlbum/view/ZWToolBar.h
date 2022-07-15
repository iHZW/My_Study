//
//  ZWToolBar.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/12.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZWToolBarDelegate <NSObject>

- (void)toolBarDidClick:(UIView *)toolBar index:(NSInteger)index;

@end

@interface ZWToolBar : ZWBaseView

@property (nonatomic ,assign) BOOL isHightLight;

@property (nonatomic ,assign) BOOL isOriginal;

@property (nonatomic ,assign) BOOL isPre;

@property (nonatomic ,weak) id<ZWToolBarDelegate> delegate;

- (void)updateCount:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
