//
//  ZWRefreshHeader.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/29.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWRefreshHeader.h"
#import "ZWAnimationView.h"


#define AnimationHeight 18.0f
#define TopMargin 30.0f
#define TopMarginOfNavigatonBar 15.0f

@interface ZWRefreshHeader ()
{
    /** 显示刷新状态的label */
    __unsafe_unretained UILabel *_stateLabel;
    __unsafe_unretained ZWAnimationView *_animationView;
}

/** 所有状态对应的文字 */
@property (nonatomic, strong) NSMutableDictionary *stateTitles;
/** 文字距离圈圈、箭头的距离 */
@property (nonatomic, assign) CGFloat labelLeftInset;

@end

@implementation ZWRefreshHeader

- (ZWAnimationView *)animationView
{
    if (_animationView == nil) {
        ZWAnimationView *animationView = [[ZWAnimationView alloc] initWithFrame:CGRectMake(0, 0, AnimationHeight, AnimationHeight)];
        [self addSubview:_animationView = animationView];
    }
    
    return _animationView;
}

- (NSMutableDictionary *)stateTitles
{
    if (!_stateTitles) {
        self.stateTitles = [NSMutableDictionary dictionary];
    }
    return _stateTitles;
}

- (UILabel *)stateLabel
{
    if (!_stateLabel) {
        UILabel *label = [UILabel mj_label];
        label.font = [UIFont systemFontOfSize:13.0];
//        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_stateLabel = label];
    }
    return _stateLabel;
}

- (void)setImageIcon:(UIImage *)image circleColor:(UIColor *)circleColor textColor:(UIColor *)textColor
{
    self.animationView.imageIcon = image;
    self.animationView.circleColor = circleColor;
    self.stateLabel.textColor = textColor;
}

- (void)setTitle:(NSString *)title forState:(MJRefreshState)state
{
    if (title == nil) return;
    self.stateTitles[@(state)] = title;
    self.stateLabel.text = self.stateTitles[@(self.state)];
}

#pragma mark - 实现父类的方法
- (void)prepare
{
    [super prepare];
    
    // 初始化间距
    self.labelLeftInset = 8;
    
    // 初始化文字
    [self setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
    [self setTitle:@"释放刷新" forState:MJRefreshStatePulling];
    [self setTitle:@"正在刷新..." forState:MJRefreshStateRefreshing];
    [self setTitle:@"正在刷新..." forState:MJRefreshStateWillRefresh];
    
}

- (void)setPullingPercent:(CGFloat)pullingPercent
{
//    NSLog(@"--inset:%@, contentSize:%@", NSStringFromUIEdgeInsets(self.scrollView.adjustedContentInset), NSStringFromCGPoint(self.scrollView.contentOffset));
    [super setPullingPercent:pullingPercent];
    if (pullingPercent < 1.0) {
        [self.animationView startAnimating:pullingPercent];
    } else {
        [self.animationView stopAnimating];
    }
}

- (void)placeSubviews
{
    [super placeSubviews];
    
    self.animationView.mj_x = self.mj_w * 0.5 - self.animationView.mj_w  - 20;
    self.stateLabel.mj_x = self.animationView.mj_x + self.animationView.mj_w + self.labelLeftInset;
    self.stateLabel.mj_w = 100;
    self.stateLabel.mj_h = self.animationView.mj_h;
    
    if (self.scrollViewOriginalInset.top > 0) {
        self.animationView.mj_y = TopMarginOfNavigatonBar + self.offsetY;
        self.stateLabel.mj_y = TopMarginOfNavigatonBar + self.offsetY;
    } else {
        float height = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) + TopMarginOfNavigatonBar  + self.offsetY;
        self.animationView.mj_y = height;
        self.stateLabel.mj_y = height;
    }
}

- (void)setState:(MJRefreshState)state
{
//    CMLogDebug(LogBusinessBasicLib, @"setState---state:%@", @(self.state));
    MJRefreshCheckState
    // 根据状态做事情
    if (state == MJRefreshStatePulling) {
        [self.animationView stopAnimating];
        self.stateLabel.text = self.stateTitles[@(state)];
    } else if (state == MJRefreshStateIdle) {
        [self.animationView stopAnimating];
        self.stateLabel.text = self.stateTitles[@(state)];
    } else if (state == MJRefreshStateRefreshing) {
        [self.animationView startAnimating];
        self.stateLabel.text = self.stateTitles[@(state)];
    }
}




@end
