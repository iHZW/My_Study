//
//  PolygonView.m
//  My_Study
//
//  Created by hzw on 2024/10/11.
//  Copyright © 2024 HZW. All rights reserved.
//

#import "PolygonView.h"

@interface PolygonView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableArray<NSValue *> *points;  // 存储多边形的定点
@property (nonatomic, assign) BOOL isDraggingPoint;  // 标记是否正在拖动定点
@property (nonatomic, assign) BOOL isDraggingPolygon;  // 标记是否正在拖动整个多边形
@property (nonatomic, assign) NSInteger draggingPointIndex;  // 当前被拖动的定点索引
@property (nonatomic, strong) UIPanGestureRecognizer *dragPointGesture;  // 定点拖动手势
@property (nonatomic, strong) UILongPressGestureRecognizer *dragPolygonGesture;  // 整体拖动手势
@property (nonatomic, assign) CGPoint lastPolygonDragPoint;  // 上一次整体拖动触点

@end

@implementation PolygonView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        self.opaque = YES;
        self.points = [NSMutableArray arrayWithObjects:
                       [NSValue valueWithCGPoint:CGPointMake(50, 50)],
                       [NSValue valueWithCGPoint:CGPointMake(150, 50)],
                       [NSValue valueWithCGPoint:CGPointMake(150, 150)],
                       [NSValue valueWithCGPoint:CGPointMake(50, 150)], nil];
        
        // 初始化手势
        [self setupGestures];
    }
    return self;
}

- (void)setupGestures {
    // 定点拖动手势
    self.dragPointGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragPoint:)];
    self.dragPointGesture.delegate = self;
    [self addGestureRecognizer:self.dragPointGesture];
    
    // 长按多边形内部后，可以整体拖动
    self.dragPolygonGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragPolygon:)];
    self.dragPolygonGesture.minimumPressDuration = 0.35;
    self.dragPolygonGesture.allowableMovement = CGFLOAT_MAX;
    self.dragPolygonGesture.delegate = self;
    [self addGestureRecognizer:self.dragPolygonGesture];
}

#pragma mark - 定点拖动手势处理

- (void)handleDragPoint:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint touchPoint = [gestureRecognizer locationInView:self];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        for (int i = 0; i < self.points.count; i++) {
            CGPoint point = [self.points[i] CGPointValue];
            CGFloat distance = hypot(touchPoint.x - point.x, touchPoint.y - point.y);
            
            if (distance < 20) {
                self.isDraggingPoint = YES;
                self.draggingPointIndex = i;
                break;
            }
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged && self.isDraggingPoint) {
        self.points[self.draggingPointIndex] = [NSValue valueWithCGPoint:touchPoint];
        [self setNeedsDisplay]; // 重绘视图
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||
               gestureRecognizer.state == UIGestureRecognizerStateCancelled ||
               gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        self.isDraggingPoint = NO;
        [self setNeedsDisplay]; // 手势结束时确保重绘
    }
}

#pragma mark - 整体拖动手势处理

- (void)handleDragPolygon:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint touchPoint = [gestureRecognizer locationInView:self];

    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.isDraggingPolygon = [self isPointInsidePolygon:touchPoint] && ![self isPointNearVertex:touchPoint];
        self.lastPolygonDragPoint = touchPoint;
        return;
    }

    if (gestureRecognizer.state == UIGestureRecognizerStateChanged && self.isDraggingPolygon) {
        CGPoint offset = CGPointMake(touchPoint.x - self.lastPolygonDragPoint.x,
                                     touchPoint.y - self.lastPolygonDragPoint.y);
        [self movePolygonWithOffset:offset];
        self.lastPolygonDragPoint = touchPoint;
        [self setNeedsDisplay];
        return;
    }

    if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||
        gestureRecognizer.state == UIGestureRecognizerStateCancelled ||
        gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        self.isDraggingPolygon = NO;
    }
}

#pragma mark - 判断触摸点是否在多边形内部
- (BOOL)isPointInsidePolygon:(CGPoint)point {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint firstPoint = [self.points[0] CGPointValue];
    CGPathMoveToPoint(path, NULL, firstPoint.x, firstPoint.y);
    
    for (int i = 1; i < self.points.count; i++) {
        CGPoint nextPoint = [self.points[i] CGPointValue];
        CGPathAddLineToPoint(path, NULL, nextPoint.x, nextPoint.y);
    }
    
    CGPathCloseSubpath(path);
    
    BOOL isInside = CGPathContainsPoint(path, NULL, point, NO);
    
    CGPathRelease(path);
    
    return isInside;
}

- (BOOL)isPointNearVertex:(CGPoint)point {
    for (NSValue *pointValue in self.points) {
        CGPoint vertexPoint = [pointValue CGPointValue];
        CGFloat distance = hypot(point.x - vertexPoint.x, point.y - vertexPoint.y);
        if (distance < 20) {
            return YES;
        }
    }
    return NO;
}

- (void)movePolygonWithOffset:(CGPoint)offset {
    if (CGPointEqualToPoint(offset, CGPointZero)) {
        return;
    }

    for (NSInteger index = 0; index < self.points.count; index++) {
        CGPoint point = [self.points[index] CGPointValue];
        point.x += offset.x;
        point.y += offset.y;
        self.points[index] = [NSValue valueWithCGPoint:point];
    }
}





#pragma mark - 手势代理方法

// 确保手势不能同时识别
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

// 检查是否应该触发整体拖动手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.dragPolygonGesture) {
        CGPoint touchPoint = [gestureRecognizer locationInView:self];
        return [self isPointInsidePolygon:touchPoint] && ![self isPointNearVertex:touchPoint];
    }
    return YES;
}

#pragma mark - 绘制多边形

- (void)drawRect:(CGRect)rect {
    // 用白色重绘背景，避免透明区域透出底层黑色。
    [[UIColor whiteColor] setFill];
    UIRectFill(rect);
    
    if (self.points.count > 1) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:[self.points[0] CGPointValue]];
        
        for (int i = 1; i < self.points.count; i++) {
            [path addLineToPoint:[self.points[i] CGPointValue]];
        }
        
        [path closePath];
        
        [[UIColor blueColor] setStroke];
        path.lineWidth = 2.0;
        [path stroke];
        
        for (int i = 0; i < self.points.count; i++) {
            CGPoint point = [self.points[i] CGPointValue];
            CGRect pointRect = CGRectMake(point.x - 5, point.y - 5, 10, 10);
            UIBezierPath *pointPath = [UIBezierPath bezierPathWithOvalInRect:pointRect];
            [[UIColor redColor] setFill];
            [pointPath fill];
        }
    }
}

@end
