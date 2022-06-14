//
//  UIView+Create.h
//  TZYJ_IPhone
//
//  Created by Weirdln on 15/9/27.
//
//

#import <Foundation/Foundation.h>


#pragma mark - UIView
@interface UIView (Create)

@property (nonatomic, weak, nullable) UIView *overlayer;

- (nullable UIColor *)deepColor;

+ (nonnull UIView *)creatLineStarPoint:(CGPoint )point length:(NSInteger)length lineWidth:(CGFloat)lineWidth lineColor:(nonnull UIColor *)lineColor isHorizontal:(BOOL)isHorizontal;
+ (nonnull UIView *)creatPointWithNum:(NSInteger)num withColor:(nullable UIColor *)color withFrame:(CGRect)frame pointColor:(nullable UIColor *)pointColor;
+ (nonnull UIView *)creatLineStarPoint:(CGPoint )point length:(NSInteger)length isHorizontal:(BOOL)isHorizontal;
// 设置背景颜色的视图
+ (nonnull UIView *)viewForColor:(nullable UIColor *)color withFrame:(CGRect)frame;

+ (nonnull UIView *)viewWithFrame:(CGRect)frame;

- (nonnull UIView *)buildView:(CGRect)frame bgColor:(nullable UIColor *)bgColor;

- (void)viewWithTitle:(nullable NSString *)titile;

- (nonnull UILabel *)buildLabel:(CGRect)frame textColor:(nullable UIColor *)textColor font:(nullable UIFont *)font text:(nullable NSString *)text;
- (nonnull UILabel *)buildLabel:(CGRect)frame textColor:(nullable UIColor *)textColor font:(nullable UIFont *)font text:(nullable NSString *)text textAlignment:(NSTextAlignment)textAlignment;

- (nonnull UIButton *)buildButtonWithTitle:(nullable NSString *)title frame:(CGRect)frame cornerRadius:(float)radius target:(nullable id)obj action:(nullable SEL)selector block:(void (^__nullable)(UIButton * __nonnull btn))block;

- (nonnull UIImageView *)buildImage:(CGRect)frame image:(nullable NSString *)imageName;

- (nonnull UIButton *)buildButton2WithTitle:(nullable NSString *)title frame:(CGRect)frame  target:(nullable id)obj action:(nullable SEL)selector block:(void (^__nullable)(UIButton * __nonnull btn))block;

- (void)dismissView;

- (void)addTapTarget:(nullable id)target selector:(nullable SEL)selector;


@end

#pragma mark - UIImageView
@interface UIImageView  (Create)

// 根据图片生成view
+ (nonnull UIImageView *)imageViewForImage:(nullable UIImage*)image withFrame:(CGRect)frame;
@end


#pragma mark - UIImage
@interface UIImage  (Create)

// 从bundle获取图片
+ (nullable UIImage *)imageNamed:(nullable NSString *)name bundle:(nullable NSBundle *)bundle;

// 获取Retina的图片
+ (nullable UIImage *)retinaImageNamed:(nullable NSString *)name bundle:(nullable NSBundle *)bundle;

// 获取拉伸的图片
+ (nullable UIImage *)resizeImageWithName:(nullable NSString *)name bundle:(nullable NSBundle *)bundle;

//  从默认bundle/images加载resize的图片
+ (nullable UIImage *)imageWithName:(nullable NSString *)name;

// 从默认bundle/images加载设置resize的图片
+ (nullable UIImage *)imageWithName:(nullable NSString *)name isResize:(BOOL)resize;

@end

#pragma mark - CATextLayer
@interface CATextLayer  (Create)

@end


#pragma mark - CALayer
@interface CALayer  (Create)

@end


#pragma mark - UILabel
@interface UILabel  (Create)
- (void)fontArialBoldMTTypefaceWithSize:(NSInteger)size;
- (void)fontArialMTTypefaceWithSize:(NSInteger)size;

+ (nullable UILabel *)creatLableWithTitleColor:(nullable UIColor*)titleColor withFont:(nullable UIFont *)font withFrame:(CGRect)frame;

+ (nullable UILabel *)labelWithFrame:(CGRect)frame text:(nullable NSString *)text textColor:(nullable UIColor *)textColor font:(nullable UIFont *)font backColor:(nullable UIColor *)backColor textAlignment:(NSTextAlignment)textAlignment;

+ (nullable UILabel *)labelWithFrame:(CGRect)frame text:(nullable NSString *)text textColor:(nullable UIColor *)textColor font:(nullable UIFont *)font backColor:(nullable UIColor *)backColor;

+ (nullable UILabel *)labelWithFrame:(CGRect)frame text:(nullable NSString *)text textColor:(nullable UIColor *)textColor font:(nullable UIFont *)font textAlignment:(NSTextAlignment)textAlignment;

+ (nullable UILabel *)labelWithFrame:(CGRect)frame text:(nullable NSString *)text textColor:(nullable UIColor *)textColor font:(nullable UIFont *)font;

+ (nullable UILabel *)labelWithFrame:(CGRect)frame text:(nullable NSString *)text textColor:(nullable UIColor *)textColor;

+ (nullable UILabel *)labelLeftAlignWithFrame:(CGRect)frame text:(nullable NSString *)text textColor:(nullable UIColor *)textColor font:(nullable UIFont *)font;

// autolayout
+ (nullable UILabel *)lableWithText:(nullable NSString *)text textColor:(nullable UIColor *)textColor font:(nullable UIFont *)font textAlignment:(NSTextAlignment)textAlignment;

+ (nullable UILabel *)lableWithText:(nullable NSString *)text textColor:(nullable UIColor *)textColor font:(nullable UIFont *)font;
+ (nullable UILabel *)labelCenterAlignWithFrame:(CGRect)frame
                                  text:(nullable NSString *)text
                             textColor:(nullable UIColor *)textColor
                                  font:(nullable UIFont *)font;

@end


#pragma mark - UIButton
@interface UIButton  (Create)

 /** title, bgImage, backColor */
+ (nonnull UIButton *)buttonWithFrame:(CGRect)frame target:(nullable id)target action:(nullable SEL)action title:(nullable NSString *)title font:(nullable UIFont *)font titleColor:(nullable UIColor *)titleColor bgImage:(nullable UIImage *)bgImage backColor:(nullable UIColor *)backColor tag:(NSInteger)tag  block:(void (^__nullable)(void))block;

 /** title, bgImage */
+ (nonnull UIButton *)buttonWithFrame:(CGRect)frame target:(nullable id)target action:(nullable SEL)action title:(nullable NSString *)title font:(nullable UIFont *)font titleColor:(nullable UIColor *)titleColor bgImage:(nullable UIImage *)bgImage tag:(NSInteger)tag block:(void (^__nullable)(void))block;

/** bgImage */
+ (nonnull UIButton *)buttonWithFrame:(CGRect)frame target:(nullable id)target action:(nullable SEL)action bgImage:(nullable UIImage *)bgImage tag:(NSInteger)tag block:(void (^__nullable)(void))block;

/** title, imageColor */
+ (nonnull UIButton *)buttonWithFrame:(CGRect)frame target:(nullable id)target action:(nullable SEL)action title:(nullable NSString *)title font:(nullable UIFont *)font titleColor:(nullable UIColor *)titleColor bgImageColor:(nullable UIColor *)bgImageColor tag:(NSInteger)tag block:(void (^__nullable)(void))block;

+ (nonnull UIButton *)buttonWithFrame:(CGRect)frame
                                title:(nullable NSString *)title
                                 font:(nullable UIFont *)font
                           titleColor:(nullable UIColor *)titleColor block:(void (^__nullable)(void))block;

@end

#pragma mark - UITextField
@interface UITextField  (Create)

+ (nonnull UITextField *)textFieldWithFrame:(CGRect)frame placeholder:(nullable NSString *)placeholder font:(nullable UIFont *)font textColor:(nullable UIColor *)textColor bgImage:(nullable UIImage *)bgImage;

+ (nonnull UITextField *)textFieldWithFrame:(CGRect)frame placeholder:(nullable NSString *)placeholder font:(nullable UIFont *)font textColor:(nullable UIColor *)textColor bgImage:(nullable UIImage *)bgImage leftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset;

@end
