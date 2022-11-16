//
//  HtmlUtilLabe.h
//  My_Study
//
//  Created by hzw on 2022/11/16.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HtmlHeader.h"
#import "HtmlParser.h"

NS_ASSUME_NONNULL_BEGIN

// （显示的文案， href 的值）
typedef void(^HtmlTagClickHandler)(NSString *_Nullable,NSString *_Nonnull);

@interface HtmlUtilLabel : UILabel

@property (nonatomic, strong,readonly) HtmlParser *htmlParser;

@property(nonatomic, assign) double baselineoffset;
// <a>标签点击跳转处理
@property (nonatomic, copy) HtmlTagClickHandler htmlTagClickHandler;

@property (nonatomic, copy) NSString *htmlString;

- (void)setHtmlString:(NSString *)htmlString;

- (void)setHtmlString:(NSString *)htmlString takeUntil:(nullable RACSignal *)signal;

@end

NS_ASSUME_NONNULL_END
