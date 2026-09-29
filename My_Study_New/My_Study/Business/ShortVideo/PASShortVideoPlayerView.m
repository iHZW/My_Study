//
//  PASShortVideoPlayerView.m
//  PASInfoLib
//
//  Created by 张勇勇(证券总部经纪业务事业部技术开发团队) on 2020/11/24.
//

#import "PASShortVideoPlayerView.h"
#import "ZWSDK.h"
#import "Masonry.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMTime.h>
#import "UIColor+Extensions.h"
#import "UIImageView+WebCache.h"
#import "PASShortVideoItemView.h"
#import "PASShortVideoModel.h"
//#import "PASLoginManager.h"
#import "PASShortVideoAgreeView.h"
#import "PASShortVideoAgreeResponse.h"
//#import "PASUserInfoBridgeModule.h"
#import "ZYWeakObject.h"
//#import "PASABTestConfig.h"


#define ItemWidth 36.0f
#define ItemHeight 55.0f
#define LeftMargin 15.0f
#define SliderHeight 10.0f
#define ImageViewHeight 211.0f
#define SliderViewBottomMargin 20.0f

@interface PASShortVideoPlayerView ()

@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) UIView *playerTapView;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UIButton *playOrpauseButton;
@property (nonatomic, strong) UISlider *sliderView;
@property (nonatomic, strong) UILabel *playtimeLabel;
@property (nonatomic, strong) PASShortVideoItemView *shareItemView;
@property (nonatomic, strong) PASShortVideoItemView *commentItemView;
@property (nonatomic, strong) PASShortVideoAgreeView *upperItemView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UILabel *toastView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong) PASShortVideoItemModel *videoModel;

@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, weak) id palyerObserver;

@property (nonatomic, strong) NSString *playTotalTime;
@property (nonatomic, assign) BOOL autoPlay;
@property (nonatomic, assign) BOOL stopped;
@property (nonatomic, assign) BOOL noPlayUrl;
@property (nonatomic, assign) NSTimeInterval startTime;

@end

@implementation PASShortVideoPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGB(0x000000);
        self.playerView = [UIView new];
        [self addSubview:self.playerView];
        [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self);
        }];
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[
            (id)UIColorFromRGBA(0x000000, 0.0).CGColor,
            (id)UIColorFromRGBA(0x000000, 0.5).CGColor,
        ];
        self.gradientLayer = gradientLayer;
        
        self.playerTapView = [UIView new];
        [self.playerView addSubview:self.playerTapView];
        
        self.imageView = [[UIImageView alloc] init];
        [self addSubview:self.imageView];
        
        self.titleLabel = [UILabel new];
        self.titleLabel.textColor = UIColorFromRGB(0xffffff);
        self.titleLabel.font = PASBFont(17.0f);
        self.titleLabel.numberOfLines = 2;
        [self addSubview:self.titleLabel];
        
        self.descriptionLabel = [UILabel new];
        self.descriptionLabel.textColor = UIColorFromRGB(0xffffff);
        self.descriptionLabel.font = PASFont(14.0f);
        self.descriptionLabel.numberOfLines = 4;
        [self addSubview:self.descriptionLabel];
        
        self.playOrpauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.playOrpauseButton setImage:[UIImage imageNamed:@"shortvideo_play"] forState:UIControlStateSelected];
        [self.playOrpauseButton setImage:[UIImage imageNamed:@"shortvideo_pause"] forState:UIControlStateNormal];
        self.playOrpauseButton.selected = NO;
        [self.playOrpauseButton addTarget:self action:@selector(playOrpauseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.playOrpauseButton];
        
        self.playtimeLabel = [UILabel new];
        self.playtimeLabel.textColor = UIColorFromRGB(0xffffff);
        self.playtimeLabel.font = PASFont(12.0f);
        self.playtimeLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.playtimeLabel];
        
        self.shareItemView = [[PASShortVideoItemView alloc] initWithFrame:CGRectZero];
        @pas_weakify_self
        self.shareItemView.block = ^{
            @pas_strongify_self
            if (self.delegate) {
                [self.delegate shareShortVideo:self.videoModel completion:^(BOOL success) {
                    if (success) {
                        NSInteger count = self.videoModel.shareInfo.count;
                        count += 1;
                        self.videoModel.shareInfo.count = count;
                        [self.shareItemView setTextNumber:count];
                    }
                }];
            }
        };
        [self.shareItemView setImageName:@"shortvideo_share" selectImageName:nil];
        [self addSubview:self.shareItemView];
        
        self.commentItemView = [[PASShortVideoItemView alloc] initWithFrame:CGRectZero];
        [self.commentItemView setImageName:@"shortvideo_comment" selectImageName:nil];
        self.commentItemView.block = ^{
            @pas_strongify_self
//            [PASLoginManager gotoPageWithNeedUserRights:UserRights_Weak matchRightsBlock:^(UserRights currentRights) {
//                if (self.delegate) {
//                    [self.delegate commentShortVideo:self.videoModel];
//                }
//            } notMatchRightsBlock:^(UserRights currentRights) {
//
//            } setProperty:^(id destinationViewController) {
//
//            }];
        };
        [self addSubview:self.commentItemView];
        
        self.upperItemView = [[PASShortVideoAgreeView alloc] initWithFrame:CGRectZero];
        [self.upperItemView setImageName:@"shortvideo_upper" selectImageName:@"shortvideo_upper_select"];
        self.upperItemView.block = ^(BOOL isAgree){
            @pas_strongify_self
            self.videoModel.isAgree = isAgree;
            NSInteger count = self.videoModel.praiseInfo.count;
            if (isAgree) {
                count += 1;
            } else {
                count -= 1;
                if (count < 0) {
                    count = 0;
                }
            }
            self.videoModel.praiseInfo.count = count;
            [self.upperItemView setTextNumber:count];
            if (self.delegate) {
                [self.delegate upperShortVideo:self.videoModel isAgree:isAgree];
            }
        };
        [self addSubview:self.upperItemView];
        
        self.sliderView = [[UISlider alloc] init];
        self.sliderView.maximumTrackTintColor = UIColorFromRGB(0x7F807F);
        self.sliderView.minimumTrackTintColor = UIColorFromRGB(0xE23232);
        self.sliderView.thumbTintColor = UIColorFromRGB(0xffffff);
        [self.sliderView setThumbImage:[UIImage imageNamed:@"shortvideo_thumb"] forState:UIControlStateNormal];
        [self.sliderView setThumbImage:[UIImage imageNamed:@"shortvideo_thumb"] forState:UIControlStateSelected];
        [self.sliderView setThumbImage:[UIImage imageNamed:@"shortvideo_thumb"] forState:UIControlStateHighlighted];
        [self.sliderView addTarget:self action:@selector(sliderViewAction:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.sliderView];
        
        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.playButton setImage:[UIImage imageNamed:@"shortvideo_playicon"] forState:UIControlStateNormal];
        [self.playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.playButton];
        
        self.activityView = [UIActivityIndicatorView new];
        self.activityView.color = UIColorFromRGB(0xffffff);
        [self.activityView stopAnimating];
        [self addSubview:self.activityView];
        
        self.toastView = [UILabel new];
        self.toastView.textColor = UIColorFromRGB(0xffffff);
        self.toastView.textAlignment = NSTextAlignmentCenter;
        self.toastView.font = PASFont(14.0f);
        self.toastView.layer.cornerRadius = 5.0f;
        self.toastView.text = @"视频加载失败";
        self.toastView.backgroundColor = UIColorFromRGBA(0x0000000, 0.8);
        [self addSubview:self.toastView];
        self.toastView.hidden = YES;
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.centerY.equalTo(self);
            make.height.mas_equalTo(ImageViewHeight);
        }];
        BOOL isOpen = NO;
        if (!isOpen) {
            float itemMargin = (ImageViewHeight - 3 * ItemHeight)/4.0f;
            [self.shareItemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).offset(-LeftMargin);
                make.top.equalTo(self.imageView).offset(itemMargin);
                make.width.mas_equalTo(ItemWidth);
                make.height.mas_equalTo(ItemHeight);
            }];
            [self.commentItemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).offset(-LeftMargin);
                make.top.equalTo(self.shareItemView.mas_bottom).offset(itemMargin);
                make.width.mas_equalTo(ItemWidth);
                make.height.mas_equalTo(ItemHeight);
            }];
            [self.upperItemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).offset(-LeftMargin);
                make.top.equalTo(self.commentItemView.mas_bottom).offset(itemMargin - 15.0f);
                make.width.mas_equalTo(ItemWidth);
                make.height.mas_equalTo(ItemHeight + 15.0);
            }];
        } else {
            self.commentItemView.hidden = YES;
            [self.shareItemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).offset(-LeftMargin);
                make.centerY.equalTo(self.imageView).offset(-ItemHeight/2.0f - 10.0f);
                make.width.mas_equalTo(ItemWidth);
                make.height.mas_equalTo(ItemHeight);
            }];
            [self.upperItemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).offset(-LeftMargin);
                make.centerY.equalTo(self.imageView).offset(35.0f);
                make.width.mas_equalTo(ItemWidth);
                make.height.mas_equalTo(ItemHeight + 15.0);
            }];
        }
        
        [self.playOrpauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(LeftMargin);
            make.bottom.equalTo(self).offset(-kPORTRAIT_SAFE_AREA_BOTTOM_SPACE - 30.0f);
            make.width.height.mas_equalTo(20.0f);
        }];
        [self.playtimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-LeftMargin);
            make.centerY.equalTo(self.playOrpauseButton.mas_centerY);
            make.height.mas_equalTo(20.0f);
            make.width.mas_equalTo(82.0f);
        }];
        [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.playOrpauseButton.mas_right).offset(9.0f);
            make.right.equalTo(self.playtimeLabel.mas_left).offset(-5.0f);
            make.centerY.equalTo(self.playOrpauseButton.mas_centerY);
            make.height.mas_equalTo(3.0f);
        }];
        [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.height.mas_equalTo(58.0f);
        }];
        [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.height.mas_equalTo(35.0f);
        }];
        [self.toastView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.mas_equalTo(114.0f);
            make.height.mas_equalTo(36.0f);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playError:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        ZYWeakObject *weakObj = [[ZYWeakObject alloc] initWithWeakObject:self];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:weakObj selector:@selector(timerFired:) userInfo:nil repeats:YES];
        [self.timer setFireDate:[NSDate distantFuture]];
        [self.playerView addTapTarget:self selector:@selector(tapAction)];
    }
    return self;
}

- (void)timerFired:(NSTimer *)timer
{
    static double tm = 0.0f;
    if (self.player.status == AVPlayerStatusReadyToPlay && !self.imageView.hidden) {
        self.imageView.hidden = YES;
    }
    if (!self.playOrpauseButton.selected && self.sliderView.value - tm < 0.0001) {
        [self.activityView startAnimating];
    }
    tm = self.sliderView.value;
}

- (void)sliderViewAction:(UISlider *)slider
{
    if (self.player.status == AVPlayerStatusReadyToPlay) {
        CMTime time = CMTimeMake(slider.value, 1);
        @pas_weakify_self
        [self.player seekToTime:time completionHandler:^(BOOL finished) {
            @pas_strongify_self
            if (finished) {
                self.playOrpauseButton.selected = NO;
                self.playButton.hidden = YES;
                [self.player play];
                [self.activityView startAnimating];
                [self.timer setFireDate:[NSDate distantPast]];
            }
        }];
    } else {
        slider.value = 0;
    }
}

- (void)playWithVideoData:(PASShortVideoItemModel *)videoModel
{
    [self removeMediaPlayer];
    self.noPlayUrl = NO;
    self.videoModel = videoModel;
    self.sliderView.minimumValue = 0;
    self.sliderView.maximumValue = videoModel.videoTime;
    self.sliderView.value = 0;
    self.playOrpauseButton.selected = NO;
    self.imageView.hidden = NO;

    self.playTotalTime = [self timeStringFormat:videoModel.videoTime];
    self.playtimeLabel.text = [NSString stringWithFormat:@"00:00/%@", self.playTotalTime];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:videoModel.images]];
    CGFloat titleHeight = [self heightOfTitleText:videoModel.title];
    CGFloat descHeight = [self heightOfText:videoModel.desc];
    [self.descriptionLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(LeftMargin);
        make.right.equalTo(self).offset(-LeftMargin);
        make.bottom.equalTo(self.playOrpauseButton.mas_top).offset(-15.0f);
        make.height.mas_equalTo(descHeight);
    }];
    if (descHeight > 0.00001) {
        descHeight += 15.0f;
    } else {
        descHeight += 4.0f;
    }
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(LeftMargin);
        make.right.equalTo(self).offset(-LeftMargin);
        make.bottom.equalTo(self.playOrpauseButton.mas_top).offset(-(descHeight + 5.0f));
        make.height.mas_equalTo(titleHeight);
    }];
    CGFloat gradientHeight = kPORTRAIT_SAFE_AREA_BOTTOM_SPACE + 30.0f + 20.0f + 15.0f + titleHeight + descHeight + 5.0f + 30.0f;
    self.gradientLayer.frame = CGRectMake(0, kMainScreenHeight - gradientHeight, kMainScreenWidth, gradientHeight);
    self.descriptionLabel.text = videoModel.desc;
    self.titleLabel.text = videoModel.title;
    [self.shareItemView setTextNumber:videoModel.shareInfo.count];
    [self.commentItemView setTextNumber:videoModel.commentInfo.count];
    [self.upperItemView setTextNumber:videoModel.praiseInfo.count];
    self.upperItemView.selected = videoModel.isAgree;
    [self requestVideoPlayUrl];
    [self requestAgreeData];
}

- (NSString *)timeStringFormat:(NSInteger)time
{
    int mini = time/60;
    int secs = time%60;
    NSString *str = [NSString stringWithFormat:@"%02d:%02d",mini, secs];
    return str;
}

- (void)requestVideoPlayUrl
{
    @pas_weakify_self
//    [self.dataLoader sendRequestForInfoNewsShortVideoUrlNewsId:self.videoModel.fromId block:^(NSInteger status, id obj) {
//        @pas_strongify_self
//        if ([obj isKindOfClass:[PASShortVideoDetailModel class]]) {
//            PASShortVideoDetailModel *model = (PASShortVideoDetailModel *)obj;
//            NSString *url = TransToString(model.data.videoUrl);
//            if (url.length > 0) {
//                self.noPlayUrl = NO;
//                url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//                [self initMediaPlayer:url];
//            } else {
//                self.noPlayUrl = YES;
//                [self showToastview];
//                [self flushUI:NO];
//            }
//        } else {
//            self.noPlayUrl = YES;
//            [self showToastview];
//            [self flushUI:NO];
//        }
//    }];
    
    PASShortVideoDetailModel *model = [PASShortVideoDetailModel new];
    PASShortVideoDetailInfo *detailInfo = [PASShortVideoDetailInfo new];
    detailInfo.videoUrl = @"http://flv3.bn.netease.com/fd5f066da93cc5c02b17a4b11e9119941abe8ef0b730534412a2256841f183031ecad22f1342686d6d070dc63a64454cbed54fbbb02e50e7988306df57142340da929109cedb43923b45469f182738a8800dc747b7a3c81c13866891408d23c67b90b632da3c70db4341896285fcd901c4f3da7018739ffa.mp4";
//    detailInfo.videoUrl = @"https://cdn.cnbj1.fds.api.mi-img.com/mi-mall/20bb1215bc101998e9e390b5c449d6ef.mp4";
    detailInfo.title = @"videoUrl";
    model.data = detailInfo;
    
    NSString *url = TransToString(model.data.videoUrl);
    if (url.length > 0) {
        self.noPlayUrl = NO;
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [self initMediaPlayer:url];
    } else {
        self.noPlayUrl = YES;
        [self showToastview];
        [self flushUI:NO];
    }
}

- (void)requestAgreeData
{
    NSDictionary *params = @{
        @"relevantId" : self.videoModel.fromId ?: @"",
    };
    @pas_weakify_self
//    [self.dataLoader sendRequestForAgreeStatus:params block:^(NSInteger status, id obj) {
//        @pas_strongify_self
//        if ([obj isKindOfClass:[PASShortVideoAgreeResponse class]]) {
//            PASShortVideoAgreeResponse *res = (PASShortVideoAgreeResponse *)obj;
//            if ([@"1" isEqualToString:res.results.status]) {
//                self.videoModel.isAgree = YES;
//            } else {
//                self.videoModel.isAgree = NO;
//            }
//            self.upperItemView.selected = self.videoModel.isAgree;
//        }
//    }];
}

- (void)removeMediaPlayer
{
    if (self.playerLayer) {
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
    }
    if (self.player) {
        [self.player pause];
        self.player.rate = 0.0f;
        [self.player removeTimeObserver:self.palyerObserver];
    }
    self.stopped = NO;
    self.playerItem = nil;
    self.player = nil;
}

- (void)initMediaPlayer:(NSString *)url
{
//    [self removeObservers];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    self.playerItem =[[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:url]];
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    self.player.rate = 0.0f;
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerLayer.frame = self.playerView.bounds;
    [self.playerView.layer addSublayer:self.playerLayer];
    [self.gradientLayer removeFromSuperlayer];
    [self.playerLayer addSublayer:self.gradientLayer];

    @pas_weakify_self
    self.palyerObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        @pas_strongify_self
        //当前播放的时间
        NSTimeInterval current = CMTimeGetSeconds(time);
        [self updateProgress:current];
    }];
    if (self.autoPlay) {
        self.player.rate = 1.0;
        [self.player play];
        self.autoPlay = NO;
        self.playButton.hidden = YES;
        self.playOrpauseButton.selected = NO;
        [self.activityView startAnimating];
        [self.timer setFireDate:[NSDate distantPast]];
    }
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showToastview
{
    self.toastView.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.toastView.hidden = YES;
    });
}

- (void)playError:(NSNotification *)aNotifi
{
    if (aNotifi.object != self.playerItem) {
        return;
    }
    [self showToastview];
    [self playOrPause:NO];
    if (self.delegate) {
        [self.delegate shortVideoPlayerError:self.videoModel];
    }
}

- (void)playToEndTime:(NSNotification *)aNotifi
{
    if (aNotifi.object != self.playerItem) {
        return;
    }
    static NSTimeInterval time = 0;
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    if (currentTime - time > 2.0f) {
        if (self.delegate) {
            [self.delegate shortVideoPlayerFinished:self.videoModel];
        }
    }
    time = currentTime;
}

- (void)startPlay
{
    self.startTime = [[NSDate date] timeIntervalSince1970];
    if (!self.player) {
        self.stopped = NO;
        self.autoPlay = YES;
    } else {
        self.player.rate = 1.0;
        if (self.stopped) {
            [self.player seekToTime:CMTimeMake(0, 1) completionHandler:^(BOOL finished) {
                if (finished) {
                    [self.player play];
                }
            }];
            self.stopped = NO;
        } else {
            [self.player play];
        }
    }
    self.playOrpauseButton.selected = NO;
    self.sliderView.value = 0;
    self.sliderView.minimumValue = 0;
    self.sliderView.maximumValue = self.videoModel.videoTime;
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
    [self.timer setFireDate:[NSDate distantPast]];
    self.playButton.hidden = YES;
}

- (void)stopPlay
{
    if (self.player) {
        [self.player pause];
        self.player.rate = 0.0;
    }
    self.playOrpauseButton.selected = YES;
    self.sliderView.value = 0;
    self.autoPlay = NO;
    self.stopped = YES;
    [self.timer setFireDate:[NSDate distantFuture]];
    self.playButton.hidden = NO;
    NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
    if (endTime > self.startTime) {
        [self shortVideoPlayerViewMonitor:(endTime - self.startTime) video:self.videoModel.fromId];
    }
}

- (void)playOrPause:(BOOL)play
{
    self.playOrpauseButton.selected = play;
    [self playOrpauseButtonAction:self.playOrpauseButton];
}

- (void)updateCommentView:(NSInteger)count
{
    [self.commentItemView setTextNumber:count];
}

- (void)updateProgress:(NSTimeInterval)time
{
    if (self.activityView.animating) {
        [self.activityView stopAnimating];
    }
    if (self.stopped) {
        [self.player pause];
    }
    if (self.sliderView.value > 0 && !self.imageView.hidden) {
        self.imageView.hidden = YES;
//        self.playerTapView.frame = self.playerLayer.videoRect;
    }
    
    self.sliderView.value = time;
    NSInteger secs = floor(time);
    NSString *currentFormatTime = [self timeStringFormat:secs];
    self.playtimeLabel.text = [NSString stringWithFormat:@"%@/%@", currentFormatTime, self.playTotalTime];
}

- (void)playOrpauseButtonAction:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (!btn.selected) {
        if (self.noPlayUrl) {
            [self requestVideoPlayUrl];
        }
        [self.player play];
        [self.activityView startAnimating];
        [self.timer setFireDate:[NSDate distantPast]];
        self.playButton.hidden = YES;
    } else {
        [self.player pause];
        [self.activityView stopAnimating];
        [self.timer setFireDate:[NSDate distantFuture]];
        self.playButton.hidden = NO;
    }
}

- (void)tapAction
{
    [self playOrpauseButtonAction:self.playOrpauseButton];
}

- (void)playButtonAction:(UIButton *)btn
{
    if (self.noPlayUrl) {
        [self requestVideoPlayUrl];
    }
    self.playOrpauseButton.selected = NO;
    self.playButton.hidden = YES;
    [self.player play];
    [self.activityView startAnimating];
    [self.timer setFireDate:[NSDate distantPast]];
}

- (void)flushUI:(BOOL)playing
{
    if (playing) {
        self.playOrpauseButton.selected = NO;
        self.playButton.hidden = YES;
        [self.activityView startAnimating];
        [self.timer setFireDate:[NSDate distantPast]];
    } else {
        self.playOrpauseButton.selected = YES;
        [self.activityView stopAnimating];
        [self.timer setFireDate:[NSDate distantFuture]];
        self.playButton.hidden = NO;
    }
}

- (CGFloat)heightOfText:(NSString *)text
{
    if (text.length == 0) {
        return 0.0f;
    }
    NSDictionary *param = @{NSFontAttributeName : PASFont(14.0)};
    NSAttributedString *attriStr = [[NSAttributedString alloc] initWithString:text attributes:param];
    CGRect rect = [attriStr boundingRectWithSize:CGSizeMake(kMainScreenWidth - 2 * LeftMargin, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGFloat height = rect.size.height + 5.0f;
    if (height > 80.0f) {
        height = 80.0f;
    }
    return height;
}

- (CGFloat)heightOfTitleText:(NSString *)text
{
    if (text.length == 0) {
        return 0.0f;
    }
    NSDictionary *param = @{NSFontAttributeName : PASBFont(17.0f)};
    NSAttributedString *attriStr = [[NSAttributedString alloc] initWithString:text attributes:param];
    CGRect rect = [attriStr boundingRectWithSize:CGSizeMake(kMainScreenWidth - 2 * LeftMargin, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGFloat height = rect.size.height + 5.0f;
    if (height > 50.0f) {
        height = 50.0f;
    }
    return height;
}

- (void)destoryPlayer
{
    [self.timer invalidate];
    [self.player removeTimeObserver:self.palyerObserver];
    self.player = nil;
    self.playerItem = nil;
    [self.playerLayer removeFromSuperlayer];
}

- (void)dealloc
{
    [self removeObservers];
    [self.timer invalidate];
}

- (void)shortVideoBackgroundMonitor:(BOOL)value
{
    if (value) {
        NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
        if (endTime > self.startTime) {
            [self shortVideoPlayerViewMonitor:(endTime - self.startTime) video:self.videoModel.fromId];
        }
    } else {
        self.startTime = [[NSDate date] timeIntervalSince1970];
    }
}

- (void)shortVideoPlayerViewMonitor:(double)time video:(NSString *)videoId
{
    
}

@end
