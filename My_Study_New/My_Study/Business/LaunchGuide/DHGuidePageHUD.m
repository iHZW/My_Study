//
//  DHGuidePageHUD.m
//  DHGuidePageHUD
//
//  Created by Apple on 16/7/14.
//  Copyright © 2016年 dingding3w. All rights reserved.
//

#import "DHGuidePageHUD.h"
#import "DHGifImageOperation.h"
#import "XYIntroductionPage.h"
#import "NSTimer+SJAssetAdd.h"

#define DDHidden_TIME   1.0

@interface DHGuidePageHUD ()<UIScrollViewDelegate>
@property (nonatomic, strong) NSArray *imageArray;
//@property (nonatomic, strong) UIPageControl *imagePageControl;
@property (nonatomic, assign) NSInteger slideIntoNumber;
@property (nonatomic, strong) XYIntroductionPage *playerController; //加载视频时使用
@property (nonatomic, assign) NSInteger currentIndex; // 当前页码
@property (nonatomic, strong) UIScrollView *pageScrollView;
@property (nonatomic, strong) NSTimer *cycleTimer;
@property (nonatomic, strong) NSArray *imageNameArray;
@end

@implementation DHGuidePageHUD

- (instancetype)dh_initWithFrame:(CGRect)frame imageNameArray:(NSArray<NSString *> *)imageNameArray buttonIsHidden:(BOOL)isHidden {
    if ([super initWithFrame:frame]) {
        self.slideInto = NO;
        self.currentIndex = 0;
        self.imageNameArray = imageNameArray;
        if (isHidden == YES) {
            self.imageArray = imageNameArray;
        }
        
        // 设置引导视图的scrollview
        UIScrollView *guidePageView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        [guidePageView setContentSize:CGSizeMake(kMainScreenWidth*imageNameArray.count, 0)];
        [guidePageView setBackgroundColor:[UIColor blueColor]];
        [guidePageView setBounces:NO];
        [guidePageView setPagingEnabled:YES];
        [guidePageView setShowsHorizontalScrollIndicator:NO];
        [guidePageView setDelegate:self];
        [self addSubview:guidePageView];
        self.pageScrollView = guidePageView;
        
        // 设置引导页上的跳过按钮
        UIButton *skipButton = [[UIButton alloc]initWithFrame:CGRectMake(kMainScreenWidth*0.78, 20, 100, 100)];
        [skipButton setBackgroundColor:[UIColor clearColor]];
        [skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [skipButton.layer setCornerRadius:(skipButton.frame.size.height * 0.5)];
        skipButton.tag = GuideActionTypeJump;
        [skipButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:skipButton];
        
        // 添加在引导视图上的多张引导图片
        for (int i=0; i<imageNameArray.count; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(frame)*i, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
            if ([[DHGifImageOperation dh_contentTypeForImageData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageNameArray[i] ofType:nil]]] isEqualToString:@"gif"]) {
                NSData *localData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageNameArray[i] ofType:nil]];
                imageView = (UIImageView *)[[DHGifImageOperation alloc] initWithFrame:imageView.frame gifImageData:localData];
                [guidePageView addSubview:imageView];
            } else {
                imageView.image = [UIImage imageNamed:imageNameArray[i]];
                [guidePageView addSubview:imageView];
            }
            
            // 设置在最后一张图片上显示进入体验按钮
            if (i == imageNameArray.count-1 && isHidden == NO) {
                [imageView setUserInteractionEnabled:YES];
                UIButton *startButton = [[UIButton alloc]initWithFrame:CGRectMake(kMainScreenWidth*0.1, kMainScreenHeight*0.81, kMainScreenWidth*0.8, 100)];
                startButton.backgroundColor = [UIColor clearColor];
                startButton.tag = GuideActionTypeComplete;
                [startButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                [imageView addSubview:startButton];
            }
        }
        
        /* 开始自动滚动 */
        [self _refreshOrStop:NO];
        
        /** 可以解决 滚动 视图受 导航和tabBar的影响 上下便偏移  */
        if (@available(iOS 11.0, *)) {
            self.pageScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        // 设置引导页上的页面控制器
//        self.imagePageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(kMainScreenWidth*0.0, kMainScreenHeight*0.9, kMainScreenWidth*1.0, kMainScreenHeight*0.1)];
//        self.imagePageControl.currentPage = 0;
//        self.imagePageControl.numberOfPages = imageNameArray.count;
//        self.imagePageControl.pageIndicatorTintColor = [UIColor grayColor];
//        self.imagePageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
//        [self addSubview:self.imagePageControl];
//
    }
    return self;
}

/* 更新滚动视图偏移量 */
- (void)updateScrollViewContentOffset
{
    if (self.imageNameArray.count > 0) {
        CGFloat contentOffsetX = self.pageScrollView.contentOffset.x;
        NSInteger pageCount = contentOffsetX /CGRectGetWidth(self.pageScrollView.frame);
        CGFloat pageWidth = self.pageScrollView.width;
        /** 解决滑动过程中 定时器触发滚动,导致滚动超出屏幕  */
        CGFloat adjustOffsetX = pageCount*pageWidth;
        /* 允许的最大滚动距离 */
        CGFloat maxRollingDistance = pageWidth * (self.imageNameArray.count - 1);
        if (adjustOffsetX < maxRollingDistance) {
            [self.pageScrollView setContentOffset:CGPointMake(adjustOffsetX + pageWidth, 0) animated:YES];
        } else {
            [self _refreshOrStop:YES];
        }
    } else {
        [self _refreshOrStop:YES];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollview {
    int page = scrollview.contentOffset.x / scrollview.frame.size.width;
    self.currentIndex = page;
    if (self.imageArray && page == self.imageArray.count-1 && self.slideInto == NO) {
        [self buttonClick:nil];
    }
    if (self.imageArray && page < self.imageArray.count-1 && self.slideInto == YES) {
        self.slideIntoNumber = 1;
    }
    if (self.imageArray && page == self.imageArray.count-1 && self.slideInto == YES) {
        UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:nil action:nil];
        if (swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight){
            self.slideIntoNumber++;
            if (self.slideIntoNumber == 3) {
                [self buttonClick:nil];
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger pageIndex = (scrollView.contentOffset.x / scrollView.frame.size.width);
    if (pageIndex >= self.imageNameArray.count - 1) {
        [self _refreshOrStop:YES];
    }
    /* ... 使用UI的切图,不单独写 */
    // 四舍五入,保证pageControl状态跟随手指滑动及时刷新
//    [self.imagePageControl setCurrentPage:(int)((scrollView.contentOffset.x / scrollView.frame.size.width) + 0.5f)];
}

#pragma mark - EventClick
- (void)buttonClick:(UIButton *)button {
    GuideActionType actionType = GuideActionTypeComplete;
    if (button) {
        actionType = button.tag;
    }
    if (self.playerController) {
        [self.playerController stopPlay];
        self.playerController = nil;
    }
    self.alpha = 0;
    BlockSafeRun(self.guideCompleteBlock, self.currentIndex, actionType);
    [self removeGuidePageHUD];
    
//    [UIView animateWithDuration:DDHidden_TIME animations:^{
//        if (self.playerController) {
//            [self.playerController stopPlay];
//            self.playerController = nil;
//        }
//        self.alpha = 0;
//        BlockSafeRun(self.guideCompleteBlock, self.currentIndex, actionType);
//        [self removeGuidePageHUD];
////        [self performSelector:@selector(removeGuidePageHUD) withObject:nil afterDelay:1];
////        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DDHidden_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////            [self performSelector:@selector(removeGuidePageHUD) withObject:nil afterDelay:1];
////        });
//    }];
}

- (void)removeGuidePageHUD {
    [self _refreshOrStop:YES];
    [self removeFromSuperview];
}

#pragma mark - Timer
- (void)_refreshOrStop:(BOOL)isStop {
    if (isStop) {
        if ( _cycleTimer != nil ) {
            [_cycleTimer invalidate];
            _cycleTimer = nil;
        }
    }
    else {
        if ( _cycleTimer == nil ) {
            __weak typeof(self) _self = self;
            _cycleTimer = [NSTimer sj_timerWithTimeInterval:5 repeats:YES usingBlock:^(NSTimer * _Nonnull timer) {
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                [self updateScrollViewContentOffset];
            }];
            [_cycleTimer sj_fire];
            [NSRunLoop.mainRunLoop addTimer:_cycleTimer forMode:NSRunLoopCommonModes];
        }
    }
}


/**< APP视频新特性页面(新增测试模块内容) */
- (instancetype)dh_initWithFrame:(CGRect)frame videoURL:(NSURL *)videoURL {
    if ([super initWithFrame:frame]) {
        self.currentIndex = 0;
        XYIntroductionPage * xyPage = [[XYIntroductionPage alloc]init];
        xyPage.xyVideoUrl = videoURL;
        xyPage.xyVolume = 0.7;
//        xyPage.xyCoverImgArr = @[]; // 可以设置覆盖的图片数组,暂时不设置
//        xyPage.xyAutoScrolling = YES;
        self.playerController = xyPage;
        [self addSubview:self.playerController.view];
        
        // 设置引导页上的跳过按钮
        UIButton *skipButton = [[UIButton alloc]initWithFrame:CGRectMake(kMainScreenWidth*0.78, 20, 100, 100)];
        [skipButton setTitle:@"跳过" forState: UIControlStateNormal];
        [skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [skipButton setBackgroundColor:[UIColor clearColor]];
        [skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [skipButton.layer setBorderWidth:1.0];
        [skipButton.layer setCornerRadius:(skipButton.frame.size.height * 0.5)];
        skipButton.tag = GuideActionTypeJump;
        [skipButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.playerController.view addSubview:skipButton];
        
        
        // 视频引导页进入按钮
        UIButton *movieStartButton = [[UIButton alloc]initWithFrame:CGRectMake(kMainScreenWidth*0.1, kMainScreenHeight*0.81, kMainScreenWidth*0.8, 100)];
        [movieStartButton.layer setBorderWidth:1.0];
        [movieStartButton.layer setCornerRadius:20.0];
        [movieStartButton.layer setBorderColor:[UIColor whiteColor].CGColor];
        [movieStartButton setTitle:@"开始体验" forState:UIControlStateNormal];
        [movieStartButton setAlpha:0.0];
        movieStartButton.tag = GuideActionTypeComplete;
        [self.playerController.view addSubview:movieStartButton];

        [movieStartButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [UIView animateWithDuration:DDHidden_TIME animations:^{
            [movieStartButton setAlpha:1.0];
        }];
    }
    return self;
}

- (void)dealloc
{
    [self _refreshOrStop:YES];
    NSLog(@"%s -- dealloc",object_getClassName(self));
}

@end
