//
//  CALayer+Helper.h
//  PASecuritiesApp
//
//  Created by Howard on 16/8/4.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>


@interface CALayer (Helper)

+ (instancetype)layerWithFrame:(CGRect)frame color:(UIColor*)color;

@property (nonatomic, assign) CGPoint center;

@end
