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

@interface PASTipView : UIView

@property (nonatomic, assign) CGFloat tipIconHeight;            //< icon图标显示高度
@property (nonatomic, assign) CGFloat tipInfoViewHeight;        //< 提示文字显示高度
@property (nonatomic, assign) CGRect tipIconBGRect;             //< icon背景区域
@property (nonatomic, copy) PASTipViewBlock tipViewBlock;       //< Block回调
@property (nonatomic, assign) BOOL showIconBorder;              //< 显示icon的边缘
@property (nonatomic, copy) NSString *tipInfo;      //< iconView的文字
@property (nonatomic, strong) UIImageView *tipIconView;
@property (nonatomic, strong) UILabel *tipInfoView; /**< 文本view */

- (instancetype)initWithFrame:(CGRect)frame tipImage:(UIImage *)tipImage tipInfo:(NSString *)tipInfo;

- (void)showTipView;

- (void)hiddenTipView;

- (void)showTipViewWithNoAnimation;

- (void)hiddenTipViewWithNoAnimation;

- (void)setTipInfoViewString:(NSString *)tipInfo;

@end
