//
//  ZWColorPickInfoView.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/13.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@class ZWColorPickInfoView;

@protocol ZWColorPickInfoViewDelegate <NSObject>

- (void)closeBtnAction:(id)sender view:(ZWColorPickInfoView *)view;

@end

@interface ZWColorPickInfoView : ZWBaseView

@property (nonatomic, weak) id<ZWColorPickInfoViewDelegate> delegate;

- (void)setCurrentColor:(NSString *)hexColor;



@end

NS_ASSUME_NONNULL_END
