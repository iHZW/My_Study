//
//  MMScrollLabelView.h
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
#pragma mark - 跑马灯

#define MM_DEPRECATED_METHODS(explain) __attribute__((deprecated(explain)))
#define MM_DEPRECATED_MESSAGES(explain) __deprecated_msg(explain)

#import "UIView+MMFrame.h"
#import <UIKit/UIKit.h>

@class MMScrollLabelView;

@protocol MMScrollLabelViewDelegate <NSObject>
@optional
- (void)scrollLabelView:(MMScrollLabelView *)scrollLabelView didClickWithText:(NSString *)text atIndex:(NSInteger)index;

@end

@interface MMScrollLabelView : UIScrollView

typedef NS_ENUM(NSInteger, MMScrollLabelViewType) {
    MMScrollLabelViewTypeLeftRight = 0, // not supports scrollInset.top\bottom\right
    MMScrollLabelViewTypeUpDown,        // not supports scrollInset.top\bottom
    MMScrollLabelViewTypeFlipRepeat,    // not supports scrollInset.top\bottom
    MMScrollLabelViewTypeFlipNoRepeat   // not supports scrollInset.top\bottom
};

/*************WILL BE REMOVED IN FUTURE.********************/
#pragma mark - Deprecated property
/** Deprecated, please Use `scrollTitle` */
@property(copy, nonatomic) NSString *mm_scrollTitle MM_DEPRECATED_METHODS("Deprecated, please Use `scrollTitle`");
/** Deprecated, please Use `scrollType` */
@property(assign, nonatomic) MMScrollLabelViewType mm_scrollType MM_DEPRECATED_METHODS("Deprecated, please Use `scrollType`");
/** Deprecated, please Use `scrollVelocity` */
@property(assign, nonatomic) NSTimeInterval mm_scrollVelocity MM_DEPRECATED_METHODS("Deprecated, please Use `scrollVelocity`");
/** Deprecated, please Use `frame` */
@property(assign, nonatomic) CGRect mm_scrollContentSize MM_DEPRECATED_METHODS("Deprecated, please Use `frame`");
/** Deprecated, please Use `scrollTitleColor` */
@property(strong, nonatomic) UIColor *mm_scrollTitleColor MM_DEPRECATED_METHODS("Deprecated, please Use `scrollTitleColor`");
/*************ALL ABOVE.***********************************/

#pragma mark - On Used Property
@property(weak, nonatomic) id<MMScrollLabelViewDelegate> scrollLabelViewDelegate;
/** 滚动文字 */
@property(copy, nonatomic) NSString *scrollTitle;
/** 滚动类型 */
@property(assign, nonatomic) MMScrollLabelViewType scrollType;
/** 滚动速率([0, 10])，单位秒s，建议在初始化方法中设置该属性*/
@property(assign, nonatomic) NSTimeInterval scrollVelocity;
/** 文本颜色 */
@property(strong, nonatomic) UIColor *scrollTitleColor;
/** 滚动内部inset */
@property(assign, nonatomic) UIEdgeInsets scrollInset;
/** 每次循环滚动的间距 */
@property(assign, nonatomic) CGFloat scrollSpace;
/** 文字排版 */
@property(assign, nonatomic) NSTextAlignment textAlignment;
/** 字体大小 */
@property(strong, nonatomic) UIFont *font;
// 根据内容自适应宽度 Pending!!
@property(assign, nonatomic) BOOL autoWidth;

#pragma mark - setupAttributeTitle

- (void)setupAttributeTitle:(NSAttributedString *)attributeTitle;

#pragma mark - Instance Methods

- (instancetype)initWithTitle:(NSString *)scrollTitle
                         type:(MMScrollLabelViewType)scrollType
                     velocity:(NSTimeInterval)scrollVelocity
                      options:(UIViewAnimationOptions)options
                        inset:(UIEdgeInsets)inset;

#pragma mark - Factory Methods

+ (instancetype)scrollWithTitle:(NSString *)scrollTitle;

+ (instancetype)scrollWithTitle:(NSString *)scrollTitle
                           type:(MMScrollLabelViewType)scrollType;

+ (instancetype)scrollWithTitle:(NSString *)scrollTitle
                           type:(MMScrollLabelViewType)scrollType
                       velocity:(NSTimeInterval)scrollVelocity;

+ (instancetype)scrollWithTitle:(NSString *)scrollTitle
                           type:(MMScrollLabelViewType)scrollType
                       velocity:(NSTimeInterval)scrollVelocity
                        options:(UIViewAnimationOptions)options;

/**
 类初始化方法
 @param scrollTitle 滚动文本
 @param scrollType 滚动类型
 @param scrollVelocity 滚动速率
 @param options Now, supports the types of MMScrollLabelViewTypeFlipRepeat\NoRepeat only.
 @param inset just edgeInset.
 */
+ (instancetype)scrollWithTitle:(NSString *)scrollTitle
                           type:(MMScrollLabelViewType)scrollType
                       velocity:(NSTimeInterval)scrollVelocity
                        options:(UIViewAnimationOptions)options
                          inset:(UIEdgeInsets)inset;

#pragma mark - Operation Methods
/**
 *  开始滚动
 */
- (void)beginScrolling;
/**
 *  停止滚动
 */
- (void)endScrolling;

/**
 *  暂停滚动(暂不支持恢复)
 */
- (void)pauseScrolling;

/** 重置滚动视图 */
- (void)resetScrollLabelView;

@end

@interface MMScrollLabelView (MMArray)

/**
 类初始化方法
 @param scrollTexts 滚动文本数组
 */
- (instancetype)initWithTextArray:(NSArray *)scrollTexts
                             type:(MMScrollLabelViewType)scrollType
                         velocity:(NSTimeInterval)scrollVelocity
                          options:(UIViewAnimationOptions)options
                            inset:(UIEdgeInsets)inset;

+ (instancetype)scrollWithTextArray:(NSArray *)scrollTexts
                               type:(MMScrollLabelViewType)scrollType
                           velocity:(NSTimeInterval)scrollVelocity
                            options:(UIViewAnimationOptions)options
                              inset:(UIEdgeInsets)inset;

@end

@interface MMScrollLabelView (MMScrollLabelViewDeprecated)

+ (instancetype)mm_setScrollTitle:(NSString *)scrollTitle MM_DEPRECATED_MESSAGES("Method deprecated. Use `+ scrollWithTitle:`");

+ (instancetype)mm_setScrollTitle:(NSString *)scrollTitle
                       scrollType:(MMScrollLabelViewType)scrollType MM_DEPRECATED_MESSAGES("Method deprecated. Use `+ scrollWithTitle:type:`");

+ (instancetype)mm_setScrollTitle:(NSString *)scrollTitle
                       scrollType:(MMScrollLabelViewType)scrollType
                   scrollVelocity:(NSTimeInterval)scrollVelocity MM_DEPRECATED_MESSAGES("Method deprecated. Use `+ scrollWithTitle:type:velocity:`");

+ (instancetype)mm_setScrollTitle:(NSString *)scrollTitle
                       scrollType:(MMScrollLabelViewType)scrollType
                   scrollVelocity:(NSTimeInterval)scrollVelocity
                          options:(UIViewAnimationOptions)options MM_DEPRECATED_MESSAGES("Method deprecated. Use `+ scrollWithTitle:type:velocity:options:`");

+ (instancetype)mm_setScrollTitle:(NSString *)scrollTitle
                       scrollType:(MMScrollLabelViewType)scrollType
                   scrollVelocity:(NSTimeInterval)scrollVelocity
                          options:(UIViewAnimationOptions)options
                            inset:(UIEdgeInsets)inset MM_DEPRECATED_MESSAGES("Method deprecated. Use `+ scrollWithTitle:type:velocity:options:inset:`");
@end

@interface UIView (MMAdditions)

- (void)addTapGesture:(id)target sel:(SEL)selector;

@end
