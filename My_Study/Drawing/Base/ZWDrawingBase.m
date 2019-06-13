//
//  ZWDrawingBase.m
//  My_Study
//
//  Created by HZW on 2019/6/4.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "ZWDrawingBase.h"

@implementation ZWDrawingBase

@synthesize isFixed           = _isFixed;
@synthesize drawingTag        = _drawingTag;
@synthesize drawingFrame      = _virtualFrame;
@synthesize drawingDatas      = _drawingDatas;
@synthesize drawingDataSource = _drawingDataSource;
@synthesize drawingDelegate   = _drawingDelegate;

- (instancetype)initWithDrawingFrame:(CGRect)drawFrame
{
    if (self = [super init]) {
        self.lineWidth = 1.;
        self.drawingFrame = drawFrame;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithDrawingFrame:CGRectZero];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%p frame = (%.2f %.2f %.2f %.2f)", self, _virtualFrame.origin.x, _virtualFrame.origin.y, _virtualFrame.size.width, _virtualFrame.size.height];
}


- (void)dealloc
{
#if !__has_feature(objc_arc)
    [_drawingDatas release];
    _drawingDataSource = nil;
    _drawingDelegate = nil;

    [super dealloc];
#endif
}


- (NSArray *)dataForDrawingInRect:(CGRect)rect
{
    if (self.drawingDatas) {
        return self.drawingDatas;
    }else if ([self.drawingDataSource respondsToSelector:@selector(datasForDrawing:inRect:)]){
        return [self.drawingDataSource datasForDrawing:self inRect:rect];
    }
    return nil;
}

#pragma mark  ZWDrawing  delegate
- (void)drawRect:(CGRect)rect withContext:(CGContextRef)context
{
    
}



@end
