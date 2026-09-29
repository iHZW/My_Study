//
//  MMScrollLabelView.m
//
//  Created by tingxins on 2/23/16.
//  Copyright © 2016 tingxins. All rights reserved.
//  如果在使用 MMScrollLabelView 的过程中出现bug，请及时联系，我会尽快进行修复。如果有更好的点子，直接 Open an issue 或者 submit a pr。
/**
 Blog : https://tingxins.com
 简书 ：http://www.jianshu.com/u/5141561e4d59
 GitHub : https://github.com/tingxins
 Weibo : http://weibo.com/tingxins
 Twitter : http://twitter.com/tingxins
 */

#define MMScrollLabelFont [UIFont systemFontOfSize:14]
#import "MMScrollLabelView.h"
#import <CoreText/CoreText.h>

static const NSInteger MMScrollDefaultTimeInterval = 2.0;//滚动默认时间

typedef NS_ENUM(NSInteger, MMScrollLabelType) {
    MMScrollLabelTypeUp = 0,
    MMScrollLabelTypeDown
};

#pragma mark - NSTimer+MMTimerTarget

@interface NSTimer (MMTimerTarget)

+ (NSTimer *)mm_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeat:(BOOL)yesOrNo block:(void(^)(NSTimer *timer))block;

@end


@implementation NSTimer (MMTimerTarget)

+ (NSTimer *)mm_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeat:(BOOL)yesOrNo block:(void (^)(NSTimer *timer))block{
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(startTimer:) userInfo:[block copy] repeats:yesOrNo];
}

+ (void)startTimer:(NSTimer *)timer {
    void (^block)(NSTimer *timer) = timer.userInfo;
    if (block) {
        block(timer);
    }
}

@end

#pragma mark - UILabel+MMLabel


@interface MMScrollLabel : UILabel

@property (assign, nonatomic) UIEdgeInsets contentInset;

@end

@implementation MMScrollLabel

- (instancetype)init {
    if (self = [super init]) {
        _contentInset = UIEdgeInsetsZero;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _contentInset = UIEdgeInsetsZero;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, _contentInset)];
}

@end

@interface MMScrollLabel (MMLabel)

+ (instancetype)mm_label;

@end

@implementation MMScrollLabel (MMLabel)

+ (instancetype)mm_label {
    MMScrollLabel *label = [[MMScrollLabel alloc]init];
    label.numberOfLines = 0;
    label.font = MMScrollLabelFont;
    label.textColor = [UIColor whiteColor];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

@end

#pragma mark - MMScrollLabelView

@interface MMScrollLabelView ()

@property (assign, nonatomic) UIViewAnimationOptions options;

@property (weak, nonatomic) MMScrollLabel *upLabel;

@property (weak, nonatomic) MMScrollLabel *downLabel;
//定时器
@property (strong, nonatomic) NSTimer *scrollTimer;
//文本行分割数组
@property (strong, nonatomic) NSArray *scrollArray;

@property (strong, nonatomic) NSArray *scrollTexts;
//当前滚动行
@property (assign, nonatomic) NSInteger currentSentence;
//是否第一次开始计时
@property (assign, nonatomic, getter=isFirstTime) BOOL firstTime;
//传入参数是否为数组
@property (assign, nonatomic) BOOL isArray;

@end

@implementation MMScrollLabelView

@synthesize scrollSpace = _scrollSpace;

@synthesize font = _font;

#pragma mark - Preference Methods

- (void)setSomePreference {
    /** Default preference. */
    self.backgroundColor = [UIColor blackColor];
    self.scrollEnabled = NO;
}

- (void)setSomeSubviews {
    MMScrollLabel *upLabel = [MMScrollLabel mm_label];
    self.upLabel = upLabel;
    [self addSubview:upLabel];
    
    MMScrollLabel *downLabel = [MMScrollLabel mm_label];
    self.downLabel = downLabel;
    [self addSubview:downLabel];
    
    [upLabel addTapGesture:self sel:@selector(didTap:)];
    [downLabel addTapGesture:self sel:@selector(didTap:)];
}

#pragma mark - UITapGestureRecognizer Methods

- (void)didTap:(UITapGestureRecognizer *)tapGesture {
    UILabel *label = (UILabel *)tapGesture.view;
    
    if (!label || ![label isKindOfClass:[UILabel class]]) return;
    
    NSInteger index = 0;
    if (self.scrollArray.count) index = [self.scrollArray indexOfObject:label.text];
    
    if ([self.scrollLabelViewDelegate respondsToSelector:@selector(scrollLabelView:didClickWithText:atIndex:)]) {
        [self.scrollLabelViewDelegate scrollLabelView:self didClickWithText:label.text atIndex:index];
    }
}

#pragma mark - Instance Methods
/** Terminating app due to uncaught exception 'Warning MMScrollLabelView -[MMScrollLabelView init] unimplemented!', reason: 'unimplemented, use - scrollWithTitle:scrollType:scrollVelocity:options:'*/
- (instancetype)init {
    @throw [NSException exceptionWithName:[NSString stringWithFormat:@"Warning %@ %s unimplemented!", self.class, __func__] reason:@"unimplemented, please use - scrollWithTitle:scrollType:scrollVelocity:options:" userInfo:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self setSomePreference];
        
        [self setSomeSubviews];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)scrollTitle
                         type:(MMScrollLabelViewType)scrollType
                     velocity:(NSTimeInterval)scrollVelocity
                      options:(UIViewAnimationOptions)options
                        inset:(UIEdgeInsets)inset {
    if (self = [super init]) {
        _scrollTitle = scrollTitle;
        _scrollType = scrollType;
        self.scrollVelocity = scrollVelocity;
        _options = options;
        _scrollInset = inset;
    }
    return self;
}

#pragma mark - Factory Methods

+ (instancetype)scrollWithTitle:(NSString *)scrollTitle {
    
    return [self scrollWithTitle:scrollTitle
                            type:MMScrollLabelViewTypeLeftRight];
}

+ (instancetype)scrollWithTitle:(NSString *)scrollTitle
                           type:(MMScrollLabelViewType)scrollType {
    
    return [self scrollWithTitle:scrollTitle
                            type:scrollType
                        velocity:MMScrollDefaultTimeInterval];
}

+ (instancetype)scrollWithTitle:(NSString *)scrollTitle
                       type:(MMScrollLabelViewType)scrollType
                   velocity:(NSTimeInterval)scrollVelocity {
    
    return [self scrollWithTitle:scrollTitle
                        type:scrollType
                    velocity:scrollVelocity
                     options:UIViewAnimationOptionCurveEaseInOut];
}

+ (instancetype)scrollWithTitle:(NSString *)scrollTitle
                       type:(MMScrollLabelViewType)scrollType
                   velocity:(NSTimeInterval)scrollVelocity
                    options:(UIViewAnimationOptions)options {
    
    return [self scrollWithTitle:scrollTitle
                            type:scrollType
                        velocity:scrollVelocity
                         options:options
                           inset:UIEdgeInsetsMake(0, 5, 0, 5)];
}

+ (instancetype)scrollWithTitle:(NSString *)scrollTitle
                       type:(MMScrollLabelViewType)scrollType
                   velocity:(NSTimeInterval)scrollVelocity
                    options:(UIViewAnimationOptions)options
                      inset:(UIEdgeInsets)inset {
    
    return [[self alloc] initWithTitle:scrollTitle
                                  type:scrollType
                              velocity:scrollVelocity
                               options:options
                                 inset:inset];
}

#pragma mark - Deprecated Getter & Setter Methods
/*************WILL BE REMOVED IN THE FUTURE.****************************/

- (void)setMm_scrollTitle:(NSString *)mm_scrollTitle {
    self.scrollTitle = mm_scrollTitle;
}

- (void)setMm_scrollType:(MMScrollLabelViewType)mm_scrollType {
    self.scrollType = mm_scrollType;
}

- (void)setMm_scrollVelocity:(NSTimeInterval)mm_scrollVelocity {
    self.scrollVelocity = mm_scrollVelocity;
}

- (void)setMm_scrollContentSize:(CGRect)mm_scrollContentSize {
    _mm_scrollContentSize = mm_scrollContentSize;
    self.frame = _mm_scrollContentSize;
}

- (void)setMm_scrollTitleColor:(UIColor *)mm_scrollTitleColor {
    self.scrollTitleColor = mm_scrollTitleColor;
}
/*************ALL ABOVE.*******************************************/


#pragma mark - Getter & Setter Methods

- (void)setScrollTitle:(NSString *)scrollTitle {
    _scrollTitle = scrollTitle;
//    self.scrollArray = nil;
    [self setupSubviewsLayout];
}

- (void)setScrollType:(MMScrollLabelViewType)scrollType {
    if (_scrollType == scrollType) return;
    
    _scrollType = scrollType;
    self.scrollVelocity = _scrollVelocity;
    [self setupSubviewsLayout];
}

- (void)setScrollVelocity:(NSTimeInterval)scrollVelocity {
    CGFloat velocity = scrollVelocity;
    if (scrollVelocity < 0.1) {
        velocity = 0.1;
    }else if (scrollVelocity > 10) {
        velocity = 10;
    }
    
    if (_scrollType == MMScrollLabelViewTypeLeftRight || _scrollType == MMScrollLabelViewTypeUpDown) {
        _scrollVelocity = velocity / 30.0;
    }else {
        _scrollVelocity = velocity;
    }
}

- (UIViewAnimationOptions)options {
    if (_options) return _options;
    return _options = UIViewAnimationOptionCurveEaseInOut;
}

- (void)setScrollTitleColor:(UIColor *)scrollTitleColor {
    _scrollTitleColor = scrollTitleColor;
    [self setupTextColor:scrollTitleColor];
}

- (void)setScrollInset:(UIEdgeInsets)scrollInset {
    _scrollInset = scrollInset;
    [self setupSubviewsLayout];
}

- (void)setScrollSpace:(CGFloat)scrollSpace {
    _scrollSpace = scrollSpace;
    [self setupSubviewsLayout];
}

- (CGFloat)scrollSpace {
    if (_scrollSpace) return _scrollSpace;
    return 0.f;
}

- (NSArray *)scrollArray {
    if (_scrollArray) return _scrollArray;
    if (_scrollTexts.count) {
        return _scrollArray = _scrollTexts;
    }
    return _scrollArray = [self getSeparatedLinesFromLabel];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setupSubviewsLayout];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
    self.upLabel.textAlignment = textAlignment;
    self.downLabel.textAlignment = textAlignment;
}

- (void)setFont:(UIFont *)font {
    _font = font;
    self.upLabel.font = font;
    self.downLabel.font = font;
    [self setupSubviewsLayout];
}

- (UIFont *)font {
    if (_font) return _font;
    return MMScrollLabelFont;
}

#pragma mark - Custom Methods

// Component initial
- (void)setupInitial {
    switch (_scrollType) {
        case MMScrollLabelViewTypeLeftRight:
            [self updateTextForScrollViewWithSEL:@selector(updateLeftRightScrollLabelLayoutWithText:labelType:)];
            break;
            
        case MMScrollLabelViewTypeUpDown:
            [self updateTextForScrollViewWithSEL:@selector(updateUpDownScrollLabelLayoutWithText:labelType:)];
            break;
        case MMScrollLabelViewTypeFlipRepeat:
        case MMScrollLabelViewTypeFlipNoRepeat:
            // TODO
            break;
            
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"MMScrollLabelViewType unrecognized in -[MMScrollLabelView setupInitial]" userInfo:nil];
            break;
    }
}

/** 重置滚动视图 */
- (void)resetScrollLabelView {
    [self endup];//停止滚动
    [self setupSubviewsLayout];//重新布局
    [self startup];//开始滚动
}

- (void)setupTextColor:(UIColor *)color {
    self.upLabel.textColor = color;
    self.downLabel.textColor = color;
}

- (void)setupTitle:(NSString *)title {
    self.upLabel.text = title;
    self.downLabel.text = title;
}

- (void)setupAttributeTitle:(NSAttributedString *)attributeTitle {
    _scrollTitle = attributeTitle.string;
    [self setupSubviewsLayout];
    self.upLabel.attributedText = attributeTitle;
    self.downLabel.attributedText = attributeTitle;
}

#pragma mark - SubviewsLayout Methods

- (void)setupSubviewsLayout {
    switch (_scrollType) {
        case MMScrollLabelViewTypeLeftRight:
            if (self.isArray) {
                [self setupInitial];
            }else {
                [self setupSubviewsLayout_LeftRight];
            }
            break;
        case MMScrollLabelViewTypeUpDown:
            if (self.isArray) {
                [self setupInitial];
            }else {
                [self setupSubviewsLayout_UpDown];
            }
            break;
        case MMScrollLabelViewTypeFlipRepeat: {
            [self setupSubviewsLayout_Flip];
            [self setupTitle:_scrollTitle];
        }
            break;
        case MMScrollLabelViewTypeFlipNoRepeat:
            [self setupSubviewsLayout_Flip];
            break;
            
        default:
            break;
    }
}

- (void)setupSubviewsLayout_LeftRight {
    
    CGFloat labelMaxH = self.mm_height;//最大高度
    CGFloat labelMaxW = 0;//无限宽
    CGFloat labelH = labelMaxH;//label实际高度
    __block CGFloat labelW = 0;//label宽度，有待计算
    
    [self setupLRUDTypeLayoutWithMaxSize:CGSizeMake(labelMaxW, labelMaxH) width:labelW height:labelH completedHandler:^(CGSize size) {
        labelW = MAX(size.width, self.mm_width);
        //开始布局
        self.upLabel.frame = CGRectMake(self->_scrollInset.left, 0, labelW, labelH);
        //由于 MMScrollLabelViewTypeLeftRight\UpDown 类型 X\Y 值均不一样，此处不再block中处理！
        self.downLabel.frame = CGRectMake(CGRectGetMaxX(self.upLabel.frame) + self.scrollSpace, 0, labelW, labelH);
    }];
}

- (void)setupSubviewsLayout_UpDown {
    CGFloat labelMaxH = 0;
    CGFloat labelMaxW = self.mm_width - _scrollInset.left - _scrollInset.right;
    CGFloat labelW = labelMaxW;
    __block CGFloat labelH = 0;
    
    [self setupLRUDTypeLayoutWithMaxSize:CGSizeMake(labelMaxW, labelMaxH) width:labelW height:labelH completedHandler:^(CGSize size) {
        labelH = MAX(size.height, self.mm_height);
        self.upLabel.frame = CGRectMake(self->_scrollInset.left, 0, labelW, labelH);
        self.downLabel.frame = CGRectMake(self->_scrollInset.left, CGRectGetMaxY(self.upLabel.frame) + self.scrollSpace, labelW, labelH);
    }];
}

- (void)setupSubviewsLayout_Flip {
    CGFloat labelW = self.mm_width - _scrollInset.left - _scrollInset.right;
    CGFloat labelX = _scrollInset.left;
    self.upLabel.frame = CGRectMake(labelX, 0, labelW, self.mm_height);
    self.downLabel.frame = CGRectMake(labelX, CGRectGetMaxY(self.upLabel.frame), labelW, self.mm_height);
}

- (void)setupLRUDTypeLayoutWithMaxSize:(CGSize)size
                                 width:(CGFloat)width
                                height:(CGFloat)height
                      completedHandler:(void(^)(CGSize size))completedHandler {
    CGSize scrollLabelS = [_scrollTitle boundingRectWithSize:size
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName: self.font} context:nil].size;
    //回调获取布局数据
    completedHandler(scrollLabelS);
    if (!self.isArray) {
        [self setupTitle:_scrollTitle];
    }
}

- (void)setupLRUDTypeLayoutWithTitle:(NSString *)title
                             maxSize:(CGSize)size
                               width:(CGFloat)width
                              height:(CGFloat)height
                    completedHandler:(void(^)(CGSize size))completedHandler {
    CGSize scrollLabelS = [title boundingRectWithSize:size
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName: self.font} context:nil].size;
    //回调获取布局数据
    completedHandler(scrollLabelS);
}

/**
 update the frame of scrollLabel. Just layout
 
 @param text scrollText
 @param type scrollLabel type
 */
- (void)updateLeftRightScrollLabelLayoutWithText:(NSString *)text labelType:(MMScrollLabelType)type {
    CGFloat labelMaxH = self.mm_height;//最大高度
    CGFloat labelMaxW = 0;//无限宽
    CGFloat labelH = labelMaxH;//label实际高度
    __block CGFloat labelW = 0;//label宽度，有待计算
    
    [self setupLRUDTypeLayoutWithTitle:text maxSize:CGSizeMake(labelMaxW, labelMaxH) width:labelW height:labelH completedHandler:^(CGSize size) {
        labelW = MAX(size.width, self.mm_width);
        //开始布局
        if (type == MMScrollLabelTypeUp) {
            self.upLabel.frame = CGRectMake(self->_scrollInset.left, 0, labelW, labelH);
        }else if (type == MMScrollLabelTypeDown) {
            self.downLabel.frame = CGRectMake(CGRectGetMaxX(self.upLabel.frame) + self.scrollSpace, 0, labelW, labelH);
        }
    }];
}

/**
 The same as "-updateLeftRightScrollLabelLayoutWithText:labelType:"
 */
- (void)updateUpDownScrollLabelLayoutWithText:(NSString *)text labelType:(MMScrollLabelType)type {
    CGFloat labelMaxH = 0;
    CGFloat labelMaxW = self.mm_width - _scrollInset.left - _scrollInset.right;
    CGFloat labelW = labelMaxW;
    __block CGFloat labelH = 0;
    
    [self setupLRUDTypeLayoutWithTitle:text maxSize:CGSizeMake(labelMaxW, labelMaxH) width:labelW height:labelH completedHandler:^(CGSize size) {
        labelH = MAX(size.height, self.mm_height);
        if (type == MMScrollLabelTypeUp) {
            self.upLabel.frame = CGRectMake(self->_scrollInset.left, 0, labelW, labelH);
        }else if (type == MMScrollLabelTypeDown) {
            self.downLabel.frame = CGRectMake(self->_scrollInset.left, CGRectGetMaxY(self.upLabel.frame) + self.scrollSpace, labelW, labelH);
        }
    }];
}

#pragma mark - Scrolling Operation Methods -- Public

- (void)beginScrolling {
    self.currentSentence = 0;
    if (self.isArray) {
        [self setupInitial];
    }
    [self startup];
}

- (void)endScrolling {
    [self endup];
}

- (void)pauseScrolling {
    [self endup];
}

#pragma mark - Scrolling Operation Methods -- Private

- (void)endup {
    [self.scrollTimer invalidate];
    self.scrollTimer = nil;
    self.scrollArray = nil;
}

- (void)startup {
    if (!self.scrollTitle.length && !self.scrollArray.count) return;
    
    [self endup];
    
    if (_scrollType == MMScrollLabelViewTypeFlipRepeat || _scrollType == MMScrollLabelViewTypeFlipNoRepeat) {
        _firstTime = YES;
        if (_scrollType == MMScrollLabelViewTypeFlipNoRepeat) {
            [self setupTitle:[self.scrollArray firstObject]];//初次显示
        }
        [self startWithVelocity:1];
    }else {
        [self startWithVelocity:self.scrollVelocity];
    }
}

//开始计时
- (void)startWithVelocity:(NSTimeInterval)velocity {
//    if (!self.scrollTitle.length) return;
    
    if (!self.scrollTitle.length && self.scrollArray.count) return;

    __weak typeof(self) weakSelf = self;
    self.scrollTimer = [NSTimer mm_scheduledTimerWithTimeInterval:velocity repeat:YES block:^(NSTimer *timer) {
        MMScrollLabelView *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf updateScrolling];
        }
    }];
    [[NSRunLoop mainRunLoop] addTimer:self.scrollTimer forMode:NSRunLoopCommonModes];
}

#pragma mark - Scrolling Animation Methods

- (void)updateScrolling {
    switch (self.scrollType) {
        case MMScrollLabelViewTypeLeftRight:
            [self updateScrollingType_LeftRight];
            break;
        case MMScrollLabelViewTypeUpDown:
            [self updateScrollingType_UpDown];
            break;
        case MMScrollLabelViewTypeFlipRepeat:
            [self updateScrollingType_FlipRepeat];
            break;
        case MMScrollLabelViewTypeFlipNoRepeat:
            [self updateScrollingType_FlipNoRepeat];
            break;
        default:
            break;
    }
}

#pragma mark - ScrollLabelView + Methods

- (void)updateScrollingType_LeftRight {

    if (self.contentOffset.x >= (_scrollInset.left + self.upLabel.mm_width + self.scrollSpace)) {
        /** 更新 Label.text */
        if ((self.contentOffset.x > (_scrollInset.left + self.upLabel.mm_width) - self.mm_width) &&
            self.isArray) {
            [self updateTextForScrollViewWithSEL:@selector(updateLeftRightScrollLabelLayoutWithText:labelType:)];
        }
        [self endup];
        self.contentOffset = CGPointMake(_scrollInset.left + 1, 0);//x增加偏移量，防止卡顿
            [self startup];
    }else {
        self.contentOffset = CGPointMake(self.contentOffset.x + 1, self.contentOffset.y);
    }
    
}

- (void)updateScrollingType_UpDown {
    if (self.contentOffset.y >= (self.upLabel.mm_height + self.scrollSpace)) {
        /** 更新 Label.text */
        if ((self.contentOffset.y >= (self.upLabel.mm_height)) &&
            self.isArray) {
            [self updateTextForScrollViewWithSEL:@selector(updateUpDownScrollLabelLayoutWithText:labelType:)];
        }
        [self endup];
        self.contentOffset = CGPointMake(0, 2);//y增加偏移量，防止卡顿
        [self startup];
    }else {
        self.contentOffset = CGPointMake(self.contentOffset.x, self.contentOffset.y + 1);
    }
}

- (void)updateScrollingType_FlipRepeat {
    [self updateRepeatTypeWithOperation:^(NSTimeInterval velocity) {
        [self flipAnimationWithDelay:velocity];
    }];
}

- (void)updateScrollingType_FlipNoRepeat {
    [self updateRepeatTypeWithOperation:^(NSTimeInterval velocity) {
        [self flipNoCleAnimationWithDelay:velocity];
    }];
}

- (void)updateRepeatTypeWithOperation:(void(^)(NSTimeInterval))operation {
    NSTimeInterval velocity = self.scrollVelocity;
    if (self.isFirstTime) {
        _firstTime = NO;
        [self endup];
        [self startWithVelocity:velocity];
    }
    operation(velocity);
}

- (void)flipAnimationWithDelay:(NSTimeInterval)delay {
    [UIView transitionWithView:self.upLabel duration:delay * 0.5 options:self.options animations:^{
        self.upLabel.mm_bottom = 0;
        [UIView transitionWithView:self.upLabel duration:delay * 0.5 options:self.options animations:^{
            self.downLabel.mm_y = 0;
        } completion:^(BOOL finished) {
            self.upLabel.mm_y = self.mm_height;
            MMScrollLabel *tempLabel = self.upLabel;
            self.upLabel = self.downLabel;
            self.downLabel = tempLabel;
        }];
    } completion:nil];
}


/**
 Execute flip animation.

 @param delay animation duration.
 */
- (void)flipNoCleAnimationWithDelay:(NSTimeInterval)delay {
    if (!self.scrollArray.count) return;
    /** 更新文本 */
    [self updateScrollText];
    /** 执行翻滚动画 */
    [self flipAnimationWithDelay:delay];
}

#pragma mark - Params For Array

void (*setter)(id, SEL, NSString *, MMScrollLabelType);

- (void)updateTextForScrollViewWithSEL:(SEL)sel {
    
    if (!self.scrollArray.count) return;

    /** 更新文本 */
    [self updateScrollText];
    /** 执行 SEL */
    setter = (void (*)(id, SEL, NSString *, MMScrollLabelType))[self methodForSelector:sel];
    setter(self, sel, self.upLabel.text, MMScrollLabelTypeUp);
    setter(self, sel, self.downLabel.text, MMScrollLabelTypeDown);
}

- (void)updateScrollText {
    NSInteger currentSentence = self.currentSentence;
    if (currentSentence >= self.scrollArray.count) currentSentence = 0;
    self.upLabel.text = self.scrollArray[currentSentence];
    currentSentence ++;
    if (currentSentence >= self.scrollArray.count) currentSentence = 0;
    self.downLabel.text = self.scrollArray[currentSentence];
    
    self.currentSentence = currentSentence;
}

#pragma mark - Text-Separator

-(NSArray *)getSeparatedLinesFromLabel {
    if (!_scrollTitle.length) return nil;
    
    NSString *text = _scrollTitle;
    UIFont *font = self.font;
    CTFontRef myFont = CTFontCreateWithName((__bridge CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)myFont range:NSMakeRange(0, attStr.length)];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,self.upLabel.mm_width,100000));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    for (id line in lines) {
        CTLineRef lineRef = (__bridge CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSString *lineString = [text substringWithRange:range];
        [linesArray addObject:lineString];
    }
    CFRelease(myFont);
    CFRelease(frameSetter);
    CFRelease(frame);
    CFRelease(path);
    return (NSArray *)linesArray;
}

- (void)dealloc {
    [self endup];
}

@end

@implementation MMScrollLabelView (MMArray)

#pragma mark - Array Methods

- (instancetype)initWithTextArray:(NSArray *)scrollTexts
                             type:(MMScrollLabelViewType)scrollType
                         velocity:(NSTimeInterval)scrollVelocity
                          options:(UIViewAnimationOptions)options
                            inset:(UIEdgeInsets)inset {
    if (self = [super init]) {
        self.isArray = YES;
        _scrollTexts = [scrollTexts copy];
        _scrollTitle = [_scrollTexts firstObject];
        _scrollType = scrollType;
        self.scrollVelocity = scrollVelocity;
        _options = options;
        _scrollInset = inset;
    }
    return self;
}

+ (instancetype)scrollWithTextArray:(NSArray *)scrollTexts
                               type:(MMScrollLabelViewType)scrollType
                           velocity:(NSTimeInterval)scrollVelocity
                            options:(UIViewAnimationOptions)options
                              inset:(UIEdgeInsets)inset {
    return [[self alloc] initWithTextArray:scrollTexts
                                      type:scrollType
                                  velocity:scrollVelocity
                                   options:options
                                     inset:inset];
}

@end

@implementation MMScrollLabelView (MMScrollLabelViewDeprecated)

+ (instancetype)mm_setScrollTitle:(NSString *)scrollTitle {
    
    return [self scrollWithTitle:scrollTitle];
}

+ (instancetype)mm_setScrollTitle:(NSString *)scrollTitle
                       scrollType:(MMScrollLabelViewType)scrollType {
    
    return [self scrollWithTitle:scrollTitle
                            type:scrollType];
}

+ (instancetype)mm_setScrollTitle:(NSString *)scrollTitle
                       scrollType:(MMScrollLabelViewType)scrollType
                   scrollVelocity:(NSTimeInterval)scrollVelocity {
    
    return [self scrollWithTitle:scrollTitle
                            type:scrollType
                        velocity:scrollVelocity];
}

+ (instancetype)mm_setScrollTitle:(NSString *)scrollTitle
                       scrollType:(MMScrollLabelViewType)scrollType
                   scrollVelocity:(NSTimeInterval)scrollVelocity
                          options:(UIViewAnimationOptions)options {
    
    return [self scrollWithTitle:scrollTitle
                            type:scrollType
                        velocity:scrollVelocity
                         options:options];
}

+ (instancetype)mm_setScrollTitle:(NSString *)scrollTitle
                       scrollType:(MMScrollLabelViewType)scrollType
                   scrollVelocity:(NSTimeInterval)scrollVelocity
                          options:(UIViewAnimationOptions)options
                            inset:(UIEdgeInsets)inset {
    
    return [self scrollWithTitle:scrollTitle
                            type:scrollType
                        velocity:scrollVelocity
                         options:options
                           inset:inset];
}

@end


@implementation UIView (MMAdditions)

- (void)addTapGesture:(id)target sel:(SEL)selector {
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    [self addGestureRecognizer:tap];
}

@end
