//
//  HtmlParser.h
//  My_Study
//
//  Created by hzw on 2022/11/16.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HtmlHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface HtmlParser : NSObject

@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;
@property (nonatomic, retain) UIColor *topLevelTextColor; // 最高优先级显示的字体颜色
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, retain) NSDictionary *linkAttributes;
@property (nonatomic, retain) NSDictionary *selectedLinkAttributes;
@property (nonatomic, copy) NSString *paragraphReplacement;
@property (nonatomic, copy) NSString *imgReplacement;
@property (nonatomic, assign) BOOL hideUnderLine;
@property (nonatomic, strong, readonly) NSMutableArray *_textComponents;
@property (nonatomic, assign) NSInteger numberOfLines;
@property (nonatomic, assign) double baselineoffset;

@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, copy, readonly) NSString *plainText;

- (RACSubject *)parseHtmlString:(NSString *)htmlString;
// 计算文本大小, 先不考虑图片
- (CGSize)calcSize:(NSString *)htmlString maxSize:(CGSize)maxSize;

@end

NS_ASSUME_NONNULL_END
