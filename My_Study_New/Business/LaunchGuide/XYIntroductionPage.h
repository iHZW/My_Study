//
//  XYIntroductionPage.h
//  XYIntroductionPage
//
//  Created by XY Lv on 17/1/20.
//  Copyright © 2017年 吕欣宇. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol XYIntroductionDelegate <NSObject>

- (void)xyIntroductionViewEnterTap:(id)sender;

@end

@interface XYIntroductionPage : UIViewController

@property (nonatomic,strong)UIScrollView * xyPageScrollView;//浮层ScrollView
@property (nonatomic,strong)UIButton     * xyEnterBtn;//进入按钮
@property (nonatomic,assign)BOOL           xyAutoScrolling;//是否自动滚动
@property (nonatomic,assign)BOOL           xyAutoLoopPlayVideo;//是否自动循环播放
@property (nonatomic,assign)BOOL           xyIsAutoEnterOn;//是否滑到最后一张进入
@property (nonatomic,assign)CGPoint        xyPageControlOffSet;//pageControl默认偏移量
@property (nonatomic,strong)UIPageControl *xyPageControl;//引导pageControl


@property (nonatomic,strong)NSArray      * xyBackgroundImgArr;//底层背景图数组
@property (nonatomic,strong)NSArray      * xyCoverImgArr;//浮层图片数组
@property (nonatomic,strong)NSArray      * xyCoverTitlesArr;//浮层文字数组
@property (nonatomic,strong)NSDictionary * xyLabelAttributesDic;//文字特性
@property (nonatomic,assign)float          xyVolume;//声音大小
@property (nonatomic,strong)NSURL     *    xyVideoUrl;//视频地址
@property (nonatomic,strong)NSArray *      xyPageArr;//放置浮层view数组

@property (nonatomic,weak)  id<XYIntroductionDelegate>xyDelegate;

- (instancetype)init;

- (void)xyStopTimer;

- (void)stopPlay;

@end


























































