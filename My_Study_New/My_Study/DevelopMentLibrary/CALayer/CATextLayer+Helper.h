//
//  CATextLayer+Helper.h
//  PASecuritiesApp
//
//  Created by Howard on 16/8/4.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>


@interface CATextLayer (Helper)

+ (CATextLayer *)textLayerWithFrame:(CGRect)frame text:(NSString *)text fontSize:(CGFloat)size fontColor:(UIColor*)color;

+ (CATextLayer *)textLayerWithFrame:(CGRect)frame text:(NSString *)text font:(UIFont *)font fontSize:(CGFloat)size fontColor:(UIColor *)color;


@end
