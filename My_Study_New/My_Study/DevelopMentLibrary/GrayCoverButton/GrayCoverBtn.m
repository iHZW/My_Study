//
//  GrayCoverBtn.m
//  TZYJ_IPhone
//
//  Created by vincent  on 15/7/9.
//
//

#import "GrayCoverBtn.h"

@implementation GrayCoverBtn

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addTarget:self action:@selector(action_touchDown:) forControlEvents:UIControlEventTouchDragInside];
        [self addTarget:self action:@selector(action_touchDown:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(action_touchDown:) forControlEvents:UIControlEventTouchDragEnter];
        [self addTarget:self action:@selector(action_touchOut:) forControlEvents:UIControlEventTouchDragOutside];
        [self addTarget:self action:@selector(action_touchOut:) forControlEvents:UIControlEventTouchUpOutside];
        [self addTarget:self action:@selector(action_touchOut:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(action_touchOut:) forControlEvents:UIControlEventTouchCancel];
        [self addTarget:self action:@selector(action_touchOut:) forControlEvents:UIControlEventTouchDragExit];

    }
    return self;
}

- (void)action_touchDown:(UIButton *)sender
{
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:self.bounds];
        _coverView.userInteractionEnabled = NO;
        if (self.actionColor) {
            _coverView.backgroundColor = self.actionColor;
        } else {
            _coverView.alpha = 0.3;
            _coverView.backgroundColor = [UIColor blackColor];
        }
    }
    [self addSubview:_coverView];
}

- (void)action_touchOut:(UIButton *)sender
{
    if ([_coverView superview]) {
        [_coverView removeFromSuperview];
    }
}
@end
