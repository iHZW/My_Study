//
//  HtmlParser.m
//  My_Study
//
//  Created by hzw on 2022/11/16.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "HtmlParser.h"
#import "HtmlComponent.h"
#import "HtmlImgAttachment.h"
#import "SDImageCache.h"
#import "SDWebImageDownloader.h"
#import "UIColor+Extensions.h"

@interface HtmlParser ()

@property (nonatomic, copy, readwrite) NSString *text;

@property (nonatomic, copy, readwrite) NSString *plainText;

@property (nonatomic, strong, readwrite) NSMutableArray *_textComponents;

@property (nonatomic, assign) NSInteger currentSelectedButtonComponentIndex;

@property (nonatomic, strong) RACBehaviorSubject *subject;

@end

@implementation HtmlParser

- (void)dealloc {
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 只能是长度为1的字符串。 和 textattachment 占据的长度一样
        self.imgReplacement                      = @" ";
        self.paragraphReplacement                = @"";
        self.lineBreakMode                       = NSLineBreakByTruncatingTail;
        self.currentSelectedButtonComponentIndex = NSNotFound;
    }
    return self;
}

- (RACSubject *)parseHtmlString:(NSString *)htmlString {
    if (!htmlString) {
        htmlString = @"";
    }
    NSMutableString *newText = [NSMutableString stringWithString:htmlString];
    [newText replaceOccurrencesOfString:@"<br\\s*/?>" withString:@"\n" options:NSRegularExpressionSearch range:NSMakeRange(0, newText.length)];
    [newText replaceOccurrencesOfString:@"&nbsp;" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, newText.length)];

    self.text = newText;
    [self extractTextStyle:self.text];
    RACSubject *subject = [self build];
    return subject;
}

- (CGSize)calcSize:(NSString *)htmlString maxSize:(CGSize)maxSize {
    if (!htmlString) {
        htmlString = @"";
    }
    NSMutableString *newText = [NSMutableString stringWithString:htmlString];
    [newText replaceOccurrencesOfString:@"<br\\s*/?>" withString:@"\n" options:NSRegularExpressionSearch range:NSMakeRange(0, newText.length)];
    [newText replaceOccurrencesOfString:@"&nbsp;" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, newText.length)];

    self.text = newText;
    [self extractTextStyle:self.text];
    NSAttributedString *attrString = [self buildNS];

    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    if (self.numberOfLines == 1) {
        options = 0;
    }

    CGSize size = [attrString boundingRectWithSize:maxSize
                                           options:options
                                           context:nil]
                      .size;
    return size;
}

#pragma mark -

+ (NSArray *)supportedTags {
    return @[
        @"img",
        @"font",
        @"a",
        @"p",
        @"i",
        @"b",
        @"u",
        @"uu",
        @"strong",
    ];
}

+ (BOOL)isSupportedTag:(NSString *)tag {
    return [[self supportedTags] containsObject:tag];
}

+ (BOOL)isStartWithSupportedTag:(NSString *)text {
    NSString *lowerText = [text lowercaseString];
    for (NSString *tag in self.supportedTags) {
        // tag 开始, 带属性的例如 <a href=''/>
        NSString *tagStart = [NSString stringWithFormat:@"<%@ ", tag];
        // 不带属性的标签例如 <p>
        NSString *tagStartNoAttr = [NSString stringWithFormat:@"<%@>", tag];
        NSString *tagEnd         = [NSString stringWithFormat:@"</%@>", tag];
        if ([lowerText hasPrefix:tagStart] ||
            [lowerText hasPrefix:tagStartNoAttr] ||
            [lowerText hasPrefix:tagEnd]) {
            return YES;
        }
    }
    return NO;
}

- (void)extractTextStyle:(NSString *)data {
    NSScanner *scanner = nil;
    NSString *text     = nil;
    NSString *tag      = nil;

    NSMutableArray *components = [NSMutableArray array];

    int last_position = 0;
    scanner           = [NSScanner scannerWithString:data];
    while (![scanner isAtEnd]) {
        [scanner scanUpToString:@"<" intoString:NULL];
        [scanner scanUpToString:@">" intoString:&text];

        NSString *delimiter = [NSString stringWithFormat:@"%@>", text];
        if ([self.class isStartWithSupportedTag:delimiter]) {
            NSInteger position = [data rangeOfString:delimiter].location;
            if (position != NSNotFound) {
                if ([delimiter rangeOfString:@"<p"].location == 0) {
                    data = [data stringByReplacingOccurrencesOfString:delimiter withString:self.paragraphReplacement options:NSCaseInsensitiveSearch range:NSMakeRange(last_position, position + delimiter.length - last_position)];
                } else if ([delimiter rangeOfString:@"<img"].location == 0) {
                    data = [data stringByReplacingOccurrencesOfString:delimiter withString:self.imgReplacement options:NSCaseInsensitiveSearch range:NSMakeRange(last_position, position + delimiter.length - last_position)];
                } else {
                    data = [data stringByReplacingOccurrencesOfString:delimiter withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(last_position, position + delimiter.length - last_position)];
                }

                data = [data stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
                data = [data stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
            }

            if ([text rangeOfString:@"</"].location == 0) {
                // end of tag
                tag = [text substringFromIndex:2];
                if (position != NSNotFound) {
                    for (int i = (int)[components count] - 1; i >= 0; i--) {
                        HtmlComponent *component = [components objectAtIndex:i];
                        if (component.text == nil && [component.tagLabel isEqualToString:tag]) {
                            NSString *text2 = [data substringWithRange:NSMakeRange(component.position, position - component.position)];
                            component.text  = text2;
                            break;
                        }
                    }
                }

            } else {
                if (position != NSNotFound) {
                    // start of tag
                    NSArray *textComponents = [[text substringFromIndex:1] componentsSeparatedByString:@" "];
                    tag                     = [textComponents objectAtIndex:0];

                    // HJLog(@"start of tag: %@", tag);
                    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
                    for (int i = 1; i < [textComponents count]; i++) {
                        NSArray *pair = [[textComponents objectAtIndex:i] componentsSeparatedByString:@"="];
                        if ([pair count] >= 2) {
                            NSString *value = [[pair subarrayWithRange:NSMakeRange(1, [pair count] - 1)] componentsJoinedByString:@"="];
                            if ([value hasPrefix:@"\""]) {
                                value = [value substringFromIndex:1];
                            }

                            if ([value hasSuffix:@"\""]) {
                                value = [value substringToIndex:value.length - 1];
                            }
                            [attributes setObject:value forKey:[pair objectAtIndex:0]];
                        }
                    }

                    HtmlComponent *component = [HtmlComponent componentWithString:nil tag:tag attributes:attributes];
                    component.position       = (int)position;

                    if ([tag isEqualToString:@"img"]) {
                        // img 特殊处理结束
                        component.text = self.imgReplacement;
                    }

                    [components addObject:component];
                }
            }

            last_position = (int)position;
        }
    }

    // HJLog(@"%@", components);
    self._textComponents = components;
    self.plainText       = data;
}

#pragma mark -

- (RACSubject *)build {
    NSAttributedString *attrString = [self buildNS];
    RACBehaviorSubject *subject    = [RACBehaviorSubject behaviorSubjectWithDefaultValue:attrString];

    self.subject = subject;
    return subject;
}

- (NSAttributedString *)buildNS {
    if (!self.plainText) {
        return nil;
    }

    NSMutableAttributedString *mutableAttString = [[NSMutableAttributedString alloc] initWithString:self.plainText];
    if (self.font) {
        [mutableAttString addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, self.plainText.length)];
    }

    if (self.textColor) {
        [mutableAttString addAttribute:NSForegroundColorAttributeName value:self.textColor range:NSMakeRange(0, self.plainText.length)];
    }

    for (HtmlComponent *component in self._textComponents) {
        int index                = (int)[self._textComponents indexOfObject:component];
        component.componentIndex = index;
        if ([component.tagLabel isEqualToString:@"i"]) {
            // make font italic
            [self applyItalicStyleToTextNS:mutableAttString atPosition:component.position withLength:(int)[component.text length]];
        } else if ([component.tagLabel isEqualToString:@"b"]) {
            // make font bold
            [self applyBoldStyleToTextNS:mutableAttString atPosition:component.position withLength:(int)[component.text length]];
        } else if ([component.tagLabel isEqualToString:@"a"]) {
            if (self.currentSelectedButtonComponentIndex == index) {
                if (self.selectedLinkAttributes) {
                    [self applyFontAttributesNS:self.selectedLinkAttributes toText:mutableAttString atPosition:component.position withLength:(int)[component.text length]];
                } else {
                    [self applyBoldStyleToTextNS:mutableAttString atPosition:component.position withLength:(int)[component.text length]];
                }
            } else {
                if (self.linkAttributes) {
                    [self applyFontAttributesNS:self.linkAttributes toText:mutableAttString atPosition:component.position withLength:(int)[component.text length]];
                } else {
                    [self applyBoldStyleToTextNS:mutableAttString atPosition:component.position withLength:(int)[component.text length]];
                    [self applySingleUnderlineTextNS:mutableAttString atPosition:component.position withLength:(int)[component.text length]];
                }
            }

            NSString *value = [component.attributes objectForKey:@"href"];
            value           = [value stringByReplacingOccurrencesOfString:@"'" withString:@""];
            [component.attributes setObject:value forKey:@"href"];
        } else if ([component.tagLabel isEqualToString:@"u"] || [component.tagLabel isEqualToString:@"uu"]) {
            // underline
            if ([component.tagLabel isEqualToString:@"u"]) {
                [self applySingleUnderlineTextNS:mutableAttString atPosition:component.position withLength:(int)[component.text length]];
            } else if ([component.tagLabel isEqualToString:@"uu"]) {
                [self applyDoubleUnderlineTextNS:mutableAttString atPosition:component.position withLength:(int)[component.text length]];
            }

            if ([component.attributes objectForKey:@"color"]) {
                NSString *value = [component.attributes objectForKey:@"color"];
                [self applyUnderlineColorNS:value toText:mutableAttString atPosition:component.position withLength:(int)[component.text length]];
            }
        } else if ([component.tagLabel isEqualToString:@"font"]) {
            [self applyFontAttributesNS:component.attributes toText:mutableAttString atPosition:component.position withLength:(int)[component.text length]];
        } else if ([component.tagLabel isEqualToString:@"p"]) {
            [self applyParagraphStyleToTextNS:mutableAttString attributes:component.attributes atPosition:component.position withLength:(int)[component.text length]];
        } else if ([component.tagLabel isEqualToString:@"img"]) {
            [self applyImgNS:mutableAttString attributes:component.attributes atPosition:component.position withLength:(int)[component.text length]];
        }
    }
    return mutableAttString;
}

#pragma mark -
#pragma mark styling

- (void)applyParagraphStyleToTextNS:(NSMutableAttributedString *)text attributes:(NSMutableDictionary *)attributes atPosition:(int)position withLength:(int)length {
    // direction
    NSWritingDirection direction = NSWritingDirectionLeftToRight;
    // leading
    CGFloat firstLineIndent        = 0.0;
    CGFloat headIndent             = 0.0;
    CGFloat tailIndent             = 0.0;
    CGFloat lineHeightMultiple     = 1.0;
    CGFloat maxLineHeight          = 0;
    CGFloat minLineHeight          = 0;
    CGFloat paragraphSpacing       = 0.0;
    CGFloat paragraphSpacingBefore = 0.0;
    int textAlignment              = (int)_textAlignment;
    int lineBreakMode              = (int)_lineBreakMode;
    int lineSpacing                = self.lineSpacing;

    for (int i = 0; i < [[attributes allKeys] count]; i++) {
        NSString *key = [[attributes allKeys] objectAtIndex:i];
        id value      = [attributes objectForKey:key];
        if ([key isEqualToString:@"align"]) {
            if ([value isEqualToString:@"left"]) {
                textAlignment = NSTextAlignmentLeft;
            } else if ([value isEqualToString:@"right"]) {
                textAlignment = NSTextAlignmentRight;
            } else if ([value isEqualToString:@"justify"]) {
                textAlignment = NSTextAlignmentJustified;
            } else if ([value isEqualToString:@"center"]) {
                textAlignment = NSTextAlignmentCenter;
            }
        } else if ([key isEqualToString:@"indent"]) {
            firstLineIndent = [value floatValue];
        } else if ([key isEqualToString:@"linebreakmode"]) {
            if ([value isEqualToString:@"wordwrap"]) {
                lineBreakMode = NSLineBreakByWordWrapping;
            } else if ([value isEqualToString:@"charwrap"]) {
                lineBreakMode = NSLineBreakByCharWrapping;
            } else if ([value isEqualToString:@"clipping"]) {
                lineBreakMode = NSLineBreakByClipping;
            } else if ([value isEqualToString:@"truncatinghead"]) {
                lineBreakMode = NSLineBreakByTruncatingHead;
            } else if ([value isEqualToString:@"truncatingtail"]) {
                lineBreakMode = NSLineBreakByTruncatingTail;
            } else if ([value isEqualToString:@"truncatingmiddle"]) {
                lineBreakMode = NSLineBreakByTruncatingMiddle;
            }
        }
    }

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing              = lineSpacing;        // 行间距
    paragraphStyle.lineHeightMultiple       = lineHeightMultiple; // 行高倍数（1.5倍行高）
    paragraphStyle.firstLineHeadIndent      = firstLineIndent;    // 首行缩进
    paragraphStyle.minimumLineHeight        = minLineHeight;      // 最低行高
    paragraphStyle.maximumLineHeight        = maxLineHeight;      // 最大行高(会影响字体)

    paragraphStyle.alignment          = textAlignment; // 对齐方式
    paragraphStyle.defaultTabInterval = 144;           // 默认Tab 宽度
    paragraphStyle.headIndent         = headIndent;    // 起始 x位置
    paragraphStyle.tailIndent         = tailIndent;    // 结束 x位置（不是右边间距，与inset 不一样）

    paragraphStyle.paragraphSpacing       = paragraphSpacing;       // 段落间距
    paragraphStyle.paragraphSpacingBefore = paragraphSpacingBefore; // 段落头部空白(实测与上边的没差啊？)
    paragraphStyle.lineBreakMode          = lineBreakMode;          // 分割模式

    paragraphStyle.baseWritingDirection = direction;

    [text addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(position, length)];
}

- (void)applySingleUnderlineTextNS:(NSMutableAttributedString *)text atPosition:(int)position withLength:(int)length {
    if (!self.hideUnderLine) {
        [text addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(position, length)];
    }
}

- (void)applyDoubleUnderlineTextNS:(NSMutableAttributedString *)text atPosition:(int)position withLength:(int)length {
    if (!self.hideUnderLine) {
        [text addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleDouble] range:NSMakeRange(position, length)];
    }
}

- (void)applyItalicStyleToTextNS:(NSMutableAttributedString *)text atPosition:(int)position withLength:(int)length {
    UIFont *_font = [UIFont italicSystemFontOfSize:self.font.pointSize];
    [text addAttribute:NSFontAttributeName value:_font range:NSMakeRange(position, length)];
}

- (void)applyFontAttributesNS:(NSDictionary *)attributes toText:(NSMutableAttributedString *)text atPosition:(int)position withLength:(int)length {
    for (NSString *key in attributes) {
        NSString *value = [attributes objectForKey:key];
        value           = [value stringByReplacingOccurrencesOfString:@"'" withString:@""];

        if ([key isEqualToString:@"color"]) {
            [self applyColorNS:value toText:text atPosition:position withLength:length];
        } else if ([key isEqualToString:@"stroke"]) {
            [text addAttribute:NSStrokeWidthAttributeName value:[NSNumber numberWithFloat:[[attributes objectForKey:@"stroke"] floatValue]] range:NSMakeRange(position, length)];
        } else if ([key isEqualToString:@"kern"]) {
            [text addAttribute:NSKernAttributeName value:[NSNumber numberWithFloat:[[attributes objectForKey:@"kern"] floatValue]] range:NSMakeRange(position, length)];
        } else if ([key isEqualToString:@"underline"]) {
            int numberOfLines = [value intValue];
            if (numberOfLines == 1) {
                [self applySingleUnderlineTextNS:text atPosition:position withLength:length];
            } else if (numberOfLines == 2) {
                [self applyDoubleUnderlineTextNS:text atPosition:position withLength:length];
            }
        } else if ([key isEqualToString:@"style"]) {
            if ([value isEqualToString:@"bold"]) {
                [self applyBoldStyleToTextNS:text atPosition:position withLength:length];
            } else if ([value isEqualToString:@"italic"]) {
                [self applyItalicStyleToTextNS:text atPosition:position withLength:length];
            }
        }
    }

    if ([attributes objectForKey:@"baselineoffset"]) {
        double offset = [[attributes objectForKey:@"baselineoffset"] doubleValue];
        [text addAttribute:NSBaselineOffsetAttributeName value:@(offset) range:NSMakeRange(position, length)];
        //        [text addAttribute:NSBaselineOffsetAttributeName value:@(1.08) range:NSMakeRange(position, length)];
    } else {
        [text addAttribute:NSBaselineOffsetAttributeName value:@(self.baselineoffset) range:NSMakeRange(position, length)];
    }

    UIFont *_font = nil;
    if ([attributes objectForKey:@"face"] && [attributes objectForKey:@"size"]) {
        NSString *fontName = [attributes objectForKey:@"face"];
        fontName           = [fontName stringByReplacingOccurrencesOfString:@"'" withString:@""];
        _font              = [UIFont fontWithName:fontName size:[[attributes objectForKey:@"size"] intValue]];
    } else if ([attributes objectForKey:@"face"] && ![attributes objectForKey:@"size"]) {
        NSString *fontName = [attributes objectForKey:@"face"];
        fontName           = [fontName stringByReplacingOccurrencesOfString:@"'" withString:@""];
        _font              = [UIFont fontWithName:fontName size:self.font.pointSize];
    } else if (![attributes objectForKey:@"face"] && [attributes objectForKey:@"size"]) {
        _font = [UIFont fontWithName:[self.font fontName] size:[[attributes objectForKey:@"size"] intValue]];
    }
    if (_font) {
        [text addAttribute:NSFontAttributeName value:_font range:NSMakeRange(position, length)];
    }
}

- (void)applyBoldStyleToTextNS:(NSMutableAttributedString *)text atPosition:(int)position withLength:(int)length {
    UIFont *_font = [UIFont boldSystemFontOfSize:self.font.pointSize];
    [text addAttribute:NSFontAttributeName value:_font range:NSMakeRange(position, length)];
}

- (void)applyColorNS:(NSString *)value toText:(NSMutableAttributedString *)text atPosition:(int)position withLength:(int)length {
    // 优先使用topLevelTextColor
    UIColor *textColor = self.topLevelTextColor;
    if (!textColor) {
        if ([value rangeOfString:@"#"].location == 0) {
            textColor = [UIColor colorFromHexString:value];
        } else {
            value        = [value stringByAppendingString:@"Color"];
            SEL colorSel = NSSelectorFromString(value);
            if ([UIColor respondsToSelector:colorSel]) {
                textColor = [UIColor performSelector:colorSel];
            }
        }
    }
    if (textColor) {
        [text addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(position, length)];
    }
}

- (void)applyUnderlineColorNS:(NSString *)value toText:(NSMutableAttributedString *)text atPosition:(int)position withLength:(int)length {
    value = [value stringByReplacingOccurrencesOfString:@"'" withString:@""];
    if ([value rangeOfString:@"#"].location == 0) {
        value          = [value stringByReplacingOccurrencesOfString:@"#" withString:@"0x"];
        UIColor *color = [UIColor colorFromHexString:value];
        [text addAttribute:NSUnderlineColorAttributeName value:color range:NSMakeRange(position, length)];
    } else {
        value           = [value stringByAppendingString:@"Color"];
        SEL colorSel    = NSSelectorFromString(value);
        UIColor *_color = nil;
        if ([UIColor respondsToSelector:colorSel]) {
            _color = [UIColor performSelector:colorSel];
            [text addAttribute:NSUnderlineColorAttributeName value:_color range:NSMakeRange(position, length)];
        }
    }
}

- (void)applyImgNS:(NSMutableAttributedString *)text attributes:(NSMutableDictionary *)attributes atPosition:(int)position withLength:(int)length {
    NSString *src = [attributes objectForKey:@"src"];
    if (src.length > 0) {
        src = [src stringByReplacingOccurrencesOfString:@"\"" withString:@""];

        UIImage *localImage = [self imageForSrc:src];
        if (localImage == nil) {
            [self downloadImage:src];
        } else {
            CGFloat width  = [[attributes objectForKey:@"width"] floatValue];
            CGFloat height = [[attributes objectForKey:@"height"] floatValue];

            // 图片偏移量 ， y >0 往上移， y < 0 往下移
            CGFloat x = [[attributes objectForKey:@"x"] floatValue];
            CGFloat y = [[attributes objectForKey:@"y"] floatValue];

            HtmlImgAttachment *attach   = [[HtmlImgAttachment alloc] init];
            attach.image                = localImage;
            attach.imgOrigin            = CGPointMake(x, y);
            attach.imgSize              = CGSizeMake(width, height);
            NSAttributedString *attrStr = [NSAttributedString attributedStringWithAttachment:attach];
            if (position + length <= text.length) {
                [text replaceCharactersInRange:NSMakeRange(position, length) withAttributedString:attrStr];
            }
        }
    }
}

- (void)downloadImage:(NSString *)src {
    NSURL *url = [NSURL URLWithString:src];
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url completed:^(UIImage *_Nullable image, NSData *_Nullable data, NSError *_Nullable error, BOOL finished) {
        if (!error && image) {
            [[SDImageCache sharedImageCache] storeImage:image forKey:src completion:^{
                NSAttributedString *attrString = [self buildNS];
                [self.subject sendNext:attrString];
            }];
        }
    }];
}

- (UIImage *)imageForSrc:(NSString *)src {
    UIImage *image = [[SDImageCache sharedImageCache] imageFromCacheForKey:src];
    return image;
}

@end
