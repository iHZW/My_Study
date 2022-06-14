//
//  ZWDrawingBase.h
//  My_Study
//
//  Created by HZW on 2019/6/4.
//  Copyright © 2019 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZWDrawing.h"
#import "ZWDrawingItems.h"

NS_ASSUME_NONNULL_BEGIN


/**
 绘制对象基类
 */
@interface ZWDrawingBase : NSObject<ZWDrawing>

@property (nonatomic, assign) CGFloat lineWidth;


- (instancetype)initWithDrawingFrame:(CGRect)drawFrame;

/**
 获取绘制数据

 @param rect rect
 @return 绘制数据
 */
- (NSArray *)dataForDrawingInRect:(CGRect)rect;

@end

NS_ASSUME_NONNULL_END
