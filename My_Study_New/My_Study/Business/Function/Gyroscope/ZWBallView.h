//
//  ZWBallView.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/14.
//  Copyright © 2022 HZW. All rights reserved.
//
/** 球view  */
#import "ZWBaseView.h"
#import <CoreMotion/CoreMotion.h>


NS_ASSUME_NONNULL_BEGIN

@interface ZWBallView : ZWBaseView

@property (nonatomic, assign) CMAcceleration acceleration;

@property (nonatomic, strong) UIImageView *imageView;

- (void)updateLocation;

@end

NS_ASSUME_NONNULL_END
