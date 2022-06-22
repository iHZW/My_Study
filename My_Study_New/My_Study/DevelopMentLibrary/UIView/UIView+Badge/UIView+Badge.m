//
//  UIView+Badge.m
//  TZYJ_IPhone
//
//  Created by Weirdln on 15/9/30.
//
//

#import "UIView+Badge.h"
#import <objc/runtime.h>
#import "CAAnimation+Animation.h"

@implementation UIView (Badge)

- (UIView *)getActualBadgeSuperView
{
    return self;
}

#pragma mark -- public methods
/**
 *  show badge with red dot style and BadgeAnimTypeNone by default.
 */
- (void)showBadge
{
    [self showBadgeWithStyle:BadgeStyleRedDot value:@"0" animationType:BadgeAnimTypeNone];
}

/**
 *  showBadge
 *
 *  @param style BadgeStyle type
 *  @param value (if 'style' is BadgeStyleRedDot or BadgeStyleNew,
 *                this value will be ignored. In this case, any value will be ok.)
 */
- (void)showBadgeWithStyle:(BadgeStyle)style value:(NSString *)value animationType:(BadgeAnimType)aniType
{
    self.aniType = aniType;
    switch (style) {
        case BadgeStyleRedDot:
            [self showRedDotBadgeWithValue:value];
            break;
        case BadgeStyleNumber:
            [self showNumberBadgeWithValue:value];
            break;
        case BadgeStyleNew:
            [self showNewBadge];
            break;
        case BadgeStyleNewImage:
            [self showNewImageBadge];
            break;
        default:
            break;
    }
    if (aniType != BadgeAnimTypeNone) {
        [self beginAnimation];
    }
}

/**
 *  clear badge
 */
- (void)clearBadge
{
    self.badge.hidden = YES;
}

#pragma mark -- private methods
- (void)showRedDotBadgeWithValue:(NSString *)value
{
    if ([value integerValue] == 0) {
        [self clearBadge];
    }
    else {
        [self showRedDotBadge];
    }
}

- (void)showRedDotBadge
{
    [self badgeInit];
    //if badge has been displayed and, in addition, is was not red dot style, we must update UI.
    if (self.badge.tag != BadgeStyleRedDot) {
        self.badge.text = @"";
        self.badge.tag = BadgeStyleRedDot;
        
        CGRect frame = self.badge.frame;
        frame.size.width = PASFactor(8);
        frame.size.height = PASFactor(8);
        self.badge.frame = frame;
        
        self.badge.center = CGPointMake(CGRectGetWidth(self.frame) + 2 + self.badgeCenterOffset.x, self.badgeCenterOffset.y);
        self.badge.layer.cornerRadius = CGRectGetHeight(self.badge.frame) / 2;
    }
    self.badge.hidden = NO;
}

- (void)showNewBadge
{
    [self badgeInit];
    //if badge has been displayed and, in addition, is was not red dot style, we must update UI.
    if (self.badge.tag != BadgeStyleNew) {
        self.badge.text = @"new";
        self.badge.tag = BadgeStyleNew;
        
        CGRect frame = self.badge.frame;
        frame.size.width = 20;
        frame.size.height = 13;
        self.badge.frame = frame;
        
        self.badge.center = CGPointMake(CGRectGetWidth(self.frame) + 2 + self.badgeCenterOffset.x, self.badgeCenterOffset.y);
        self.badge.font = [UIFont boldSystemFontOfSize:9];
        self.badge.layer.cornerRadius = CGRectGetHeight(self.badge.frame) / 3;
    }
    self.badge.hidden = NO;
}

- (void)showNewImageBadge
{
    [self badgeInit];
    //if badge has been displayed and, in addition, is was not red dot style, we must update UI.
    if (self.badge.tag != BadgeStyleNewImage) {
        self.badge.tag = BadgeStyleNewImage;
        
        CGRect frame = self.badge.frame;
        frame.size.width = 24;
        frame.size.height = 12;
        self.badge.frame = frame;
        self.badge.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"home_news_new"]];
        self.badge.layer.cornerRadius = 0;
        self.badge.center = CGPointMake(CGRectGetWidth(self.frame) + 2 + self.badgeCenterOffset.x, self.badgeCenterOffset.y);
    }
    self.badge.hidden = NO;
}

- (void)showNumberBadgeWithValue:(NSString *)value
{
    NSInteger val = [value integerValue];
    if (val < 0) {
        return;
    }
    [self badgeInit];
    self.badge.hidden = (val == 0);
    self.badge.tag = BadgeStyleNumber;
    self.badge.font = [UIFont systemFontOfSize:11];
    self.badge.text = (val >= self.maxBadgeNumber ? [NSString stringWithFormat:@"%@+",@(self.maxBadgeNumber)] : [NSString stringWithFormat:@"%@", @(val)]);
    self.badge.lineBreakMode = NSLineBreakByClipping;
    [self adjustLabelWidth:self.badge];
    CGRect frame = self.badge.frame;
//    frame.size.width = 24;
    frame.size.width = 22;
    frame.size.height = 18;
    if(CGRectGetWidth(frame) < CGRectGetHeight(frame)) {
        frame.size.width = CGRectGetHeight(frame);
    }
    self.badge.frame = frame;
    self.badge.center = CGPointMake(CGRectGetWidth(self.frame) + 2 + self.badgeCenterOffset.x, self.badgeCenterOffset.y);
    self.badge.layer.cornerRadius = CGRectGetHeight(self.badge.frame) / 2;
}

//lazy loading
- (void)badgeInit
{
    if (self.badgeBgColor == nil) {
        self.badgeBgColor = [UIColor redColor];
    }
    if (self.badgeTextColor == nil) {
        self.badgeTextColor = [UIColor whiteColor];
    }
    
    if (nil == self.badge) {
        CGFloat redotWidth = PASFactor(8);
        CGRect frm = CGRectMake(CGRectGetWidth(self.frame), -redotWidth, redotWidth, redotWidth);
        self.badge = [[UILabel alloc] initWithFrame:frm];
        self.badge.textAlignment = NSTextAlignmentCenter;
        self.badge.center = CGPointMake(CGRectGetWidth(self.frame) + 2 + self.badgeCenterOffset.x, self.badgeCenterOffset.y);
        self.badge.backgroundColor = self.badgeBgColor;
        self.badge.textColor = self.badgeTextColor;
        self.badge.text = @"";
        self.badge.tag = BadgeStyleRedDot;//red dot by default
        self.badge.layer.cornerRadius = CGRectGetWidth(self.badge.frame) / 2;
        self.badge.layer.masksToBounds = YES;//very important
        self.badge.hidden = NO;
        self.maxBadgeNumber = 99;
        [[self getActualBadgeSuperView] addSubview:self.badge];
    }
}

#pragma mark --  other private methods
- (void)adjustLabelWidth:(UILabel *)label
{
    [label setNumberOfLines:0];
    NSString *s = [label.text length] > 0 ? label.text : @"value";
    UIFont *font = [label font];
#if 0
    CGSize size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds),2000);
    CGSize labelsize = [s sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
#else
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize labelsize = [s sizeWithAttributes:@{NSFontAttributeName : font, NSParagraphStyleAttributeName : paragraphStyle}];
#endif
    
    CGRect frame = label.frame;
    frame.size = labelsize;
    [label setFrame:frame];
}

#pragma mark -- animation

//if u want to add badge animation type, follow steps bellow:
//1. go to definition of BadgeAnimType and add new type
//2. go to category of CAAnimation+WAnimation to add new animation interface
//3. call that new interface here
- (void)beginAnimation
{
    switch(self.aniType) {
        case BadgeAnimTypeBreathe:
            [self.badge.layer addAnimation:[CAAnimation opacityForever_Animation:1.4]
                                    forKey:kBadgeBreatheAniKey];
            break;
        case BadgeAnimTypeShake:
            [self.badge.layer addAnimation:[CAAnimation shake_AnimationRepeatTimes:CGFLOAT_MAX
                                                                          durTimes:1
                                                                            forObj:self.badge.layer]
                                    forKey:kBadgeShakeAniKey];
            break;
        case BadgeAnimTypeScale:
            [self.badge.layer addAnimation:[CAAnimation scaleFrom:1.4
                                                          toScale:0.6
                                                         durTimes:1
                                                              rep:MAXFLOAT]
                                    forKey:kBadgeScaleAniKey];
            break;
        case BadgeAnimTypeBounce:
            [self.badge.layer addAnimation:[CAAnimation bounce_AnimationRepeatTimes:CGFLOAT_MAX
                                                                           durTimes:1
                                                                             forObj:self.badge.layer]
                                    forKey:kBadgeBounceAniKey];
            break;
        case BadgeAnimTypeNone:
        default:
            break;
    }
}


- (void)removeAnimation
{
    if (self.badge) {
        [self.badge.layer removeAllAnimations];
    }
}


#pragma mark -- setter/getter
- (UILabel *)badge
{
    return objc_getAssociatedObject(self, &badgeLabelKey);
}

- (void)setBadge:(UILabel *)label
{
    objc_setAssociatedObject(self, &badgeLabelKey, label, OBJC_ASSOCIATION_RETAIN);
}

- (UIColor *)badgeBgColor
{
    return objc_getAssociatedObject(self, &badgeBgColorKey);
}

- (void)setBadgeBgColor:(UIColor *)badgeBgColor
{
    objc_setAssociatedObject(self, &badgeBgColorKey, badgeBgColor, OBJC_ASSOCIATION_RETAIN);
    if (self.badge) {
        self.badge.backgroundColor = badgeBgColor;
    }
}

- (UIColor *)badgeTextColor
{
    return objc_getAssociatedObject(self, &badgeTextColorKey);
}

- (void)setBadgeTextColor:(UIColor *)badgeTextColor
{
    objc_setAssociatedObject(self, &badgeTextColorKey, badgeTextColor, OBJC_ASSOCIATION_RETAIN);
    if (self.badge) {
        self.badge.textColor = badgeTextColor;
    }
}

- (BadgeAnimType)aniType
{
    id obj = objc_getAssociatedObject(self, &badgeAniTypeKey);
    if(obj != nil && [obj isKindOfClass:[NSNumber class]])
    {
        return [obj integerValue];
    }
    else
        return BadgeAnimTypeNone;
}

- (void)setAniType:(BadgeAnimType)aniType
{
    NSNumber *numObj = @(aniType);
    objc_setAssociatedObject(self, &badgeAniTypeKey, numObj, OBJC_ASSOCIATION_RETAIN);
    if (self.badge) {
        [self removeAnimation];
        [self beginAnimation];
    }
}

- (CGRect)badgeFrame
{
    id obj = objc_getAssociatedObject(self, &badgeFrameKey);
    if (obj != nil && [obj isKindOfClass:[NSDictionary class]] && [obj count] == 4) {
        CGFloat x = [obj[@"x"] floatValue];
        CGFloat y = [obj[@"y"] floatValue];
        CGFloat width = [obj[@"width"] floatValue];
        CGFloat height = [obj[@"height"] floatValue];
        return  CGRectMake(x, y, width, height);
    } else
        return CGRectZero;
}

- (void)setBadgeFrame:(CGRect)badgeFrame
{
    NSDictionary *frameInfo = @{@"x" : @(badgeFrame.origin.x), @"y" : @(badgeFrame.origin.y),
                                @"width" : @(badgeFrame.size.width), @"height" : @(badgeFrame.size.height)};
    objc_setAssociatedObject(self, &badgeFrameKey, frameInfo, OBJC_ASSOCIATION_RETAIN);
    if (self.badge) {
        self.badge.frame = badgeFrame;
    }
}

- (CGPoint)badgeCenterOffset
{
    id obj = objc_getAssociatedObject(self, &badgeCenterOffsetKey);
    if (obj != nil && [obj isKindOfClass:[NSDictionary class]] && [obj count] == 2) {
        CGFloat x = [obj[@"x"] floatValue];
        CGFloat y = [obj[@"y"] floatValue];
        return CGPointMake(x, y);
    } else
        return CGPointZero;
}

- (void)setBadgeCenterOffset:(CGPoint)badgeCenterOff
{
    NSDictionary *cenerInfo = @{@"x" : @(badgeCenterOff.x), @"y" : @(badgeCenterOff.y)};
    objc_setAssociatedObject(self, &badgeCenterOffsetKey, cenerInfo, OBJC_ASSOCIATION_RETAIN);
    if (self.badge) {
        self.badge.center = CGPointMake(CGRectGetWidth(self.frame) + 2 + badgeCenterOff.x, badgeCenterOff.y);
    }
}

- (NSInteger)maxBadgeNumber
{
    id obj = objc_getAssociatedObject(self, &badgeMaxBadgeNumberKey);
    if(obj != nil && [obj isKindOfClass:[NSNumber class]])
    {
        return [obj integerValue];
    }
    else
        return 0;
}

- (void)setMaxBadgeNumber:(NSInteger)maxBadgeNumber
{
    NSNumber *numObj = @(maxBadgeNumber);
    objc_setAssociatedObject(self, &badgeMaxBadgeNumberKey, numObj, OBJC_ASSOCIATION_RETAIN);
}


@end

#pragma mark -- UIBarItem

@implementation UIBarItem (Badge)

- (UIView *)getActualBadgeSuperView
{
    return [self valueForKeyPath:@"_view"];//use KVC to hack actual view
}


@end
