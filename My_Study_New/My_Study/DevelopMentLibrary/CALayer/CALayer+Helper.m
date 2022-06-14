//
//  CALayer+Helper.m
//  PASecuritiesApp
//
//  Created by Howard on 16/8/4.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "CALayer+Helper.h"


@implementation CALayer (Helper)


+ (instancetype)layerWithFrame:(CGRect)frame color:(UIColor*)color
{
    CALayer *l      = [[self class] layer];
    l.contentsScale = [[UIScreen mainScreen] scale];
    l.frame         = frame;
    
    if (color) {
        l.backgroundColor = color.CGColor;
    }
    return l;
}

- (CGPoint)center
{
    CGRect f = self.frame;
    return CGPointMake(f.origin.x + f.size.width/2, f.origin.y + f.size.height/2);
}

- (void)setCenter:(CGPoint)center
{
    CGPoint o  = self.center;
    CGRect f   = self.frame;
    CGRect t   = CGRectMake(f.origin.x + (center.x - o.x), f.origin.y + (center.y - o.y), f.size.width, f.size.height);
    self.frame = t;
}

@end
