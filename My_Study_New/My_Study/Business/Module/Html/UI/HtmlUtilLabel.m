//
//  HtmlUtilLabe.m
//  My_Study
//
//  Created by hzw on 2022/11/16.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "HtmlUtilLabel.h"
#import "HtmlComponent.h"
// #import "CommonWebViewController.h"

@interface HtmlUtilLabel ()

@property (nonatomic, strong, readwrite) HtmlParser *htmlParser;

@property (nonatomic, strong) NSString *router;

@property (nonatomic, assign) NSInteger numberOfRouters;

@property (nonatomic, strong) NSTextContainer *textContainer;

@property (nonatomic, strong) NSTextStorage *textStorage;

@property (nonatomic, strong) NSLayoutManager *layoutManager;

@end

@implementation HtmlUtilLabel

- (void)dealloc {
}

- (HtmlParser *)htmlParser {
    if (!_htmlParser) {
        _htmlParser                = [[HtmlParser alloc] init];
        _htmlParser.font           = self.font;
        _htmlParser.linkAttributes = @{@"color": @"#4F7AFD"};
    }
    return _htmlParser;
}

- (void)setHtmlString:(NSString *)htmlString {
    [self setHtmlString:htmlString takeUntil:nil];
}

- (void)setHtmlString:(NSString *)htmlString takeUntil:(RACSignal *)signal {
    _htmlString = htmlString;
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnLabel:)]];

    @weakify(self)
        RACSignal *parseSignal = [self.htmlParser parseHtmlString:htmlString];
    if (signal) {
        parseSignal = [parseSignal takeUntil:signal];
    }

    [parseSignal subscribeNext:^(id _Nullable x) {
        @strongify(self)
            NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        NSTextContainer *textContainer     = [[NSTextContainer alloc] initWithSize:CGSizeZero];
        NSTextStorage *textStorage         = [[NSTextStorage alloc] initWithAttributedString:x];

        // Configure layoutManager and textStorage
        [layoutManager addTextContainer:textContainer];
        [textStorage addLayoutManager:layoutManager];

        // Configure textContainer
        textContainer.lineFragmentPadding  = 0.0;
        textContainer.lineBreakMode        = self.lineBreakMode;
        textContainer.maximumNumberOfLines = self.numberOfLines;

        self.layoutManager = layoutManager;
        self.textContainer = textContainer;
        self.textStorage   = textStorage;

        self.attributedText = textStorage;
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    if (self.numberOfLines == 1) {
        options = 0;
    }

    // CGRect textBoundingBox = [self.layoutManager usedRectForTextContainer:self.textContainer];
    CGSize size = [self.attributedText boundingRectWithSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)
                                                    options:options
                                                    context:nil].size;
    self.textContainer.size = CGSizeMake(size.width, size.height + 10);
}

- (void)handleTapOnLabel:(UITapGestureRecognizer *)tapGesture {
    CGPoint locationOfTouchInLabel = [tapGesture locationInView:tapGesture.view];
    NSInteger glythIndex           = [self.layoutManager glyphIndexForPoint:locationOfTouchInLabel inTextContainer:self.textContainer];
    // 获取改glyph对应的rect
    CGRect glythRect = [self.layoutManager boundingRectForGlyphRange:NSMakeRange(glythIndex, 1) inTextContainer:self.textContainer];
    // 最终判断该字形的显示范围是否包括点击的location
    if (CGRectContainsPoint(glythRect, locationOfTouchInLabel)) {
        NSInteger characterIndex = [self.layoutManager characterIndexForGlyphAtIndex:glythIndex];

        NSLog(@"点击: %ld", characterIndex);
        [self.htmlParser._textComponents enumerateObjectsUsingBlock:^(HtmlComponent *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            NSRange range = NSMakeRange(obj.position, obj.text.length);
            if (NSLocationInRange(characterIndex, range)) {
                NSString *router = [obj.attributes objectForKey:@"href"];
                NSString *text   = obj.text;
                if ([router isKindOfClass:[NSString class]]) {
                    router = [[router stringByReplacingOccurrencesOfString:@"'" withString:@""] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    NSLog(@"%@", router);
                    if ([router hasPrefix:@"javascript"]) {
                        /* 不作处理 */
                    } else {
                        if (self.htmlTagClickHandler) {
                            self.htmlTagClickHandler(text, router);
                        } else {
                            if ([router hasPrefix:@"http://"] ||
                                [router hasPrefix:@"https://"]) {
                                /* 判断是webUrl 直接跳转webview---后边补充 */

                                //                                CommonWebViewController *ctrl = [[CommonWebViewController alloc] init];
                                //                                ctrl.url = __String_Not_Nil(router);
                                //                                UIViewController *topViewController = [UIApplication topOfRootViewController];
                                //                                [topViewController.navigationController pushViewController:ctrl animated:NO];

                            } else {
                                /** 路由跳转---后边补充  */
                            }
                        }
                    }

                    *stop = YES;
                }
            }
        }];
    }
}

#pragma mark - Override

- (void)drawTextInRect:(CGRect)rect {
    NSRange range = NSMakeRange(0, self.textStorage.length);
    [self.layoutManager drawBackgroundForGlyphRange:range atPoint:CGPointMake(0.0, 0.0)];
    [self.layoutManager drawGlyphsForGlyphRange:range atPoint:CGPointMake(0.0, 0.0)];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    [super setLineBreakMode:lineBreakMode];
    self.textContainer.lineBreakMode = lineBreakMode;
    self.htmlParser.lineBreakMode    = lineBreakMode;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    self.htmlParser.textAlignment = textAlignment;
}

- (void)setTextColor:(UIColor *)textColor {
    [super setTextColor:textColor];
    self.htmlParser.textColor = textColor;
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    self.htmlParser.font = font;
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    [super setNumberOfLines:numberOfLines];
    self.textContainer.maximumNumberOfLines = numberOfLines;
    self.htmlParser.numberOfLines           = numberOfLines;
}

- (void)setBaselineoffset:(double)baselineoffset {
    _baselineoffset                = baselineoffset;
    self.htmlParser.baselineoffset = baselineoffset;
}

@end
