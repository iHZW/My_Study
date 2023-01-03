//
//  GiveLikeView.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/12/30.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GiveLikeView : UIView

@property (nonatomic, strong) UIImageView *likeBefore;
@property (nonatomic, strong) UIImageView *likeAfter;
@property (nonatomic, assign) CGFloat     likeDuration;
@property (nonatomic, strong) UIColor     *zanFillColor;

- (void)resetView;

@end

NS_ASSUME_NONNULL_END
