//
//  ZWCropButtonView.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZWButtonDelegate <NSObject>

- (void)zwButtonDidClick:(UIView *)button;

@end

@interface ZWCropButton : ZWBaseView

@property (nonatomic ,assign) BOOL isHighLight;

@property (nonatomic ,weak) id<ZWButtonDelegate> delegate;

- (void)updateText:(NSString *)text count:(NSInteger)count;

- (CGSize)caculateWidth;

@end

NS_ASSUME_NONNULL_END
