//
//  PASUIDefine.h
//  PASecuritiesApp
//
//  Created by vince on 16/4/14.
//  Copyright © 2016年 PAS. All rights reserved.
//

#ifndef PASUIDefine_h
#define PASUIDefine_h
#import "UIColor+Extensions.h"

# pragma mark ---------size
#define kContentSideHorizSpace 15
#define kContentSideVertiSpace 10

# pragma mark ---------color

// 通用背景色
#define kBackGroudColor UIColorFromRGB(0xf0f0f0)

#define kLogoutBtnColor UIColorFromRGB(0xaf292e)

// 红涨绿跌平黑
#define POSITIVE_COLOR   PAS_COLOR_RED
#define NEGATIVE_COLOR   PAS_COLOR_GREEN
#define EQUAL_COLOR      UIColorFromRGB(0x333333)
#define STOCK_COLOR(origin, target) target > -origin && target < origin ? EQUAL_COLOR : origin < target ? POSITIVE_COLOR : NEGATIVE_COLOR
#define POSI_OR_NEGA_COLOR(value) STOCK_COLOR(kCompareFloatZero, value)

// 平安辅助色
#define PAS_COLOR_ORANGE UIColorFromRGB(0xff8000)
#define PAS_COLOR_BLUE   UIColorFromRGB(0x0099ff)
#define PAS_COLOR_GREEN  UIColorFromRGB(0x2978ff)
#define PAS_COLOR_RED    UIColorFromRGB(0xe2233e)
#define PAS_COLOR_WHITE  UIColorFromRGB(0xffffff)

// 字体颜色
#define PAS_TEXT_COLOR_TITLE      UIColorFromRGB(0x111111)// 标题
#define PAS_TEXT_COLOR_CONTENT    UIColorFromRGB(0x333333)// 常规正文
#define PAS_TEXT_COLOR_SUBCONTENT UIColorFromRGB(0x666666)// 次要文字
#define PAS_TEXT_COLOR_AUXCONTENT UIColorFromRGB(0x999999)// 辅助说明文字
#define PAS_TEXT_COLOR_BLUE       UIColorFromRGB(0x0066cc)// 蓝色着重文字颜色

#define PAS_SELECT_COLOR_CELL  UIColorFromRGB(0xf0f0f0) //选中cell颜色

/**
 *  table 相关色值字体定义
 */
#define TABLE_TITLE_COLOR UIColorFromRGB(0x666666)//标题
#define TABLE_CONTENT_COLOR UIColorFromRGB(0x111111)//内容
#define TABLE_TIPS_COLOR UIColorFromRGB(0xcccccc)//暗提示

#define TABLE_SHORT_LINE_COLOR UIColorFromRGB(0xcccccc)
#define TABLE_LONG_LINE_COLOR UIColorFromRGB(0xbbbbbb)

// 通用颜色

#define BACKGROUD_COLOR UIColorFromRGB(0xf0f0f0)
#define MARET_BACKGROUD_COLOR UIColorFromRGB(0x101419)

#define kCONTENT_SPACE 12 // 内容中间间隙
#define kBORDER_SPACE 15 // 坐右边边距

#endif /* PASUIDefine_h */
