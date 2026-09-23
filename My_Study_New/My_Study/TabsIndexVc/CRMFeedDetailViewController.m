//
//  CRMFeedDetailViewController.m
//  My_Study
//
//  Created by Codex on 2026/7/8.
//  Copyright © 2026 HZW. All rights reserved.
//

#import "CRMFeedDetailViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface CRMFeedDetailViewController () <UIScrollViewDelegate>

@property (nonatomic, copy) NSDictionary *feedInfo;
@property (nonatomic, assign) BOOL video;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UIScrollView *imageScrollView;
@property (nonatomic, strong) UIView *pageIndicatorView;
@property (nonatomic, strong) UILabel *articleTextLabel;
@property (nonatomic, strong) NSArray<UIView *> *carouselPages;
@property (nonatomic, strong) NSArray<UIView *> *indicatorDots;
@property (nonatomic, assign) CGFloat carouselPageWidth;
@property (nonatomic, assign) CGFloat carouselPageStride;
@property (nonatomic, assign) NSInteger carouselDragStartPage;

@end

@implementation CRMFeedDetailViewController

- (instancetype)initWithFeedInfo:(NSDictionary *)feedInfo {
    self = [super init];
    if (self) {
        _feedInfo = [feedInfo copy];
        _video = [feedInfo[@"video"] boolValue];
        self.hideNavigationBar = YES;
        self.hidesBottomBarWhenPushed = YES;
        self.hideTabbar = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = self.video ? UIColor.blackColor : UIColor.whiteColor;
    [self setupTopBar];
    if (self.video) {
        [self setupVideoDetail];
    } else {
        [self setupArticleDetail];
    }
    [self setupBottomBar];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    CGFloat topInset = 0;
    CGFloat bottomInset = 0;
    if (@available(iOS 11.0, *)) {
        topInset = self.view.safeAreaInsets.top;
        bottomInset = self.view.safeAreaInsets.bottom;
    } else {
        topInset = kSysStatusBarHeight;
    }

    CGFloat topHeight = 72;
    CGFloat bottomHeight = 72 + bottomInset;
    self.topBar.frame = CGRectMake(0, 0, width, topInset + topHeight);
    self.bottomBar.frame = CGRectMake(0, height - bottomHeight, width, bottomHeight);
    self.contentView.frame = CGRectMake(0, CGRectGetMaxY(self.topBar.frame), width, CGRectGetMinY(self.bottomBar.frame) - CGRectGetMaxY(self.topBar.frame));

    if (self.video) {
        self.playerLayer.frame = self.contentView.bounds;
    } else {
        CGFloat imageHeight = MIN(CGRectGetHeight(self.contentView.bounds) * 0.58, width * 1.16);
        self.imageScrollView.frame = CGRectMake(0, 0, width, imageHeight);
        self.carouselPageWidth = floor(width * 0.90);
        self.carouselPageStride = 46.0;
        CGFloat sideInset = (width - self.carouselPageWidth) * 0.5;
        for (NSInteger index = 0; index < self.carouselPages.count; index++) {
            UIView *view = self.carouselPages[index];
            view.frame = CGRectMake(sideInset + index * self.carouselPageStride, 8, self.carouselPageWidth, imageHeight - 16);
            UIView *label = view.subviews.firstObject;
            label.frame = view.bounds;
            view.layer.cornerRadius = 14;
            view.layer.masksToBounds = NO;
            view.layer.shadowColor = UIColor.blackColor.CGColor;
            view.layer.shadowOpacity = 0.18;
            view.layer.shadowRadius = 12;
            view.layer.shadowOffset = CGSizeMake(0, 6);
            view.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:14].CGPath;
            view.layer.doubleSided = NO;
        }
        self.imageScrollView.contentSize = CGSizeMake(width + MAX(0, self.carouselPages.count - 1) * self.carouselPageStride, imageHeight);
        self.pageIndicatorView.frame = CGRectMake((width - [self pageIndicatorWidth]) * 0.5, imageHeight + 12, [self pageIndicatorWidth], 8);
        [self layoutIndicatorDots];
        [self updateCarouselForOffset:self.imageScrollView.contentOffset.x];
        self.articleTextLabel.frame = CGRectMake(18, imageHeight + 18, width - 36, 132);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player pause];
}

- (void)setupTopBar {
    self.topBar = [[UIView alloc] initWithFrame:CGRectZero];
    self.topBar.backgroundColor = self.video ? UIColor.blackColor : UIColor.whiteColor;
    [self.view addSubview:self.topBar];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(18, 42, 44, 44);
    backButton.titleLabel.font = [UIFont systemFontOfSize:34 weight:UIFontWeightLight];
    [backButton setTitle:@"‹" forState:UIControlStateNormal];
    [backButton setTitleColor:self.video ? UIColor.whiteColor : UIColorFromRGB(0x222222) forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.topBar addSubview:backButton];

    if (self.video) {
        NSArray<NSString *> *icons = @[@"⌕", @"↗"];
        for (NSInteger index = 0; index < icons.count; index++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(CGRectGetWidth(UIScreen.mainScreen.bounds) - 110 + index * 54, 42, 44, 44);
            button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            button.titleLabel.font = [UIFont systemFontOfSize:30 weight:UIFontWeightRegular];
            [button setTitle:icons[index] forState:UIControlStateNormal];
            [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            [self.topBar addSubview:button];
        }
    } else {
        UIView *avatar = [[UIView alloc] initWithFrame:CGRectMake(70, 48, 34, 34)];
        avatar.layer.cornerRadius = 17;
        avatar.layer.masksToBounds = YES;
        avatar.backgroundColor = [self colorFromFeedKey:@"endColor"];
        [self.topBar addSubview:avatar];

        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(114, 48, 180, 34)];
        nameLabel.text = self.feedInfo[@"author"] ?: @"营养师暖阳";
        nameLabel.font = [UIFont boldSystemFontOfSize:16];
        nameLabel.textColor = UIColorFromRGB(0x333333);
        [self.topBar addSubview:nameLabel];

        UIButton *followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        followButton.frame = CGRectMake(CGRectGetWidth(UIScreen.mainScreen.bounds) - 142, 48, 92, 34);
        followButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        followButton.layer.cornerRadius = 17;
        followButton.layer.borderWidth = 1;
        followButton.layer.borderColor = UIColorFromRGB(0xff3850).CGColor;
        followButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [followButton setTitle:@"立即关注" forState:UIControlStateNormal];
        [followButton setTitleColor:UIColorFromRGB(0xff3850) forState:UIControlStateNormal];
        [self.topBar addSubview:followButton];

        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        shareButton.frame = CGRectMake(CGRectGetWidth(UIScreen.mainScreen.bounds) - 50, 44, 44, 44);
        shareButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        shareButton.titleLabel.font = [UIFont systemFontOfSize:30];
        [shareButton setTitle:@"↗" forState:UIControlStateNormal];
        [shareButton setTitleColor:UIColorFromRGB(0x222222) forState:UIControlStateNormal];
        [self.topBar addSubview:shareButton];
    }
}

- (void)setupVideoDetail {
    self.contentView = [[UIView alloc] initWithFrame:CGRectZero];
    self.contentView.backgroundColor = UIColor.blackColor;
    [self.view addSubview:self.contentView];

    NSString *path = [NSBundle.mainBundle pathForResource:@"XYVideo" ofType:@"mp4"];
    if (path.length > 0) {
        NSURL *url = [NSURL fileURLWithPath:path];
        self.player = [AVPlayer playerWithURL:url];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self.contentView.layer addSublayer:self.playerLayer];
        [self.player play];
    } else {
        UILabel *placeholder = [[UILabel alloc] initWithFrame:CGRectZero];
        placeholder.text = @"视频播放区域";
        placeholder.textAlignment = NSTextAlignmentCenter;
        placeholder.textColor = UIColor.whiteColor;
        placeholder.font = [UIFont boldSystemFontOfSize:24];
        placeholder.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        placeholder.frame = self.contentView.bounds;
        [self.contentView addSubview:placeholder];
    }

    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, CGRectGetWidth(UIScreen.mainScreen.bounds) - 36, 120)];
    infoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    infoLabel.numberOfLines = 0;
    infoLabel.textColor = UIColor.whiteColor;
    infoLabel.font = [UIFont systemFontOfSize:17];
    infoLabel.text = [NSString stringWithFormat:@"%@\n#好视频扶持计划 #商业思维 #信息差 #这份工作", self.feedInfo[@"title"] ?: @"不体面但能挣的工作，两年80W!"];
    [self.contentView addSubview:infoLabel];
}

- (void)setupArticleDetail {
    self.contentView = [[UIView alloc] initWithFrame:CGRectZero];
    self.contentView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.contentView];

    self.imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.imageScrollView.pagingEnabled = NO;
    self.imageScrollView.bounces = NO;
    self.imageScrollView.clipsToBounds = NO;
    self.imageScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.imageScrollView.showsHorizontalScrollIndicator = NO;
    self.imageScrollView.delegate = self;
    [self.contentView addSubview:self.imageScrollView];

    NSArray<NSString *> *texts = @[@"图文\n资讯", @"内容\n轮播", @"重点\n信息", @"评论\n互动"];
    NSMutableArray<UIView *> *pages = [NSMutableArray arrayWithCapacity:texts.count];
    for (NSInteger index = 0; index < texts.count; index++) {
        UIView *page = [[UIView alloc] initWithFrame:CGRectZero];
        page.backgroundColor = index % 2 == 0 ? [self colorFromFeedKey:@"startColor"] : [self colorFromFeedKey:@"endColor"];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.frame = page.bounds;
        label.text = texts[index];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.font = [UIFont boldSystemFontOfSize:46];
        label.textColor = UIColor.whiteColor;
        [page addSubview:label];
        [self.imageScrollView addSubview:page];
        [pages addObject:page];
    }
    self.carouselPages = pages;

    self.pageIndicatorView = [[UIView alloc] initWithFrame:CGRectZero];
    self.pageIndicatorView.userInteractionEnabled = NO;
    [self.contentView addSubview:self.pageIndicatorView];

    NSMutableArray<UIView *> *dots = [NSMutableArray arrayWithCapacity:texts.count];
    for (NSInteger index = 0; index < texts.count; index++) {
        UIView *dot = [[UIView alloc] initWithFrame:CGRectZero];
        dot.layer.cornerRadius = 4;
        dot.layer.masksToBounds = YES;
        dot.backgroundColor = index == 0 ? UIColorFromRGB(0xff3850) : UIColorFromRGB(0xd6d6d6);
        [self.pageIndicatorView addSubview:dot];
        [dots addObject:dot];
    }
    self.indicatorDots = dots;

    self.articleTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.articleTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.articleTextLabel.numberOfLines = 0;
    self.articleTextLabel.font = [UIFont boldSystemFontOfSize:21];
    self.articleTextLabel.textColor = UIColorFromRGB(0x333333);
    self.articleTextLabel.text = [NSString stringWithFormat:@"%@\n#多囊 #健康饮食 #图文资讯 #评论区", self.feedInfo[@"title"] ?: @"男士备孕多吃这10种食物"];
    [self.contentView addSubview:self.articleTextLabel];
}

- (void)setupBottomBar {
    self.bottomBar = [[UIView alloc] initWithFrame:CGRectZero];
    self.bottomBar.backgroundColor = self.video ? UIColor.blackColor : UIColor.whiteColor;
    [self.view addSubview:self.bottomBar];

    UIView *input = [[UIView alloc] initWithFrame:CGRectMake(18, 10, 190, 44)];
    input.layer.cornerRadius = 22;
    input.backgroundColor = self.video ? UIColorFromRGB(0x202020) : UIColorFromRGB(0xf4f4f4);
    [self.bottomBar addSubview:input];

    UILabel *inputLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, 160, 44)];
    inputLabel.text = @"说点什么...";
    inputLabel.font = [UIFont systemFontOfSize:15];
    inputLabel.textColor = UIColorFromRGB(0x888888);
    [input addSubview:inputLabel];

    NSArray<NSString *> *items = @[@"♡ 373", @"☆ 176", @"◌ 95"];
    CGFloat startX = 226;
    for (NSInteger index = 0; index < items.count; index++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(startX + index * 78, 10, 72, 44)];
        label.font = [UIFont boldSystemFontOfSize:20];
        label.textColor = self.video ? UIColor.whiteColor : UIColorFromRGB(0x222222);
        label.text = items[index];
        [self.bottomBar addSubview:label];
    }
}

- (UIColor *)colorFromFeedKey:(NSString *)key {
    UIColor *color = self.feedInfo[key];
    return [color isKindOfClass:UIColor.class] ? color : UIColorFromRGB(0x79d5ff);
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.imageScrollView && scrollView.bounds.size.width > 0) {
        [self updateCarouselForOffset:scrollView.contentOffset.x];
        NSInteger page = lround(scrollView.contentOffset.x / MAX(1, self.carouselPageStride));
        NSInteger safePage = MAX(0, MIN(page, self.indicatorDots.count - 1));
        [self updateIndicatorForPage:safePage];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView != self.imageScrollView || self.carouselPageStride <= 0) {
        return;
    }

    NSInteger page = lround(scrollView.contentOffset.x / self.carouselPageStride);
    self.carouselDragStartPage = MAX(0, MIN(page, self.carouselPages.count - 1));
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                      withVelocity:(CGPoint)velocity
               targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView != self.imageScrollView || self.carouselPageStride <= 0) {
        return;
    }

    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView];
    NSInteger targetIndex = self.carouselDragStartPage;
    if (velocity.x > 0.12 || translation.x < -28.0) {
        targetIndex += 1;
    } else if (velocity.x < -0.12 || translation.x > 28.0) {
        targetIndex -= 1;
    } else {
        targetIndex = lround(scrollView.contentOffset.x / self.carouselPageStride);
    }

    targetIndex = MAX(0, MIN(targetIndex, self.carouselPages.count - 1));
    targetContentOffset->x = targetIndex * self.carouselPageStride;
    targetContentOffset->y = 0;
}

- (CGFloat)pageIndicatorWidth {
    NSInteger count = self.carouselPages.count;
    if (count <= 0) {
        return 0;
    }
    return count * 8 + MAX(0, count - 1) * 6;
}

- (void)layoutIndicatorDots {
    CGFloat x = 0;
    for (UIView *dot in self.indicatorDots) {
        dot.frame = CGRectMake(x, 0, 8, 8);
        dot.layer.cornerRadius = 4;
        x += 14;
    }
}

- (void)updateIndicatorForPage:(NSInteger)page {
    [self.indicatorDots enumerateObjectsUsingBlock:^(UIView *_Nonnull dot, NSUInteger idx, BOOL *_Nonnull stop) {
        dot.backgroundColor = idx == page ? UIColorFromRGB(0xff3850) : UIColorFromRGB(0xd6d6d6);
        dot.transform = idx == page ? CGAffineTransformMakeScale(1.15, 1.15) : CGAffineTransformIdentity;
    }];
}

- (void)updateCarouselForOffset:(CGFloat)offset {
    if (self.carouselPageStride <= 0) {
        return;
    }

    CGFloat currentIndex = offset / self.carouselPageStride;
    [self.carouselPages enumerateObjectsUsingBlock:^(UIView *_Nonnull page, NSUInteger idx, BOOL *_Nonnull stop) {
        CGFloat distance = idx - currentIndex;
        CGFloat absDistance = fabs(distance);
        CGFloat limitedDistance = MIN(absDistance, 3.0);
        CGFloat scale = 1.0 - limitedDistance * 0.035;
        CGFloat alpha = 1.0 - limitedDistance * 0.08;
        CGFloat rotateY = distance * -0.035;
        CGFloat translateX = distance >= 0 ? distance * 10.0 : distance * 28.0;
        CGFloat translateY = distance >= 0 ? limitedDistance * 3.0 : limitedDistance * 8.0;

        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1.0 / 1000.0;
        transform = CATransform3DTranslate(transform, translateX, translateY, -limitedDistance * 18.0);
        transform = CATransform3DRotate(transform, rotateY, 0, 1, 0);
        transform = CATransform3DScale(transform, scale, scale, 1);
        page.layer.transform = transform;
        page.layer.zPosition = 1000 - absDistance * 10.0;
        page.alpha = MAX(0.55, alpha);
    }];
}

@end
