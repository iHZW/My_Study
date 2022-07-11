//
//  UIImageView+Animations.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "UIImageView+Animations.h"

@implementation UIImageView (Animations)

- (void)rotating
{
    [self rotating:1 direction:1];
}

- (void)rotating:(CFTimeInterval)duration direction:(NSInteger)direction
{
    
    if (direction != 1 && direction != -1) {
        direction = 1;
    }
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    animation.toValue = [NSNumber numberWithFloat:(2 * M_PI) * direction];
    
    animation.duration = duration;
    //旋转效果累计，先转180度，接着再旋转180度，从而实现360旋转
    animation.cumulative = YES;
    animation.repeatCount = 1000;
    animation.removedOnCompletion = NO;
    
    [self.layer removeAnimationForKey:@"rotate360Degree"];
    [self.layer addAnimation:animation forKey:@"rotate360Degree"];
    
}


@end
