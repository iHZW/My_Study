//
//  UIView+FrameSperator.m
//  PASecuritiesApp
//
//  Created by Howard on 16/8/4.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "UIView+FrameSperator.h"
#import "CALayer+Helper.h"


@implementation UIView (FrameSperator)

+ (void)divideRect:(CGRect)rect colCount:(NSUInteger)cols rowCount:(NSUInteger)rows renderCallback:(CMRenderRectIndexCallback)block
{
    cols         = cols > 0 ? cols : 1;
    rows         = rows > 0 ? rows : 1;
    CGSize tsize = CGSizeMake(rect.size.width / cols, rect.size.height / rows);
    CGRect frame = CGRectZero;
    CGPoint pos  = CGPointZero;
    
    for (int i = 0; i < rows; i++) {
        pos.x = 0;
        for (int j = 0; j < cols; j++) {
            frame = CGRectMake(pos.x, pos.y, tsize.width, tsize.height);
            //把frame转换成基于rect坐标位置
            frame.origin.x += rect.origin.x;
            frame.origin.y += rect.origin.y;
            block(frame,j,i);
            pos.x += tsize.width;
        }
        pos.y += tsize.height;
    }
}

+ (void)divideRect:(CGRect)rect colProportion:(NSString *)colPor rowProportion:(NSString *)rowPor renderCallback:(CMRenderRectIndexCallback)block
{
    NSArray *cols      = [colPor componentsSeparatedByString:@":"];
    cols               = cols.count > 0 ? cols : @[@(1)];
    __block float part = 0;
    
    [cols enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        part += [obj floatValue];
    }];
    
    CGFloat perCol = rect.size.width/part;
    NSArray *rows  = [rowPor componentsSeparatedByString:@":"];
    rows           = rows.count > 0 ? rows : @[@(1)];
    part           = 0;
    
    [rows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        part += [obj floatValue];
    }];
    
    CGFloat perRow = rect.size.height/part;
    CGFloat posY   = 0;
    
    CGRect frame;
    for (NSInteger i = 0; i < rows.count; i++) {
        CGFloat ht   = perRow * [rows[i]floatValue];
        CGFloat posX = 0;
        for (NSInteger j = 0; j<cols.count; j++) {
            CGFloat wd     = perCol * [cols[j]floatValue];
            frame          = CGRectMake(posX, posY, wd, ht);
            frame.origin.x += rect.origin.x;
            frame.origin.y += rect.origin.y;
            posX           += wd;
            block(frame,j,i);
        }
        posY += ht;
    }
}

+ (void)divideRectByHorizontal:(CGRect)rect colProportion:(NSString *)colPor renderCallback:(CMRenderRectIndexCallback)block
{
    [self divideRect:rect colProportion:colPor rowProportion:nil renderCallback:block];
}

+ (void)divideRectByVertical:(CGRect)rect rowProportion:(NSString *)rowPor renderCallback:(CMRenderRectIndexCallback)block
{
    [self divideRect:rect colProportion:nil rowProportion:rowPor renderCallback:block];
}

- (NSArray *)drawSeperatorLineWithRect:(CGRect)rect color:(UIColor *)color width:(CGFloat)width withEdges:(UIRectEdge)edgs
{
    NSMutableArray *ary = [NSMutableArray array];
    CGRect frame;
    if (edgs & UIRectEdgeTop) {
        frame          = CGRectMake(0, 0, rect.size.width, width);
        frame.origin.x += rect.origin.x;
        frame.origin.y += rect.origin.y;
        CALayer *layer = [CALayer layerWithFrame:frame color:color];
        [self.layer addSublayer:layer];
        [ary addObject:layer];
    }
    if (edgs & UIRectEdgeLeft) {
        frame          = CGRectMake(0, 0, width, rect.size.height);
        frame.origin.x += rect.origin.x;
        frame.origin.y += rect.origin.y;
        CALayer *layer = [CALayer layerWithFrame:frame color:color];
        [self.layer addSublayer:layer];
        [ary addObject:layer];
    }
    if (edgs & UIRectEdgeBottom) {
        frame          = CGRectMake(0, rect.size.height-width, rect.size.width, width);
        frame.origin.x += rect.origin.x;
        frame.origin.y += rect.origin.y;
        CALayer *layer = [CALayer layerWithFrame:frame color:color];
        [self.layer addSublayer:layer];
        [ary addObject:layer];
    }
    if (edgs & UIRectEdgeRight) {
        frame          = CGRectMake(rect.size.width-width, 0, width, rect.size.height);
        frame.origin.x += rect.origin.x;
        frame.origin.y += rect.origin.y;
        CALayer *layer = [CALayer layerWithFrame:frame color:color];
        [self.layer addSublayer:layer];
        [ary addObject:layer];
    }
    return ary;
}

- (NSArray *)drawSeperatorLine:(UIColor *)color width:(CGFloat)width withEdges:(UIRectEdge)edgs
{
    return [self drawSeperatorLineWithRect:self.bounds color:color width:width withEdges:edgs];
}

- (CAShapeLayer *)drawLineWithColor:(UIColor *)color width:(CGFloat)width forPath:(void (^)(CGMutablePathRef))drawBlock
{
    CAShapeLayer *layer     = [[CAShapeLayer alloc] init];
    layer.frame             = self.bounds;
    layer.strokeColor       = color.CGColor;
    layer.fillColor         = [UIColor clearColor].CGColor;
    layer.lineWidth         = width;
    CGMutablePathRef path   = CGPathCreateMutable();
    drawBlock(path);
    layer.path=path;
    CGPathRelease(path);
    [self.layer addSublayer:layer];
    return layer;
}

- (CAShapeLayer *)drawLineWithColor:(UIColor *)color width:(CGFloat)width startPos:(CGPoint)startPos endPos:(CGPoint)endPos
{
    CAShapeLayer *layer     = [[CAShapeLayer alloc] init];
    layer.frame             = self.bounds;
    layer.strokeColor       = color.CGColor;
    layer.lineWidth         = width;
    CGMutablePathRef path   = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, startPos.x, startPos.y);
    CGPathAddLineToPoint(path, NULL, endPos.x, endPos.y);
    layer.path=path;
    CGPathRelease(path);
    [self.layer addSublayer:layer];
    return layer;
}

@end
