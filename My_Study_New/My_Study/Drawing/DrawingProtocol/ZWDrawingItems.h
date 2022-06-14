//
//  ZWDrawingItems.h
//  My_Study
//
//  Created by HZW on 2019/6/5.
//  Copyright © 2019 HZW. All rights reserved.
//

//#ifndef ZWDrawingItems_h
//#define ZWDrawingItems_h
//
//
//#endif /* ZWDrawingItems_h */

/**
 * 字符串绘制项
 */
@protocol DZHTextItem <NSObject>

/**字符串内容*/
@property (nonatomic, copy) NSString *text;

/**字符串绘制区域*/
@property (nonatomic, assign) CGRect textRect;

/**字符串颜色*/
@property (nonatomic, retain) UIColor *textColor;

/**字符串字体*/
@property (nonatomic, retain) UIFont *textFont;

/**文本对齐方式*/
@property (nonatomic, assign) NSTextAlignment alignment;

@end
