//
//  MMPrivacyLinksView.m
//  My_Study
//
//  Created by hzw on 2023/2/17.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "MMPrivacyLinksView.h"
#import "ZWSDK.h"
#import "UIFont+Tool.h"
#import "Masonry.h"

@interface MMPrivacyLinksView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILabel *leftLabel;

@property (nonatomic, strong) UILabel *privacyLinkLabel;

@property (nonatomic, strong) UILabel *andLabel;

@property (nonatomic, strong) UILabel *userLinkLabel;

@end

@implementation MMPrivacyLinksView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setUI];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    return self;
}


- (void)_setUI {
    
    [self addSubview:self.leftLabel];
    [self addSubview:self.privacyLinkLabel];
    [self addSubview:self.andLabel];
    [self addSubview:self.userLinkLabel];

    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@30);
        make.top.bottom.equalTo(self);
    }];
    
    [self.privacyLinkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftLabel.mas_right);
        make.top.bottom.equalTo(self);
    }];
    
    [self.andLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.privacyLinkLabel.mas_right);
        make.top.bottom.equalTo(self);
    }];
    
    [self.userLinkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.andLabel.mas_right);
        make.top.bottom.equalTo(self);
    }];
}

#pragma mark - Action
- (void)privacyAction {
    NSLog(@"privacyAction");
}


- (void)userActioin {
    NSLog(@"userActioin");
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch{
    CGPoint touchPoint = [touch locationInView:self];
    
    if (CGRectGetMinX(self.userLinkLabel.frame) <= touchPoint.x &&
        touchPoint.x <= CGRectGetMaxX(self.userLinkLabel.frame)){
        [self userActioin];
//        [WM.router executeURLNoCallBack:@"/h5/system-setting/user-agreement"];
    } else if (CGRectGetMinX(self.privacyLinkLabel.frame) <= touchPoint.x &&
               touchPoint.x <= CGRectGetMaxX(self.privacyLinkLabel.frame)){
//        [WM.router executeURLNoCallBack:@"/h5/system-setting/privacy-policy"];
        [self privacyAction];
    }
    return NO;
}



#pragma mark -  Lazy loading

- (UILabel *)leftLabel {
    if (!_leftLabel) {
        _leftLabel = [UILabel labelWithFrame:CGRectZero text:@"阅读完整版" textColor:UIColorFromRGB(0x111111) font:[UIFont eh_regularFontSize:12] textAlignment:NSTextAlignmentCenter];
    }
    return _leftLabel;
}


- (UILabel *)privacyLinkLabel {
    if (!_privacyLinkLabel) {
        _privacyLinkLabel = [UILabel labelWithFrame:CGRectZero text:@"《隐私协议》" textColor:UIColor.blueColor font:[UIFont eh_regularFontSize:12] textAlignment:NSTextAlignmentCenter];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(privacyAction)];
        [_privacyLinkLabel addGestureRecognizer:tap];
    }
    return _privacyLinkLabel;
}

- (UILabel *)andLabel {
    if (!_andLabel) {
        _andLabel = [UILabel labelWithFrame:CGRectZero text:@"和" textColor:UIColorFromRGB(0x111111) font:[UIFont eh_regularFontSize:12] textAlignment:NSTextAlignmentCenter];
    }
    return _andLabel;
}

- (UILabel *)userLinkLabel {
    if (!_userLinkLabel) {
        _userLinkLabel = [UILabel labelWithFrame:CGRectZero text:@"《用户协议》" textColor:UIColor.blueColor font:[UIFont eh_regularFontSize:12] textAlignment:NSTextAlignmentCenter];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userActioin)];
        [_userLinkLabel addGestureRecognizer:tap];
    }
    return _userLinkLabel;
}

@end
