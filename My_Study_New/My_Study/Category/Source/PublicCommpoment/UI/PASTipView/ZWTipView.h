//
//  PASTipView.h
//  TZYJ_IPhone
//
//  Created by Howard on 15/11/26.
//
//

#import <UIKit/UIKit.h>

#define kPromptWords             @"没有更多内容了~"
#define kPromptWordsForMyStock   @"您还没有添加自选股呦~"


typedef void(^PASTipViewBlock)(void);

@interface ZWTipView : UIView

/** icon图标显示高度  */
@property (nonatomic, assign) CGFloat tipIconHeight;
/** 提示文字显示高度 */
@property (nonatomic, assign) CGFloat tipInfoViewHeight;
/** icon背景区域  */
@property (nonatomic, assign) CGRect tipIconBGRect;
/** Block回调  */
@property (nonatomic, copy) PASTipViewBlock tipViewBlock;
/** 显示icon的边缘  */
@property (nonatomic, assign) BOOL showIconBorder;
/** iconView的文字  */
@property (nonatomic, copy) NSString *tipInfo;
/** iconView  */
@property (nonatomic, strong) UIImageView *tipIconView;
/** 文本view  */
@property (nonatomic, strong) UILabel *tipInfoView;

- (instancetype)initWithFrame:(CGRect)frame tipImage:(UIImage *)tipImage tipInfo:(NSString *)tipInfo;

- (void)showTipView;

- (void)hiddenTipView;

- (void)showTipViewWithNoAnimation;

- (void)hiddenTipViewWithNoAnimation;

- (void)setTipInfoViewString:(NSString *)tipInfo;

@end
