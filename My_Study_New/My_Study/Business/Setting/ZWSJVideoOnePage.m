//
//  ZWSJVideoOnePage.m
//  My_Study
//
//  Created by hzw on 2023/7/21.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "ZWSJVideoOnePage.h"
#import <SJVideoPlayer/SJVideoPlayer.h>


@interface ZWSJVideoOnePage ()

@property (nonatomic, strong) SJVideoPlayer *player;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) NSInteger count;

@end

@implementation ZWSJVideoOnePage

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setUI];
    self.count = 1;
    
    self.player.rotationManager.disabledAutorotation = YES;
    
}


- (void)_setUI {
    [self.view addSubview:self.player.view];
    [self.player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.offset(20);
        }
        make.left.right.offset(0);
        make.height.equalTo(self.player.view.mas_width).multipliedBy(9 / 16.0);
    }];
    
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.player.view.mas_bottom).offset(10.0);
        make.height.mas_equalTo(500);
    }];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.player vc_viewDidAppear];
    
    NSString *url = @"https://dh2.v.netease.com/2017/cg/fxtpty.mp4";
    if (ValidString(url)) {
        NSURL *medioUrl = [NSURL URLWithString:url];
        SJVideoPlayerURLAsset *asset = [SJVideoPlayerURLAsset.alloc initWithURL:medioUrl];
        self.player.URLAsset = asset;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player vc_viewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.player vc_viewDidDisappear];
}

- (void)tapAction {
//    SJControlLayerIdentifier
    self.count += 1;
    [self.player.switcher switchControlLayerForIdentifier: (LONG_MAX - self.count)];
    
    if (self.count >= 7) {
        self.count = 0;
    }
}


#pragma mark -  Lazy loading
- (SJVideoPlayer *)player {
    if (!_player) {
        _player = SJVideoPlayer.player;
    }
    return _player;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 500)];
        _contentView.backgroundColor = UIColor.cyanColor;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [_contentView addGestureRecognizer:tap];
    }
    return _contentView;
}



@end
