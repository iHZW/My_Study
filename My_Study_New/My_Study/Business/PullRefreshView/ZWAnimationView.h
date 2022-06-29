//
//  ZWAnimationView.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/29.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWAnimationView : ZWBaseView

@property (nonatomic, strong) UIImage *imageIcon;

@property (nonatomic, strong) UIColor *circleColor;

- (void)startAnimating:(float)value;

- (void)startAnimating;

- (void)stopAnimating;


@end

NS_ASSUME_NONNULL_END
