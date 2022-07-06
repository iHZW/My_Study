//
//  UIView+Badge.h
//  TZYJ_IPhone
//
//  Created by Weirdln on 15/9/30.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BadgeStyle)
{
    BadgeStyleRedDot = 0,          /* red dot style */
    BadgeStyleNumber,              /* badge with number */
    BadgeStyleNew,                  /* badge with a fixed text "new" */
    BadgeStyleNewImage              /* badge with a new imageview */
};

typedef NS_ENUM(NSUInteger, BadgeAnimType)
{
    BadgeAnimTypeNone = 0,         /* without animation, badge stays still */
    BadgeAnimTypeScale,            /* scale effect */
    BadgeAnimTypeShake,            /* shaking effect */
    BadgeAnimTypeBounce,           /* bouncing effect */
    BadgeAnimTypeBreathe           /* breathing light effect, which makes badge more attractive */
};


//key for associative methods during runtime
static char badgeLabelKey;
static char badgeBgColorKey;
static char badgeTextColorKey;
static char badgeAniTypeKey;
static char badgeFrameKey;
static char badgeCenterOffsetKey;
static char badgeMaxBadgeNumberKey;


@protocol BadgeProtocol <NSObject>

@required
/**
 *  Maybe self is not kind of UIView, it is not able to directly attach badge.
 This method is used to find actual view (non-nil) inside UIBarButtonItem instance.
 *
 *  @return view
 */
- (UIView *)getActualBadgeSuperView;

@end

@interface UIView (Badge) <BadgeProtocol>

@property (nonatomic, strong) UILabel *badge;           /* badge entity, which is adviced not to set manually */
@property (nonatomic, strong) UIColor *badgeBgColor;    /* red color by default if not set */
@property (nonatomic, strong) UIColor *badgeTextColor;  /* white color by default if not set */
@property (nonatomic) CGRect badgeFrame;        /* we have optimized the badge frame and center.
                                                         This property is adviced not to set manually */

@property (nonatomic) CGPoint  badgeCenterOffset;/* offset from right-top corner. {0,0} by default */
/* For x, negative number means left offset
 For y, negative number means bottom offset*/

@property (nonatomic) BadgeAnimType aniType;   /* NOTE that this is not animation type of badge's
                                                         appearing, nor  hidding*/

 /** if badge value is above maxBadgeNumber, @"..." will be printed */
@property (nonatomic) NSInteger maxBadgeNumber;

/**
 *  show badge with red dot style and BadgeAnimTypeNone by default.
 */
- (void)showBadge;

/**
 *  shoBadge
 *
 *  @param style BadgeStyle type
 *  @param value (if 'style' is BadgeStyleRedDot or BadgeStyleNew,
 this value will be ignored. In this case, any value will be ok.)
 *   @param aniType 类型
 */
- (void)showBadgeWithStyle:(BadgeStyle)style
                     value:(NSString *)value
             animationType:(BadgeAnimType)aniType;


/**
 *  clear badge
 */
- (void)clearBadge;

@end



#pragma mark -- UIBarItem

@interface UIBarItem (Badge)

@end
