//
//  UIView+Create.m
//  TZYJ_IPhone
//
//  Created by Weirdln on 15/9/27.
//
//

#import "UIView+Create.h"
#import "GrayCoverBtn.h"
#import "PASTextField.h"
#import <objc/runtime.h>
#import "UIColor+Extensions.h"
#import "GCDCommon.h"

#pragma mark - UIView
@implementation UIView (Create)

- (UIView *)overlayer
{
    UIView *v = objc_getAssociatedObject(self, @selector(overlayer));
    return v;
}
- (void)setOverlayer:(UIView *)overlayer
{
    objc_setAssociatedObject(self, @selector(overlayer), overlayer, OBJC_ASSOCIATION_ASSIGN);
    [self addSubview:overlayer];
}

- (UIColor*)deepColor
{
    if (![self.superview.backgroundColor isEqual:[UIColor clearColor]]) {
        return self.superview.backgroundColor;
    } else {
        return [self.superview deepColor];
    }
}

+ (UIView *)creatLineStarPoint:(CGPoint )point length:(NSInteger)length lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor isHorizontal:(BOOL)isHorizontal
{
    UIView *line = [[UIView alloc] init];
    if (lineWidth == 0) {
        lineWidth = 0.5;
    }
    if (isHorizontal) {
        line.frame = CGRectMake(point.x, point.y, length, lineWidth);
    }else{
        line.frame = CGRectMake(point.x, point.y, lineWidth, length);
    }
    if (lineColor) {
        line.backgroundColor = lineColor;
    }else{
        line.backgroundColor = UIColorFromRGB(0x444444);
    }
    return line;
}

+ (UIView *)creatLineStarPoint:(CGPoint )point length:(NSInteger)length isHorizontal:(BOOL)isHorizontal{
    UIView *line = [[self alloc] init];
    if (isHorizontal) {
        line.frame = CGRectMake(point.x, point.y, length, 0.5);
    }else{
        line.frame = CGRectMake(point.x, point.y, 0.5, length);
    }
    line.backgroundColor = UIColorFromRGB(0x444444);
    return line;
}
+ (UIView *)creatPointWithNum:(NSInteger)num
                    withColor:(UIColor *)color
                    withFrame:(CGRect)frame
                   pointColor:(UIColor *)pointColor{
    
    UIView *view = [UIView viewForColor:color withFrame:frame];
    double gap = (frame.size.width-4)/(num-1);
    for (NSInteger index=0; index<num; index++) {
        UIView *pointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, 4)];
        pointView.backgroundColor = pointColor;
        pointView.layer.cornerRadius =2;
        pointView.layer.masksToBounds = YES;
        pointView.center = CGPointMake(2+(index*gap), frame.size.height/2);
        [view addSubview:pointView];
    }
    return view;
}
// 设置背景颜色的视图
+ (UIView *)viewForColor:(UIColor *)color withFrame:(CGRect)frame
{
    UIView *view = [[self alloc] initWithFrame:frame];
    view.backgroundColor = color;
    return view;
}

+ (UIView *)viewWithFrame:(CGRect)frame
{
    UIView *tempView = [[UIView alloc] initWithFrame:frame];
    return tempView;
}

- (UIView *)buildView:(CGRect)frame bgColor:(UIColor *)bgColor
{
    UIView *tempView = [[UIView alloc] initWithFrame:frame];
    tempView.backgroundColor = bgColor;
    [self addSubview:tempView];
    return tempView;
}

- (void)viewWithTitle:(NSString *)titile
{
    performBlockOnMainQueue(NO, ^{
        static UILabel *l = nil;
        if (!l) {
            l = [[UILabel alloc] init];
            l.textColor = [UIColor grayColor];
            l.font = [UIFont systemFontOfSize:14];
        }
        
        l.text = titile;
        [l sizeToFit];
        l.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [self addSubview:l];
    });
}

- (UILabel *)buildLabel:(CGRect)frame textColor:(UIColor *)textColor font:(UIFont *)font text:(NSString *)text
{
    return [self buildLabel:frame textColor:textColor font:font text:text textAlignment:NSTextAlignmentLeft];
}

- (UILabel *)buildLabel:(CGRect)frame textColor:(UIColor *)textColor font:(UIFont *)font text:(NSString *)text textAlignment:(NSTextAlignment)textAlignment
{
    UILabel *templab = [[UILabel alloc] initWithFrame:frame];
    templab.backgroundColor = [UIColor clearColor];
    templab.textAlignment = textAlignment;
    templab.textColor = textColor;
    templab.font = font;
    templab.text = text;
    [self addSubview:templab];
    return templab;
}


/**
 *  创建带圆角button，自带点击特效
 *
 *  @param title    <#title description#>
 *  @param frame    <#frame description#>
 *  @param radius   <#radius description#>
 *  @param obj      <#obj description#>
 *  @param selector <#selector description#>
 *  @param block    可以设置button的各种状态
 *
 *  @return <#return value description#>
 */
- (UIButton *)buildButtonWithTitle:(NSString *)title frame:(CGRect)frame cornerRadius:(float)radius target:(id)obj action:(SEL)selector block:(void (^)(UIButton *btn))block
{
    GrayCoverBtn *tempBtn = [[GrayCoverBtn alloc ] init];
    tempBtn.frame = frame;
    tempBtn.backgroundColor = [UIColor clearColor];
    [tempBtn setTitle:title forState:UIControlStateNormal];
    tempBtn.layer.cornerRadius = radius;
    tempBtn.layer.masksToBounds = YES;
    [tempBtn addTarget:obj action:selector forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:tempBtn];
    if (block) {
        block(tempBtn);
    }
    return tempBtn;
}

// 系统button
- (UIButton *)buildButton2WithTitle:(NSString *)title frame:(CGRect)frame  target:(id)obj action:(SEL)selector block:(void (^)(UIButton *btn))block
{
    UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tempBtn.frame = frame;
    tempBtn.backgroundColor = [UIColor clearColor];
    [tempBtn setTitle:title forState:UIControlStateNormal];
    [tempBtn addTarget:obj action:selector forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:tempBtn];
    if (block) {
        block(tempBtn);
    }
    return tempBtn ;
}

- (UIImageView *)buildImage:(CGRect)frame image:(NSString *)imageName
{
    UIImageView *tempView = [[UIImageView alloc] initWithFrame:frame];
    tempView.backgroundColor = [UIColor clearColor];
    tempView.image = imageName.length > 0 ? [UIImage imageNamed:imageName] : nil;
    [self addSubview:tempView];
    return tempView;
}

- (void)dismissView
{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)addTapTarget:(nullable id)target selector:(nullable SEL)selector
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    tapGest.numberOfTapsRequired = 1;
    tapGest.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGest];
}

@end

#pragma mark - UIImageView
@implementation UIImageView  (Create)

// 根据图片生成view
+ (UIImageView *)imageViewForImage:(UIImage*)image withFrame:(CGRect)frame;
{
    UIImageView *imageView = [[self alloc] initWithFrame:frame];
    imageView.userInteractionEnabled = YES;
    imageView.image = image;
    return imageView;
}

@end

#pragma mark - UIImage
@implementation UIImage  (Create)

+ (UIImage *)imageNamed:(NSString *)name bundle:(NSBundle *)bundle
{
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[bundle bundlePath], name]];
}

+ (UIImage *)retinaImageNamed:(NSString *)name bundle:(NSBundle *)bundle
{
    UIImage *img        = [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:nil]];
    CGImageRef cgimage  = img.CGImage;
    img                 = [UIImage imageWithCGImage:cgimage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    
    return img;
}

+ (UIImage *)resizeImageWithName:(NSString *)name bundle:(NSBundle *)bundle
{
    UIImage *image = [[self class] retinaImageNamed:name bundle:bundle];//获取图片
    if(image)
    {
        CGSize size = image.size;
        CGFloat x = ceilf(size.width*.5);
        CGFloat y = ceilf(size.height*.5);
        if([image respondsToSelector:@selector(resizableImageWithCapInsets:)])
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(y, x, y, x)];
        else
            image = [image stretchableImageWithLeftCapWidth:x topCapHeight:y];
    }
    return image;
}

+ (UIImage *)imageWithName:(NSString *)name
{
    return [[self class] imageWithName:name isResize:YES];
}

+ (UIImage *)imageWithName:(NSString *)name isResize:(BOOL)resize
{
    if(resize)
        return [[self class] resizeImageWithName:name bundle:[NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/CommonResource.bundle/images", [[NSBundle mainBundle] resourcePath]]]];
    else
        return [[self class] retinaImageNamed:name bundle:[NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/CommonResource.bundle/images", [[NSBundle mainBundle] resourcePath]]]];
}


@end

#pragma mark - CATextLayer
@implementation CATextLayer  (Create)

@end


#pragma mark - CALayer
@implementation CALayer  (Create)

@end


#pragma mark - UILabel
@implementation UILabel  (Create)
//[numOne setFont:[UIFont fontWithName:@"Arial-BoldMT" size:17]];
- (void)fontArialBoldMTTypefaceWithSize:(NSInteger)size{
    [self setFont:[UIFont fontWithName:@"Arial-BoldMT" size:size]];
}
- (void)fontArialMTTypefaceWithSize:(NSInteger)size{
    [self setFont:[UIFont fontWithName:@"ArialMT" size:size]];
}


+ (UILabel *)creatLableWithTitleColor:(UIColor*)titleColor withFont:(UIFont *)font withFrame:(CGRect)frame
{
    return [[self class] labelWithFrame:frame text:@"" textColor:titleColor font:font backColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter];
}

+ (UILabel *)labelWithFrame:(CGRect)frame text:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font backColor:(UIColor*)backColor textAlignment:(NSTextAlignment)textAlignment
{
    UILabel *label = [[self alloc] initWithFrame:frame];
    label.textAlignment = textAlignment;
    label.backgroundColor = [UIColor clearColor];
    
    if (text)
        label.text = text;
    if(backColor)
        label.backgroundColor = backColor;
    if(font)
        label.font = font;
    if(textColor)
        label.textColor = textColor;
    return label;
}

+ (UILabel *)labelWithFrame:(CGRect)frame text:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font backColor:(UIColor*)backColor
{
    return [[self class] labelWithFrame:frame text:text textColor:textColor font:font backColor:backColor textAlignment:NSTextAlignmentCenter];
}

+ (UILabel *)labelWithFrame:(CGRect)frame text:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font textAlignment:(NSTextAlignment)textAlignment;
{
    return [[self class] labelWithFrame:frame text:text textColor:textColor font:font backColor:[UIColor clearColor] textAlignment:textAlignment];
}

+ (UILabel *)labelWithFrame:(CGRect)frame text:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font
{
    return [[self class] labelWithFrame:frame text:text textColor:textColor font:font backColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter];
}

+ (UILabel *)labelWithFrame:(CGRect)frame text:(NSString *)text textColor:(UIColor *)textColor
{
    return [[self class] labelWithFrame:frame text:text textColor:textColor font:nil backColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter];
}

+ (UILabel *)labelLeftAlignWithFrame:(CGRect)frame text:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font
{
    return [[self class] labelWithFrame:frame text:text textColor:textColor font:font backColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
}

// autolayout
+ (nullable UILabel *)lableWithText:(NSString *)text textColor:(nullable UIColor *)textColor font:(nullable UIFont *)font textAlignment:(NSTextAlignment)textAlignment
{
    return [[self class] labelWithFrame:CGRectZero text:text textColor:textColor font:font backColor:nil textAlignment:textAlignment];
}

+ (nullable UILabel *)lableWithText:(NSString *)text textColor:(nullable UIColor *)textColor font:(nullable UIFont *)font
{
    return [[self class] lableWithText:text textColor:textColor font:font textAlignment:NSTextAlignmentCenter];
}
+ (UILabel *)labelCenterAlignWithFrame:(CGRect)frame text:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font
{
    return [[self class] labelWithFrame:frame text:text textColor:textColor font:font backColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter];
}
@end


#pragma mark - UIButton

#import "UIButton+Block.h"
//#import "UIImageCategory.h"

@implementation UIButton  (Create)

+ (nonnull UIButton *)buttonWithFrame:(CGRect)frame
                                title:(nullable NSString *)title
                                 font:(nullable UIFont *)font
                           titleColor:(nullable UIColor *)titleColor block:(void (^__nullable)(void))block{
   return   [self buttonWithFrame:frame
                           target:nil
                          action:nil
                           title:title
                            font:font
                      titleColor:titleColor
                         bgImage:nil
                       backColor:[UIColor clearColor]
                             tag:0 block:block];
}

+ (UIButton *)buttonWithFrame:(CGRect)frame target:(id)target action:(SEL)action title:(NSString *)title font:(UIFont *)font titleColor:(UIColor *)titleColor bgImage:(UIImage *)bgImage backColor:(UIColor *)backColor tag:(NSInteger)tag
{
    UIButton *button = [self buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    if (font)
        button.titleLabel.font = font;
    
    if (titleColor)
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    
    if (bgImage)
        [button setBackgroundImage:bgImage forState:UIControlStateNormal];
    
    if(backColor)
        [button setBackgroundColor:backColor];
    
    [button setTag:tag];
    return button;
}

+ (UIButton *)buttonWithFrame:(CGRect)frame target:(id)target action:(SEL)action title:(NSString *)title font:(UIFont *)font titleColor:(UIColor *)titleColor bgImage:(UIImage *)bgImage tag:(NSInteger)tag
{
    return [[self class]buttonWithFrame:frame target:target action:action title:title font:font titleColor:titleColor bgImage:bgImage backColor:[UIColor clearColor] tag:tag];
}

+ (UIButton *)buttonWithFrame:(CGRect)frame target:(id)target action:(SEL)action title:(NSString *)title font:(UIFont *)font titleColor:(UIColor *)titleColor backColor:(UIColor *)backColor tag:(NSInteger)tag
{
    return [[self class]buttonWithFrame:frame target:target action:action title:title font:font titleColor:titleColor bgImage:nil backColor:backColor tag:tag];
}

+ (UIButton *)buttonWithFrame:(CGRect)frame target:(id)target action:(SEL)action bgImage:(UIImage *)bgImage tag:(NSInteger)tag
{
    return [[self class]buttonWithFrame:frame target:target action:action title:nil font:nil titleColor:nil bgImage:bgImage  backColor:[UIColor clearColor] tag:tag];
}

+ (UIButton *)buttonWithFrame:(CGRect)frame target:(id)target action:(SEL)action title:(NSString *)title font:(UIFont *)font titleColor:(UIColor *)titleColor bgImage:(UIImage *)bgImage backColor:(UIColor *)backColor tag:(NSInteger)tag  block:(void (^)(void))block
{
    UIButton *button = [self buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    if (font)
        button.titleLabel.font = font;
    
    if (titleColor)
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    
    if (bgImage)
        [button setBackgroundImage:bgImage forState:UIControlStateNormal];
    
    if(backColor)
        [button setBackgroundColor:backColor];
    
    if (block)
        [button handleControlEvent:UIControlEventTouchUpInside withBlock:block];
    
    [button setTag:tag];
    return button;
}

+ (UIButton *)buttonWithFrame:(CGRect)frame target:(id)target action:(SEL)action title:(NSString *)title font:(UIFont *)font titleColor:(UIColor *)titleColor bgImage:(UIImage *)bgImage tag:(NSInteger)tag block:(void (^)(void))block
{
    return [[self class] buttonWithFrame:frame target:target action:action title:title font:font titleColor:titleColor bgImage:bgImage backColor:[UIColor clearColor] tag:tag block:block];
}

+ (UIButton *)buttonWithFrame:(CGRect)frame target:(id)target action:(SEL)action bgImage:(UIImage *)bgImage tag:(NSInteger)tag block:(void (^)(void))block
{
    return [[self class] buttonWithFrame:frame target:target action:action title:nil font:nil titleColor:nil bgImage:bgImage backColor:[UIColor clearColor] tag:tag block:block];
}

+ (UIButton *)buttonWithFrame:(CGRect)frame target:(id)target action:(SEL)action title:(NSString *)title font:(UIFont *)font titleColor:(UIColor *)titleColor bgImageColor:(UIColor *)bgImageColor tag:(NSInteger)tag block:(void (^)(void))block
{
    UIImage *image = bgImageColor ? [UIImage createImageWithColor:bgImageColor] : nil;
    return [[self class] buttonWithFrame:frame target:target action:action title:title font:font titleColor:titleColor bgImage:image backColor:[UIColor clearColor] tag:tag block:block];
}

@end

#pragma mark - UITextField
@implementation UITextField  (Create)

+ (nonnull UITextField *)textFieldWithFrame:(CGRect)frame placeholder:(nullable NSString *)placeholder font:(nullable UIFont *)font textColor:(nullable UIColor *)textColor bgImage:(nullable UIImage *)bgImage
{
    return [[self class] textFieldWithFrame:frame placeholder:placeholder font:font textColor:textColor bgImage:bgImage leftOffset:0 rightOffset:0];
}

+ (nonnull UITextField *)textFieldWithFrame:(CGRect)frame placeholder:(NSString *)placeholder font:(UIFont *)font textColor:(UIColor *)textColor bgImage:(UIImage *)bgImage leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset
{
    PASTextField *textField = [[[self class] alloc] initWithFrame:frame];
    textField.placeholder = placeholder;
    if (font)
        textField.font = font;
    
    if (textColor)
        textField.textColor = textColor;
    
    if (bgImage)
        [textField setBackground:bgImage];
    
    if ([textField respondsToSelector:@selector(setLeftOffset:)] && [textField respondsToSelector:@selector(setRightOffset:)])
    {
        textField.leftOffset = leftOffset;
        textField.rightOffset = rightOffset;
    }
    return textField;
}

@end
