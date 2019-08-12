//
//  ZWDrawing.h
//  My_Study
//
//  Created by HZW on 2019/6/4.
//  Copyright © 2019 HZW. All rights reserved.
//


#import "DZHDrawingDefine.h"

@protocol ZWDrawingDataSource, ZWDrawingDelegate;

@protocol ZWDrawing <NSObject>

/**< 绘制区域,默认是相对坐标,  isFixed为YES, 则为绝对坐标, 如果为CGRectZero则不进行绘制处理 */
@property (nonatomic, assign) CGRect drawingFrame;

/**< 控制drawingFrame是相对坐标还是绝对坐标, 相对坐标是相对父类容器而言的坐标, 绝对坐标是相对根容器而言的坐标  */
@property (nonatomic, assign) BOOL isFixed;

/**< 绘制对象标记 */
@property (nonatomic, assign) NSInteger drawingTag;

/**< 绘制数据, 如果存在则不调用数据进行数据获取 */
@property (nonatomic, strong) NSArray *drawingDatas;

/**< 绘制数据源 */
@property (nonatomic, weak) id<ZWDrawingDataSource> drawingDataSource;


/**< 委托 绘制前置 后置 处理 */
@property (nonatomic, weak) id<ZWDrawingDelegate> drawingDelegate;


/**
 绘制方法

 @param rect 绘制区域
 @param context CoreGraphics上下文
 */
- (void)drawRect:(CGRect)rect withContext:(CGContextRef)context;


@end




@protocol ZWDrawingDataSource <NSObject>


/**
 获取绘制数据

 @param drawing 绘制组件
 @param rect 绘制区域
 @return 绘制数据
 */
- (NSArray *)datasForDrawing:(id<ZWDrawing>)drawing inRect:(CGRect)rect;

@end




@protocol ZWDrawingDelegate <NSObject>

/**
 绘制处理

 @param drawing 绘制组件
 @param rect 绘制区域
 */
- (void)prepareDrawing:(id<ZWDrawing>)drawing inRect:(CGRect)rect;





/**
 绘制后处理

 @param drawing 绘制组件
 @param rect 绘制区域
 */
- (void)completeDrawing:(id<ZWDrawing>)drawing inRect:(CGRect)rect;

@end
