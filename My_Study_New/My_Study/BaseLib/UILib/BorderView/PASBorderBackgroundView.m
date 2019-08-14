//
//  PASBorderBackgroundView.m
//  PASecuritiesApp
//
//  Created by Weirdln on 16/5/30.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "PASBorderBackgroundView.h"
//#import "PASFaceManager.h"

static UIColor *shortLineColor; // 有left inset的线的颜色
static UIColor *longLineColor; // 跟cell宽度一样的线的颜色
static UIColor *separateSpaceColor; // 中间分隔部分颜色

@implementation PASBorderBackgroundView

+ (void)initialize
{
//    shortLineColor = PASFaceColorWithKey(@"p107");
//    longLineColor = PASFaceColorWithKey(@"p108");
//    separateSpaceColor = PASFaceColorWithKey(@"p109");
}

/**
 *  换肤通知处理函数
 *
 *  @param notification 通知参数
 */
- (void)notifyThemeChange:(NSNotification *)notification
{
//    shortLineColor = PASFaceColorWithKey(@"p107");
//    longLineColor = PASFaceColorWithKey(@"p108");
//    separateSpaceColor = PASFaceColorWithKey(@"p109");
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.lineBolder = 0.5;
        self.borderInset = kDefaultBorderInset;
        self.vertiBorderInset = kDefaultBorderInset;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (self.borderOption)
    {
        CGPoint leftPoint, rightPoint, topPoint, bottomPoint;
        UIColor *color = nil;
        
        // 上边
        if (self.borderOption & PASBorderOptionTop || self.borderOption & PASBorderOptionTopNoInset)
        {
            color = shortLineColor;
            // 需要添加lineBolder偏移量
            leftPoint = CGPointMake(self.borderInset.left, self.borderInset.top);
            rightPoint = CGPointMake(CGRectGetMaxX(rect) - self.borderInset.right, self.borderInset.top);
            if (self.borderOption & PASBorderOptionTopNoInset)
            {
                color = longLineColor;
                leftPoint.x = 0;
                rightPoint.x = CGRectGetMaxX(rect);
            }
            [[self class] drawLine:context pt1:leftPoint pt2:rightPoint clr:color width:self.lineBolder];

            // 需要间隔条
            if (self.borderOption & PASBorderOptionHeadSeparateSpace)
            {
                leftPoint.y -= self.borderInset.top / 2; // 需要往上偏移top的一半;
                rightPoint.y -= self.borderInset.top / 2;
                [[self class] drawLine:context pt1:leftPoint pt2:rightPoint clr:separateSpaceColor width:self.borderInset.top];
            }
        }
        
        // 下边
        if (self.borderOption & PASBorderOptionBottom || self.borderOption & PASBorderOptionBottomNoInset)
        {
            color = shortLineColor;
            leftPoint = CGPointMake(self.borderInset.left, CGRectGetMaxY(rect) - self.borderInset.bottom);
            rightPoint = CGPointMake(CGRectGetMaxX(rect) - self.borderInset.right, CGRectGetMaxY(rect) - self.borderInset.bottom);
            if (self.borderOption & PASBorderOptionBottomNoInset)
            {
                color = longLineColor;
                leftPoint.x = 0;
                rightPoint.x = CGRectGetMaxX(rect);
            }
            [[self class] drawLine:context pt1:leftPoint pt2:rightPoint clr:color width:self.lineBolder];

            // 需要间隔条
            if (self.borderOption & PASBorderOptionTrailSeparateSpace)
            {
                leftPoint.y += self.borderInset.top / 2; // 需要往下偏移top的一半;
                rightPoint.y += self.borderInset.top / 2;
                [[self class] drawLine:context pt1:leftPoint pt2:rightPoint clr:separateSpaceColor width:self.borderInset.bottom];
            }
        }
       
        // 左边
        if (self.borderOption & PASBorderOptionLeft || self.borderOption & PASBorderOptionLeftNoInset)
        {
            color = shortLineColor;
            topPoint = CGPointMake(self.vertiBorderInset.left, self.vertiBorderInset.top);
            bottomPoint = CGPointMake(self.vertiBorderInset.left, CGRectGetMaxY(rect) - self.vertiBorderInset.bottom);
            if (self.borderOption & PASBorderOptionLeftNoInset)
            {
                color = longLineColor;
                topPoint.y = 0;
                bottomPoint.y = CGRectGetMaxY(rect);
            }
            [[self class] drawLine:context pt1:topPoint pt2:bottomPoint clr:color width:self.lineBolder];

            // 需要间隔条
            if (self.borderOption & PASBorderOptionHeadSeparateSpace)
            {
                topPoint.x -= self.vertiBorderInset.left / 2; // 需要往左偏移left的一半
                bottomPoint.x -= self.vertiBorderInset.left / 2;
                [[self class] drawLine:context pt1:topPoint pt2:bottomPoint clr:separateSpaceColor width:self.vertiBorderInset.left];
            }
        }
        
        // 右边
        if (self.borderOption & PASBorderOptionRight || self.borderOption & PASBorderOptionRightNoInset)
        {
            color = shortLineColor;
            topPoint = CGPointMake(CGRectGetMaxX(rect) - self.vertiBorderInset.right, self.vertiBorderInset.top);
            bottomPoint = CGPointMake(CGRectGetMaxX(rect) - self.vertiBorderInset.right, CGRectGetMaxY(rect) - self.vertiBorderInset.bottom);
            if (self.borderOption & PASBorderOptionRightNoInset)
            {
                color = longLineColor;
                topPoint.y = 0;
                bottomPoint.y = CGRectGetMaxY(rect);
            }
            [[self class] drawLine:context pt1:topPoint pt2:bottomPoint clr:color width:self.lineBolder];

            // 需要间隔条
            if (self.borderOption & PASBorderOptionTrailSeparateSpace)
            {
                topPoint.x += self.vertiBorderInset.left / 2; // 需要往右偏移left的一半
                bottomPoint.x += self.vertiBorderInset.left / 2;
                [[self class] drawLine:context pt1:topPoint pt2:bottomPoint clr:separateSpaceColor width:self.vertiBorderInset.right];
            }
        }
    }
}

+ (void)drawLine:(CGContextRef)gc pt1:(CGPoint)pt1 pt2:(CGPoint)pt2 clr:(UIColor *)clr width:(float)width
{
    CGContextMoveToPoint(gc, pt1.x, pt1.y);
    CGContextAddLineToPoint(gc, pt2.x, pt2.y);
    CGContextSetStrokeColorWithColor(gc, clr.CGColor);
    CGContextSetLineWidth(gc, width);
    CGContextStrokePath(gc);
}

#pragma mark - 色值
- (void)setShortColor:(UIColor *)shortColor
{
    shortLineColor = shortColor;
}

- (void)setLongColor:(UIColor *)longColor
{
    longLineColor = longColor;
}

- (void)setSeparateColor:(UIColor *)separateColor
{
    separateSpaceColor = separateColor;
}

@end
