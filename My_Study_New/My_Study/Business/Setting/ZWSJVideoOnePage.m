//
//  ZWSJVideoOnePage.m
//  My_Study
//
//  Created by hzw on 2023/7/21.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "SJSourceURLs.h"
#import "ZWSJVideoOnePage.h"
#import <SJUIKit/SJAttributesFactory.h>
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <objc/message.h>
#import "ZWLaunchManage.h"

@interface SJVideoPlayer (SJPictureInPictureAdditions)
@property (nonatomic, strong, nullable) UIViewController *pip_sourceViewController;
@end

@implementation SJVideoPlayer (SJPictureInPictureAdditions)
- (void)setPip_sourceViewController:(UIViewController *)pip_sourceViewController {
    objc_setAssociatedObject(self, @selector(pip_sourceViewController), pip_sourceViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable UIViewController *)pip_sourceViewController {
    return objc_getAssociatedObject(self, _cmd);
}
@end

@interface UIViewController (SJPictureInPictureAdditions)
+ (UIViewController *)pip_appTopViewController;
@end

@implementation UIViewController (SJPictureInPictureAdditions)
+ (UIViewController *)pip_appTopViewController {
    UIViewController *vc = UIApplication.sharedApplication.keyWindow.rootViewController;
    while ([vc isKindOfClass:[UINavigationController class]] ||
           [vc isKindOfClass:[UITabBarController class]] ||
           vc.presentedViewController) {
        if ([vc isKindOfClass:[UINavigationController class]])
            vc = [(UINavigationController *)vc topViewController];
        if ([vc isKindOfClass:[UITabBarController class]])
            vc = [(UITabBarController *)vc selectedViewController];
        if (vc.presentedViewController)
            vc = vc.presentedViewController;
    }
    return vc;
}
@end

@interface ZWSJVideoOnePage ()

@property (nonatomic, strong) SJVideoPlayer *player;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) NSInteger count;

@end

@implementation ZWSJVideoOnePage

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p1);
    [self _setUI];
    self.count = 1;
    [self.player play];
    self.player.rotationManager.disabledAutorotation = YES;
}

- (void)_setUI {
//    [self defaultVideoPlayer];
    [self loadPip];
}

- (void)loadPip{
    self.edgesForExtendedLayout = UIRectEdgeNone;

    UIView *superview         = [UIView.alloc initWithFrame:CGRectZero];
    superview.backgroundColor = UIColor.blackColor;
    [self.view addSubview:superview];
    [superview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.centerY.offset(0);
        make.height.mas_equalTo(superview.mas_width).multipliedBy(9 / 16.0);
    }];

    _player                       = [SJVideoPlayer.alloc init];
    _player.URLAsset              = [SJVideoPlayerURLAsset.alloc initWithURL:SourceURL0];
    _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _player.view.frame            = superview.bounds;
    if (self.currentTime > 0) {
        [_player seekToTime:self.currentTime completionHandler:^(BOOL finished) {
            NSLog(@"finished = %@", @(finished));
        }];
    }
    [superview addSubview:_player.view];

    [_player.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol> _Nonnull make) {
                                     make.append(@"请右上角点击画中画按钮, 进入画中画模式");
                                     make.font([UIFont systemFontOfSize:14]);
                                     make.textColor(UIColor.whiteColor);
                                     make.alignment(NSTextAlignmentCenter);
                                 }] duration:-1];

    if (@available(iOS 14.0, *)) {
        __weak typeof(self) _self                                        = self;
        _player.playbackObserver.pictureInPictureStatusDidChangeExeBlock = ^(SJVideoPlayer *player) {
            __strong typeof(_self) self = _self;
            if (self == nil) return;
            switch (player.playbackController.pictureInPictureStatus) {
                case SJPictureInPictureStatusRunning: {
                    player.pip_sourceViewController = self;

                    // 进入画中画后, 退出当前的控制器
                    if (player.isFullscreen) {
                        [player rotate:SJOrientation_Portrait animated:YES completion:^(__kindof SJBaseVideoPlayer *_Nonnull player) {
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                    } else if (player.isFitOnScreen) {
                        [player setFitOnScreen:NO animated:YES completionHandler:^(__kindof SJBaseVideoPlayer *_Nonnull player) {
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                    } else {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                } break;
                case SJPictureInPictureStatusStopped: {
                    player.pip_sourceViewController = nil;
                } break;
                default:
                    break;
            }
        };

        _player.playbackController.restoreUserInterfaceForPictureInPictureStop = ^(id<SJVideoPlayerPlaybackController> _Nonnull controller, void (^_Nonnull completionHandler)(BOOL)) {
            __strong typeof(_self) self = _self;
            if (self == nil) return;
            UIViewController *topViewController = UIViewController.pip_appTopViewController;
            UINavigationController *nav         = topViewController.navigationController;
            if (nav != nil) [nav pushViewController:self animated:YES];
            completionHandler(YES);
        };
    }
}

#pragma mark - 加载默认VideoPlayer
- (void)defaultVideoPlayer {
    self.player = SJVideoPlayer.player;
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
    
    [ZWLaunchManage sharedInstance].isSJ = YES;
    [_player vc_viewDidAppear];

//    NSString *url = @"https://dh2.v.netease.com/2017/cg/fxtpty.mp4";
//    if (ValidString(url)) {
//        NSURL *medioUrl              = [NSURL URLWithString:url];
//        SJVideoPlayerURLAsset *asset = [SJVideoPlayerURLAsset.alloc initWithURL:medioUrl];
//        self.player.URLAsset         = asset;
//    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_player vc_viewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [ZWLaunchManage sharedInstance].isSJ = NO;
    if ( @available(iOS 14.0, *) ) {
        if ( _player.playbackController.pictureInPictureStatus != SJPictureInPictureStatusRunning ) [_player vc_viewDidDisappear];
    }
}

- (void)tapAction {
    //    SJControlLayerIdentifier
    self.count += 1;
    [self.player.switcher switchControlLayerForIdentifier:(LONG_MAX - self.count)];

    if (self.count >= 7) {
        self.count = 0;
    }
}

#pragma mark -  Lazy loading
//- (SJVideoPlayer *)player {
//    if (!_player) {
//        _player = SJVideoPlayer.player;
//    }
//    return _player;
//}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView                 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 500)];
        _contentView.backgroundColor = UIColor.cyanColor;
        UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [_contentView addGestureRecognizer:tap];
    }
    return _contentView;
}

@end
