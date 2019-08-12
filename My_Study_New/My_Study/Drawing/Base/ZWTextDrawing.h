//
//  ZWTextDrawing.h
//  My_Study
//
//  Created by HZW on 2019/6/4.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "ZWDrawingBase.h"

NS_ASSUME_NONNULL_BEGIN


/**
 文本绘制组件,  用于绘制单个文本
 */
@interface ZWTextDrawing : ZWDrawingBase

@property (nonatomic, strong) UIFont *textFont;

@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, copy) NSString *text;

@property (nonatomic, assign) NSTextAlignment alignment;

@end


/**
 多文本绘制组件
 */
@interface ZWTextsDrawing : ZWDrawingBase



@end



NS_ASSUME_NONNULL_END
