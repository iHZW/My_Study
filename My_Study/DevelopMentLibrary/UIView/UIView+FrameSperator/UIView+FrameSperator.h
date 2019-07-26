//
//  UIView+FrameSperator.h
//  PASecuritiesApp
//
//  Created by Howard on 16/8/4.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^CMRenderRectIndexCallback) (CGRect rect,NSUInteger idxCol, NSUInteger idxRow);

/**
 *  把指定的rect进行分割，按照比例或者平均分割
 */
@interface UIView (FrameSperator)

+ (void)divideRect:(CGRect)rect colCount:(NSUInteger)cols rowCount:(NSUInteger)rows renderCallback:(CMRenderRectIndexCallback)block;

+ (void)divideRect:(CGRect)rect colProportion:(NSString *)colPor rowProportion:(NSString *)rowPor renderCallback:(CMRenderRectIndexCallback)block;

+ (void)divideRectByHorizontal:(CGRect)rect colProportion:(NSString *)colPor renderCallback:(CMRenderRectIndexCallback)block;

+ (void)divideRectByVertical:(CGRect)rect rowProportion:(NSString *)rowPor renderCallback:(CMRenderRectIndexCallback)block;

- (NSArray *)drawSeperatorLineWithRect:(CGRect)rect color:(UIColor *)color width:(CGFloat)width withEdges:(UIRectEdge)edgs;

- (NSArray *)drawSeperatorLine:(UIColor *)color width:(CGFloat)width withEdges:(UIRectEdge)edgs;

- (CAShapeLayer *)drawLineWithColor:(UIColor *)color width:(CGFloat)width forPath:(void (^)(CGMutablePathRef))drawBlock;

- (CAShapeLayer *)drawLineWithColor:(UIColor *)color width:(CGFloat)width startPos:(CGPoint)startPos endPos:(CGPoint)endPos;

@end
