//
//  PASShortVideoPlayerViewController.m
//  PASInfoLib
//
//  Created by 张勇勇(证券总部经纪业务事业部技术开发团队) on 2020/11/24.
//

#import "PASShortVideoPlayerViewController.h"
#import "NSObject+Customizer.h"
#import "PASShortVideoResponse.h"
#import "ZWSDK.h"
#import "PASShortVideoPlayerView.h"
#import "LoadingUtil.h"


#define kNotifyNativeCommentData                @"NotificationCommentDataFromWebView"


@interface PASShortVideoPlayerViewController () <UIScrollViewDelegate, PASShortVideoPlayerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) NSMutableArray *videoDatas;

//@property (nonatomic, strong) PASConsultingInfoDataLoader *dataLoader;

@property (nonatomic, strong) NSMutableArray<PASShortVideoPlayerView *> *views;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) CGPoint offset;
@property (nonatomic, assign) BOOL dragUpper;

@property (nonatomic ,strong) NSMutableDictionary *schemaParams;
@property (nonatomic, assign) NSInteger nt;
@property (nonatomic, assign) BOOL loadingNextPage;

@property (nonatomic, strong) UIView *commentBackView;
@property (nonatomic, strong) UIView *guideView;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) UILabel *toastView;

//@property (nonatomic, strong) PASWebViewController *webVc;
@property (nonatomic, strong) UIButton *commentCloseBtn;
@property (nonatomic, strong) UIView *commentView;

@end

@implementation PASShortVideoPlayerViewController

- (void)initExtendedData
{
    [super initExtendedData];
    self.videoDatas = [NSMutableArray array];
    self.views = [NSMutableArray array];
    self.currentIndex = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentDataNotify:) name:kNotifyNativeCommentData object:nil];
}

//- (PASConsultingInfoDataLoader *)dataLoader
//{
//    if (!_dataLoader) {
//        _dataLoader = [[PASConsultingInfoDataLoader alloc] init];
//        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
//        self.relatedPageID = [UIResponder pathOfObject:self abortClass:nil parameters:params];
//        self.relatedPageParams = params;
//    }
//
//    _dataLoader.relatedPageID = self.relatedPageID;
//    _dataLoader.relatedPageParams = self.relatedPageParams;
//
//    return _dataLoader;
//}

- (BOOL)navigationBarStatus
{
    return NO;
}

- (void)enterBackground
{
    if (self.currentIndex == 0) {
        [self.views[0] playOrPause:NO];
        [self.views[0] shortVideoBackgroundMonitor:YES];
    } else if (self.currentIndex == self.videoDatas.count - 1) {
        if (self.videoDatas.count < 3) {
            [self.views[1] playOrPause:NO];
            [self.views[1] shortVideoBackgroundMonitor:YES];
        } else {
            [self.views[2] playOrPause:NO];
            [self.views[2] shortVideoBackgroundMonitor:YES];
        }
    } else {
        [self.views[1] playOrPause:NO];
        [self.views[1] shortVideoBackgroundMonitor:YES];
    }
}

- (void)becomeActive
{
    if (self.currentIndex == 0) {
        [self.views[0] playOrPause:YES];
        [self.views[0] shortVideoBackgroundMonitor:NO];
    } else if (self.currentIndex == self.videoDatas.count - 1) {
        if (self.videoDatas.count < 3) {
            [self.views[1] playOrPause:YES];
            [self.views[1] shortVideoBackgroundMonitor:NO];
        } else {
            [self.views[2] playOrPause:YES];
            [self.views[2] shortVideoBackgroundMonitor:NO];
        }
    } else {
        [self.views[1] playOrPause:YES];
        [self.views[1] shortVideoBackgroundMonitor:NO];
    }
}

- (void)commentDataNotify:(NSNotification *)notify
{
    if (!notify.object) {
        return;
    }
    NSDictionary *object = notify.object;
    NSString *sence = [object objectForKey:@"sence"];
    NSDictionary *data = [object objectForKey:@"data"];
    if ([@"shortvideo" isEqualToString:[sence lowercaseString]] && data.count > 0) {
        NSInteger count = [[data objectForKey:@"count"] integerValue];
        NSString *infocode = [data objectForKey:@"infocode"];
        [self updateCommentData:infocode count:count];
    }
}

- (void)updateCommentData:(NSString *)fromId count:(NSInteger)count
{
    PASShortVideoItemModel *currentModel = self.videoDatas[self.currentIndex];
    if ([fromId isEqualToString:currentModel.fromId]) {
        currentModel.commentInfo.count = count;
        if (self.currentIndex == 0) {
            [self.views[0] updateCommentView:count];
        } else if (self.currentIndex == self.videoDatas.count - 1) {
            if (self.videoDatas.count < 3) {
                [self.views[1] updateCommentView:count];
            } else {
                [self.views[2] updateCommentView:count];
            }
        } else {
            [self.views[1] updateCommentView:count];
        }
    } else {
        [self.videoDatas enumerateObjectsUsingBlock:^(PASShortVideoItemModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([fromId isEqualToString:obj.fromId]) {
                obj.commentInfo.count = count;
                *stop = YES;
            }
        }];
    }
}

- (UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
        _scrollView.pagingEnabled = YES;
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.backgroundColor = UIColorFromRGB(0x000000);
        _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    }
    return _scrollView;
}

- (UIView *)commentView
{
    if (nil == _commentView) {
        _commentView = [[UIView alloc] initWithFrame:CGRectMake(0, kMainScreenHeight/2.0, kMainScreenWidth, kMainScreenHeight/2.0)];
        _commentView.backgroundColor = UIColorFromRGB(0xffffff);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 44.5f)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = UIColorFromRGB(0x333333);
        label.font = PASFont(18.0);
        label.text = @"评论";
        [_commentView addSubview:label];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 44.5f, kMainScreenWidth, 0.5f)];
        line.backgroundColor = UIColorFromRGB(0xEDEDED);
        [_commentView addSubview:line];
        [_commentView addSubview:self.commentCloseBtn];
    }
    return _commentView;
}

- (UIButton *)commentCloseBtn
{
    if (nil == _commentCloseBtn) {
        _commentCloseBtn = [[UIButton alloc] initWithFrame:CGRectMake(kMainScreenWidth - 48.0f, 5.0f, 35.0f, 35.0f)];
        [_commentCloseBtn setImage:[UIImage imageNamed:@"shortvideo_comment_close"] forState:UIControlStateNormal];
        [_commentCloseBtn addTarget:self action:@selector(commentCloseBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commentCloseBtn;
}

- (void)commentCloseBtnAction:(id)sender
{
    [self commentBackViewTapAction];
}

- (UILabel *)toastView
{
    if (nil == _toastView) {
        _toastView = [UILabel new];
        _toastView.textColor = UIColorFromRGB(0xffffff);
        _toastView.textAlignment = NSTextAlignmentCenter;
        _toastView.font = PASFont(14.0f);
        _toastView.layer.cornerRadius = 5.0f;
        _toastView.text = @"视频列表已播完";
        _toastView.backgroundColor = UIColorFromRGBA(0x0000000, 0.8);
        [self.view addSubview:_toastView];
        [_toastView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.width.mas_equalTo(135.0f);
            make.height.mas_equalTo(36.0f);
        }];
    }
    return _toastView;
}

- (void)showToastView
{
    self.toastView.hidden = NO;
    self.toastView.text = @"视频列表已播完";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.toastView.hidden = YES;
    });
}

- (void)showFailRequestPageToastView
{
    self.toastView.hidden = NO;
    self.toastView.text = @"视频列表加载失败";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.toastView.hidden = YES;
    });
}


- (UIView *)emptyView
{
    if (_emptyView == nil) {
        _emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
        _emptyView.backgroundColor = UIColorFromRGB(0x000000);
        UIImageView *imageView = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:@"shortvideo_empty"];
        imageView.image = image;
        [_emptyView addSubview:imageView];
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = UIColorFromRGB(0xffffff);
        label.font = PASFont(15.0f);
        label.text = @"视频被风吹走了！";
        [_emptyView addSubview:label];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_emptyView);
            make.centerY.equalTo(_emptyView).offset(-image.size.height/2.0);
            make.width.mas_equalTo(image.size.width);
            make.height.mas_equalTo(image.size.height);
        }];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView.mas_bottom).offset(20.0f);
            make.left.right.equalTo(_emptyView);
            make.height.mas_equalTo(25.0f);
        }];
    }
    return _emptyView;
}

- (UIView *)guideView
{
    if (_guideView == nil) {
        _guideView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
        _guideView.backgroundColor = UIColorFromRGBA(0x000000, 0.7);
        UIImageView *imageView = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:@"shortvideo_guide"];
        imageView.image = image;
        [_guideView addSubview:imageView];
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = UIColorFromRGB(0xffffff);
        label.font = PASFont(15.0f);
        label.text = @"向上滑动查看更多";
        [_guideView addSubview:label];
        imageView.frame = CGRectMake((kMainScreenWidth - image.size.width)/2.0f, (kMainScreenHeight - image.size.height)/2.0f, image.size.width, image.size.height);
        label.frame = CGRectMake(0, CGRectGetMaxY(imageView.frame) + 20.0f, kMainScreenWidth, 25.0f);

        [_guideView addTapTarget:self selector:@selector(guideViewTap)];
        UIPanGestureRecognizer *panG = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(guideViewTap)];
        [_guideView addGestureRecognizer:panG];
    }
    return _guideView;
}
 - (void)guideViewTap
{
    [self.guideView removeFromSuperview];
    [self.views[0] startPlay];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    id<CMTPLivingServiceProtocol>  service = [CMBusMediator serviceForProtocol:@protocol(CMTPLivingServiceProtocol) componentId:kCMPTPublicService];
//    [service closeVHallAndAnydoorAudio];
    self.view.backgroundColor = UIColorFromRGB(0x000000);
    [self.view addSubview:self.scrollView];
    self.commentBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    [self.commentBackView addTapTarget:self selector:@selector(commentBackViewTapAction)];
    [self.view addSubview:self.commentBackView];
    self.commentBackView.hidden = YES;
    if(@available(iOS 11, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(8.0f, kSysStatusBarHeight + (kMainNavHeight - 35.0f)/2.0f, 44.0f, 35.0f)];
    [self.backButton setImage:[UIImage imageNamed:@"shortvideo_back"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
    
    PASShortVideoPlayerView *view1 = [[PASShortVideoPlayerView alloc] init];
//    view1.dataLoader = self.dataLoader;
    view1.delegate = self;
    
    PASShortVideoPlayerView *view2 = [[PASShortVideoPlayerView alloc] init];
//    view2.dataLoader = self.dataLoader;
    view2.delegate = self;
    
    PASShortVideoPlayerView *view3 = [[PASShortVideoPlayerView alloc] init];
//    view3.dataLoader = self.dataLoader;
    view3.delegate = self;
    
    [self.views addObject:view1];
    [self.views addObject:view2];
    [self.views addObject:view3];
    [self.views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
        view.frame = CGRectMake(0, idx * kMainScreenHeight, kMainScreenWidth, kMainScreenHeight);
        [self.scrollView addSubview:view];
    }];

    self.scrollView.hidden = YES;
    [self requestFirstShortVideoData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIApplication *application = [UIApplication sharedApplication];
    UIStatusBarStyle barstyle = UIStatusBarStyleLightContent;
    [application setStatusBarStyle:barstyle];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    UIApplication *application = [UIApplication sharedApplication];
    UIStatusBarStyle barstyle = UIStatusBarStyleDefault;
    #ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        barstyle = UIStatusBarStyleDarkContent;
    }
    #endif
    [application setStatusBarStyle:barstyle];
}

- (void)dealloc
{
    [self enterBackground]; //统计埋点
    [self.views enumerateObjectsUsingBlock:^(PASShortVideoPlayerView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
        [obj destoryPlayer];
    }];
    [self.views removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)backButtonAction:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)propertyURLSchemeParamCallbackAction:(Protocol *)protocol params:(NSDictionary *)params actionBlock:(URLParamMapPropertyCheckBlock)actionBlock
{
    [super propertyURLSchemeParamCallbackAction:protocol params:params actionBlock:actionBlock];
    if (params) {
        self.schemaParams = [NSMutableDictionary dictionaryWithDictionary:params];
    } else {
        self.schemaParams = [NSMutableDictionary dictionary];
    }
}

- (void)addEmptyVideoView
{
    [self.view addSubview:self.emptyView];
    [self.view bringSubviewToFront:self.backButton];
}

- (void)addGuideVideoView
{
    [self.view addSubview:self.guideView];
    [self.view bringSubviewToFront:self.backButton];
}

- (void)requestFirstShortVideoData
{
    [self.schemaParams setObject:@0 forKey:@"nt"];
    [self.schemaParams setObject:@20 forKey:@"pageSize"];
//    [LoadingUtil show];
//    [self.dataLoader sendRequestForQueryShortVideoList:self.schemaParams block:^(NSInteger status, id obj) {
//        [LoadingUtil hide];
//        if ([obj isKindOfClass:[PASShortVideoResponse  class]]) {
//            PASShortVideoResponse *res = (PASShortVideoResponse *)obj;
//            self.nt = res.results.nt;
//            if (res.results.list.count > 0) {
//                self.scrollView.hidden = NO;
//                [self.videoDatas addObjectsFromArray:res.results.list];
//                if ([self.videoDatas count] < 3) {
//                    [self.scrollView setContentSize:CGSizeMake(kMainScreenWidth, self.videoDatas.count * kMainScreenHeight)];
//                } else {
//                    [self.scrollView setContentSize:CGSizeMake(kMainScreenWidth, self.views.count * kMainScreenHeight)];
//                }
//
//                [self.views[0] playWithVideoData:self.videoDatas[0]];
//                [self.views[0] startPlay];
//                if (self.videoDatas.count > 1) {
//                    [self.views[1] playWithVideoData:self.videoDatas[1]];
//                }
//                if (![[NSUserDefaults standardUserDefaults] objectForKey:@"shortvideo_guide"]) {
//                    [self addGuideVideoView];
//                    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"shortvideo_guide"];
//                }
//            } else {
//                //没有视频,被风吹走了展示
//                [self addEmptyVideoView];
//            }
//        } else {
//            //没有视频,被风吹走了展示
//            [self addEmptyVideoView];
//        }
//    }];
    
    PASShortVideoResponse *res = [PASShortVideoResponse new];
    PASShortVideoResult *result = [PASShortVideoResult new];
    PASShortVideoModelInfo *modelInfo = [PASShortVideoModelInfo new];
    modelInfo.count = 1000000;
    PASShortVideoModelInfo *modelInfo2 = [PASShortVideoModelInfo new];
    modelInfo2.count = 2030000;
    PASShortVideoModelInfo *modelInfo3 = [PASShortVideoModelInfo new];
    modelInfo3.count = 599990000;
    
    PASShortVideoItemModel *model1 = [PASShortVideoItemModel new];
    model1.title = @"model1";

    model1.commentInfo = modelInfo;
    model1.shareInfo = modelInfo2;
    model1.praiseInfo = modelInfo3;
    
    PASShortVideoItemModel *model2 = [PASShortVideoItemModel new];
    model2.title = @"model2";
    model2.commentInfo = modelInfo;
    model2.shareInfo = modelInfo2;
    model2.praiseInfo = modelInfo3;
    
    PASShortVideoItemModel *model3 = [PASShortVideoItemModel new];
    model3.title = @"model3";
    model3.commentInfo = modelInfo;
    model3.shareInfo = modelInfo2;
    model3.praiseInfo = modelInfo3;
    
    result.list = (NSArray<PASShortVideoItemModel> *)@[model1, model2, model3];
    result.nt = 121;
    result.pageSize = 20;
    
    res.results = result;
    
    self.nt = res.results.nt;
    if (res.results.list.count > 0) {
        self.scrollView.hidden = NO;
        [self.videoDatas addObjectsFromArray:res.results.list];
        if ([self.videoDatas count] < 3) {
            [self.scrollView setContentSize:CGSizeMake(kMainScreenWidth, self.videoDatas.count * kMainScreenHeight)];
        } else {
            [self.scrollView setContentSize:CGSizeMake(kMainScreenWidth, self.views.count * kMainScreenHeight)];
        }
        
        [self.views[0] playWithVideoData:self.videoDatas[0]];
        [self.views[0] startPlay];
        if (self.videoDatas.count > 1) {
            [self.views[1] playWithVideoData:self.videoDatas[1]];
        }
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"shortvideo_guide"]) {
            [self addGuideVideoView];
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"shortvideo_guide"];
        }
    }
}

- (void)requestNextPageShortVideoData
{
    if (self.loadingNextPage) {
        return;
    }
    self.loadingNextPage = YES;
    [self.schemaParams setObject:@(self.nt) forKey:@"nt"];
    [self.schemaParams setObject:@20 forKey:@"pageSize"];
    @pas_weakify_self
//    [self.dataLoader sendRequestForQueryShortVideoList:self.schemaParams block:^(NSInteger status, id obj) {
//        @pas_strongify_self
//        if ([obj isKindOfClass:[PASShortVideoResponse  class]]) {
//            PASShortVideoResponse *res = (PASShortVideoResponse *)obj;
//            self.nt = res.results.nt;
//            if (res.results.list.count > 0) {
//                NSInteger preCount = self.videoDatas.count;
//                [self.videoDatas addObjectsFromArray:res.results.list];
//                [self loadNextGroupVideos:preCount];
//            } else {
//                //没有视频,toast提示
//                [self showToastView];
//            }
//        } else {
//            [self showFailRequestPageToastView];
//        }
//        self.loadingNextPage = NO;
//    }];
    
    
}

- (void)loadNextGroupVideos:(NSInteger)preCount
{
    if (preCount - 1 != self.currentIndex) {
        return;
    }

    if ([self.videoDatas count] < 3) {
        [self.scrollView setContentSize:CGSizeMake(kMainScreenWidth, self.videoDatas.count * kMainScreenHeight)];
    } else {
        [self.scrollView setContentSize:CGSizeMake(kMainScreenWidth, self.views.count * kMainScreenHeight)];
    }
    if (preCount < 3) {
        //第一组视频小于3个
        if (preCount == 1) {
            [self.views[0] stopPlay];
            [self.views[1] playWithVideoData:self.videoDatas[preCount]];
            if (preCount + 1 < [self.videoDatas count]) {
                [self.views[2] playWithVideoData:self.videoDatas[preCount + 1]];
            }
            [UIView animateWithDuration:0.25 animations:^{
                [self.scrollView setContentOffset:CGPointMake(0, kMainScreenHeight)];
            } completion:^(BOOL finished) {
                [self.scrollView setContentOffset:CGPointMake(0, kMainScreenHeight)];
                [self.views[1] startPlay];
            }];
        } else {
            //preCount == 2
            if (preCount + 1 < [self.videoDatas count]) {
                //增加2个及以上
                [self.views[1] stopPlay];
                [self.views[2] playWithVideoData:self.videoDatas[preCount]];
                PASShortVideoPlayerView *last = self.views[0];
                [last playWithVideoData:self.videoDatas[preCount + 1]];
                [self.views removeObject:last];
                [self.views addObject:last];
                [self.views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
                    view.frame = CGRectMake(0, idx * kMainScreenHeight, kMainScreenWidth, kMainScreenHeight);
                }];
                [self.scrollView setContentOffset:CGPointMake(0, 0)];
                [UIView animateWithDuration:0.25 animations:^{
                   [self.scrollView setContentOffset:CGPointMake(0, kMainScreenHeight)];
                } completion:^(BOOL finished) {
                   [self.scrollView setContentOffset:CGPointMake(0, kMainScreenHeight)];
                   [self.views[1] startPlay];
                }];
            } else {
                //增加一个
                [self.views[1] stopPlay];
                [self.views[2] playWithVideoData:self.videoDatas[preCount]];
                [UIView animateWithDuration:0.25 animations:^{
                   [self.scrollView setContentOffset:CGPointMake(0, 2 * kMainScreenHeight)];
                } completion:^(BOOL finished) {
                   [self.scrollView setContentOffset:CGPointMake(0, 2 * kMainScreenHeight)];
                   [self.views[2] startPlay];
                }];
            }
        }
        self.currentIndex++;
    } else {
        PASShortVideoPlayerView *one = self.views[2];
        [one stopPlay];
        if (preCount == [self.videoDatas count] - 1) {
            //最后一个
            PASShortVideoPlayerView *last = self.views[0];
            [last playWithVideoData:self.videoDatas[preCount]];
            [self.views removeObject:last];
            [self.views addObject:last];
            [self.views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
                view.frame = CGRectMake(0, idx * kMainScreenHeight, kMainScreenWidth, kMainScreenHeight);
            }];
            self.currentIndex++;
            [self.scrollView setContentOffset:CGPointMake(0, kMainScreenHeight)];
            [UIView animateWithDuration:0.25 animations:^{
                [self.scrollView setContentOffset:CGPointMake(0, 2 * kMainScreenHeight)];
            } completion:^(BOOL finished) {
                [self.scrollView setContentOffset:CGPointMake(0, 2 * kMainScreenHeight)];
                [last startPlay];
            }];
        } else {
            //不是最后一个
            //正要播放的视频
            PASShortVideoPlayerView *middle = self.views[0];
            [middle playWithVideoData:self.videoDatas[preCount]];
            //装下一个要播放的视频
            PASShortVideoPlayerView *last = self.views[1];
            [last playWithVideoData:self.videoDatas[preCount + 1]];
            
            [self.views removeAllObjects];
            [self.views addObject:one];
            [self.views addObject:middle];
            [self.views addObject:last];
            [self.views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
                view.frame = CGRectMake(0, idx * kMainScreenHeight, kMainScreenWidth, kMainScreenHeight);
            }];
            [self.scrollView setContentOffset:CGPointMake(0, 0)];
            [UIView animateWithDuration:0.25 animations:^{
                [self.scrollView setContentOffset:CGPointMake(0, kMainScreenHeight)];
            } completion:^(BOOL finished) {
                [self.scrollView setContentOffset:CGPointMake(0, kMainScreenHeight)];
                [middle startPlay];
            }];
        }
    }
}

- (void)commentBackViewTapAction
{
    [self.commentView removeFromSuperview];
    self.commentBackView.hidden = YES;
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.offset = scrollView.contentOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGPoint currentOffset = scrollView.contentOffset;
    if (currentOffset.y - self.offset.y > 0) {
        //上滑
        self.dragUpper = YES;
    } else {
        //下滑
        self.dragUpper = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    NSLog(@"--->pre video1:%ld diff:%f drag:%d", self.currentIndex, scrollView.contentOffset.y - self.offset.y, self.dragUpper);
    if (self.dragUpper) {
        if (scrollView.contentOffset.y - self.offset.y < 0.0001f) {
            [scrollView setContentOffset:self.offset];
            if (self.currentIndex == self.videoDatas.count - 1) {
                [self requestNextPageShortVideoData];
            }
            return;
        }
    } else {
        if (scrollView.contentOffset.y - self.offset.y > -0.0001f) {
            [scrollView setContentOffset:self.offset];
            return;
        }
    }
//    NSLog(@"--->pre video:%ld diff:%f drag:%d", self.currentIndex, scrollView.contentOffset.y - self.offset.y, self.dragUpper);
    if (self.dragUpper) {
        if (self.currentIndex < [self.videoDatas count] - 1) {
            if (self.currentIndex == 0) {
                PASShortVideoPlayerView *player1 = self.views[0];
                [player1 stopPlay];
                self.currentIndex++;
                PASShortVideoPlayerView *player2 = self.views[1];
                [player2 startPlay];
//                NSLog(@"--->current video:%ld", self.currentIndex);
                if (self.currentIndex == [self.videoDatas count] - 1) {
                    //当前播放为最后一个视频
                } else {
                    PASShortVideoPlayerView *player3= self.views[2];
                    [player3 playWithVideoData:self.videoDatas[self.currentIndex + 1]];
                }
                [self.views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
                    view.frame = CGRectMake(0, idx * kMainScreenHeight, kMainScreenWidth, kMainScreenHeight);
                }];
                [scrollView setContentOffset:CGPointMake(0, kMainScreenHeight)];
                PASShortVideoItemModel *currentItem = self.videoDatas[self.currentIndex];
                [self dragUpMonitor:currentItem.fromId];
                return;
            }
            //停止播放上一个视频
            [self.views[1] stopPlay];
            self.currentIndex++;
            //播放当前视频
            [self.views[2] startPlay];
//            NSLog(@"--->current video:%ld", self.currentIndex);
            if (self.currentIndex == [self.videoDatas count] - 1) {
                //当前播放为最后一个视频
            } else {
                //预装载下一个视频
                PASShortVideoPlayerView *one = [self.views objectAtIndex:0];
//                [one stopPlay];
                [one playWithVideoData:self.videoDatas[self.currentIndex+1]];
                [self.views removeObjectAtIndex:0];
                [self.views addObject:one];
                [self.views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
                    view.frame = CGRectMake(0, idx * kMainScreenHeight, kMainScreenWidth, kMainScreenHeight);
                }];
                [scrollView setContentOffset:CGPointMake(0, kMainScreenHeight)];
            }
            PASShortVideoItemModel *currentItem = self.videoDatas[self.currentIndex];
            [self dragUpMonitor:currentItem.fromId];
        } else {
            //请求下一组
            [self requestNextPageShortVideoData];
        }
    } else {
        if (self.currentIndex > 0) {
            if (self.currentIndex == [self.videoDatas count] - 1) {
                //前一个播放为最后一个
                if (self.videoDatas.count < 3) {
                    [self.views[1] stopPlay];
                    self.currentIndex--;
                    //播放视频
                    [self.views[0] startPlay];
//                    NSLog(@"--->current video:%ld", self.currentIndex);
                } else {
                    [self.views[2] stopPlay];
                    self.currentIndex--;
                    //播放视频
                    [self.views[1] startPlay];
//                    NSLog(@"--->current video:%ld", self.currentIndex);
                }
                PASShortVideoItemModel *currentItem = self.videoDatas[self.currentIndex];
                [self dragDownMonitor:currentItem.fromId];
                return;
            }
            //停止播放上一个视频
            [self.views[1] stopPlay];
            self.currentIndex--;
            [self.views[0] startPlay];
//            NSLog(@"--->current video:%ld", self.currentIndex);
            if (self.currentIndex == 0) {
                //当前播放为第一个视频
            } else {
                //预装载上一个视频
                PASShortVideoPlayerView *last = [self.views objectAtIndex:2];
//                [last stopPlay];
                [last playWithVideoData:self.videoDatas[self.currentIndex - 1]];
                [self.views removeObjectAtIndex:2];
                [self.views insertObject:last atIndex:0];
                [self.views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
                    view.frame = CGRectMake(0, idx * kMainScreenHeight, kMainScreenWidth, kMainScreenHeight);
                }];
                [scrollView setContentOffset:CGPointMake(0, kMainScreenHeight)];
            }
            PASShortVideoItemModel *currentItem = self.videoDatas[self.currentIndex];
            [self dragDownMonitor:currentItem.fromId];
        } else {
            
        }
    }
}

#pragma mark PASShortVideoPlayerDelegate
- (void)shortVideoPlayerFinished:(PASShortVideoItemModel *)videoModel
{
    NSInteger lastIndex = self.videoDatas.count - 1;
//    NSLog(@"--->curentIndex:%ld, lastIndex:%ld", self.currentIndex, lastIndex);
    if (self.currentIndex == lastIndex) {
        //请求下一组
        [self requestNextPageShortVideoData];
    } else {
        CGPoint offset = self.scrollView.contentOffset;
        self.offset = self.scrollView.contentOffset;
        offset.y += kMainScreenHeight;
        [UIView animateWithDuration:0.25 animations:^{
            [self.scrollView setContentOffset:offset];
        } completion:^(BOOL finished) {
            [self.scrollView setContentOffset:offset];
            self.dragUpper = YES;
            [self scrollViewDidEndDecelerating:self.scrollView];
        }];
    }
}

- (void)shortVideoPlayerError:(PASShortVideoItemModel *)videoModel
{
    
}

- (void)shareShortVideo:(PASShortVideoItemModel *)videoModel completion:(void(^)(BOOL success))block
{
//    PASShareObject *shareObject = [[PASShareObject alloc] init];
//    shareObject.channelType = ShareCannel_All;
//    shareObject.contentType = ShareContent_NewsPicture;
//    shareObject.shareTitle = videoModel.title;
//    shareObject.shareDescription = videoModel.title;
//    shareObject.shareURLString = videoModel.detailLink;
//    shareObject.shareImageUrl = videoModel.images;
//    shareObject.pageId = @"shortvideo";
//    shareObject.positionInfo = @{kShareInfoId:TransToString(videoModel.fromId),
//                                 kSharePositionLabel:@"shortvideo",
//                                 kSharePositionName:@"videoshare"
//    };
//    @pas_weakify_self
//    [[PASShareModule sharedPASShareModule] shareWithShareModel:shareObject actionBlock:^(ShareChannelType channel, ShareResponseStatusType status, id  _Nonnull shareObj) {
//        @pas_strongify_self
//        if (status == ShareResponseStatus_Success) {
//            NSMutableDictionary *params = [NSMutableDictionary dictionary];
//            NSString *share = @"";
//            switch (channel) {
//                case ShareChannel_Weixin:
//                    share = @"wechat";
//                    break;
//                case ShareChannel_SinaWeiBo:
//                    share = @"weibo";
//                    break;
//                case ShareChannel_WeixinTimeline:
//                    share = @"moments";
//                    break;
//                default:
//                    break;
//            }
//            [params setObject:share forKey:@"toShareType"];
//            [params setObject:videoModel.fromId ?: @"" forKey:@"relevantId"];
//            [params setObject:videoModel.sceneId ?: @"" forKey:@"scene"];
////            [self.dataLoader sendRequestForShareShortVideo:params block:^(NSInteger status, id obj) {
////
////            }];
//            if (block) {
//                block(YES);
//            }
//        }
//    }];
//    [self shareMonitor:videoModel.fromId];
}

- (void)commentShortVideo:(PASShortVideoItemModel *)videoModel
{
//    self.commentBackView.hidden = NO;
//    PASWebViewController *webVc = [[PASWebViewController alloc] init];
//    NSString *url = [NSString stringWithFormat:@"%@/static/info/news/videoComment.html?infocode=%@",[PASSiteAddressManager getBaseHtmlURL], videoModel.fromId];
//    webVc.requestURL = url;
//    [self.commentView addSubview:webVc.view];
//    webVc.view.frame = CGRectMake(0, 45.0f, kMainScreenWidth, 1.0f/2.0f *kMainScreenHeight - 45.0f);
//    webVc.webView.frame = CGRectMake(0, 0, kMainScreenWidth, 1.0f/2.0f *kMainScreenHeight - 45.0f);
//    [self.commentBackView addSubview:self.commentView];
//    [UIView animateWithDuration:0.25 animations:^{
//        self.commentView.frame = CGRectMake(0,  1.0f/2.0f *kMainScreenHeight, kMainScreenWidth, 1.0f/2.0f *kMainScreenHeight);
//    } completion:^(BOOL finished) {
//        self.commentView.frame = CGRectMake(0,  1.0f/2.0f *kMainScreenHeight, kMainScreenWidth, 1.0f/2.0f *kMainScreenHeight);
//    }];
//    self.webVc = webVc;
//    [self commentMonitor:videoModel.fromId];
//    UIApplication *application = [UIApplication sharedApplication];
//    UIStatusBarStyle barstyle = UIStatusBarStyleLightContent;
//    [application setStatusBarStyle:barstyle];
}

- (void)upperShortVideo:(PASShortVideoItemModel *)videoModel isAgree:(BOOL)value
{
    NSString *agree = @"1";
    if (!value) {
        agree = @"0";
    }
    NSDictionary *param = @{
        @"like" : agree,
        @"relevantId" : videoModel.fromId ?: @""
    };
    @pas_weakify_self
//    [self.dataLoader sendRequestForAgreeShortVideo:param block:^(NSInteger status, id obj) {
//        @pas_strongify_self
//        if ([obj isKindOfClass:[NSDictionary class]]) {
//            id status = [obj objectForKey:@"status"];
//            if (status && [status intValue] == 1) {
//                videoModel.isAgree = value;
//            }
//        }
//    }];
    [self agreeMonitor:videoModel.fromId];
}

#pragma mark monitor
- (void)dragDownMonitor:(NSString *)videoId
{
    
}

- (void)dragUpMonitor:(NSString *)videoId
{
    
}

- (void)commentMonitor:(NSString *)videoId
{
    
}

- (void)agreeMonitor:(NSString *)videoId
{
    
}

- (void)shareMonitor:(NSString *)videoId
{
    
}

@end
