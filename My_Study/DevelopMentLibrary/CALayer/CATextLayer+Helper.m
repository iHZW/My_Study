//
//  CATextLayer+Helper.m
//  PASecuritiesApp
//
//  Created by Howard on 16/8/4.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "CATextLayer+Helper.h"


@implementation CATextLayer (Helper)

+ (CATextLayer *)textLayerWithFrame:(CGRect)frame text:(NSString *)text fontSize:(CGFloat)size fontColor:(UIColor*)color
{
    return [self textLayerWithFrame:frame text:text font:nil fontSize:size fontColor:color];
}

+ (CATextLayer *)textLayerWithFrame:(CGRect)frame text:(NSString *)text font:(UIFont *)font fontSize:(CGFloat)size fontColor:(UIColor *)color
{
    CATextLayer *layer  = [CATextLayer layer];
    layer.frame         = frame;
    layer.fontSize      = size;
    layer.contentsScale = [[UIScreen mainScreen] scale];
    
    if (text) {
        layer.string = text;
    }
    
    if (font) {
        layer.font = (__bridge CFTypeRef _Nullable)(font);
    }
    
    if (color) {
        layer.foregroundColor = color.CGColor;
    }
    return layer;
}

@end
