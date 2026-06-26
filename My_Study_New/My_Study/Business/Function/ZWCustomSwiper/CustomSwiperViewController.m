//
//  CustomSwiperViewController.m
//  My_Study
//
//  Created by hzw on 2025/1/22.
//  Copyright © 2025 HZW. All rights reserved.
//

#import "CustomSwiperViewController.h"
#import "CustomSwipingView.h"
#import "SwiperView.h"
#import "ZWCustomData.h"
#import "ZWCustomeView.h"

#define kEQHUserCardWidth ((kMainScreenWidth - 12 * 2 - 8) / 2)

@interface CustomSwiperViewController () <SwiperViewDelegate>

@property (nonatomic, strong) SwiperView *swiperView;

@end

@implementation CustomSwiperViewController
- (void)initExtendedData {
    [super initExtendedData];

    self.title = @"自定义Swiper";
}

- (void)loadUIData {
    [super loadUIData];
    // 创建自定义数据对象
    ZWCustomData *data1 = [[ZWCustomData alloc] initWithTitle:@"标题1" subtitle:@"副标题1" image:[UIImage imageNamed:@"image1"]];
    ZWCustomData *data2 = [[ZWCustomData alloc] initWithTitle:@"标题2" subtitle:@"副标题2" image:[UIImage imageNamed:@"image2"]];
    ZWCustomData *data3 = [[ZWCustomData alloc] initWithTitle:@"标题3" subtitle:@"副标题3" image:[UIImage imageNamed:@"image3"]];

    // 创建自定义视图
    ZWCustomeView *view1 = [[ZWCustomeView alloc] initWithFrame:CGRectMake(0, 0, kEQHUserCardWidth, 200)];
    [view1 updateWithData:data1];

    ZWCustomeView *view2 = [[ZWCustomeView alloc] initWithFrame:CGRectMake(0, 0, kEQHUserCardWidth, 200)];
    [view2 updateWithData:data2];

    ZWCustomeView *view3 = [[ZWCustomeView alloc] initWithFrame:CGRectMake(0, 0, kEQHUserCardWidth, 200)];
    [view3 updateWithData:data3];

    // 初始化 SwiperView
    CustomSwipingView *swiper = [[CustomSwipingView alloc] initWithFrame:CGRectMake(10, 100, kEQHUserCardWidth, 200) views:@[view1, view2, view3] autoScrollInterval:3.0];
    [swiper setCornerRadius:4.0];
    [self.view addSubview:swiper];

    //    // 更新某个视图中的数据
    //    ZWCustomData *newData = [[ZWCustomData alloc] initWithTitle:@"更新后的标题2" subtitle:@"更新后的副标题2" image:[UIImage imageNamed:@"newImage"]];
    //    [swiper updateData:newData forViewAtIndex:1];
    //
    //    // 替换某个视图
    //    ZWCustomeView *newView = [[ZWCustomeView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
    //    [newView updateWithData:[[ZWCustomData alloc] initWithTitle:@"新视图" subtitle:@"新副标题" image:[UIImage imageNamed:@"newImage"]]];
    //    [swiper replaceView:newView atIndex:0];
    
    [self addSwiperView];
}

- (void)addSwiperView {
    SwiperView *swiper = [[SwiperView alloc] initWithFrame:CGRectMake(10, 450, kEQHUserCardWidth, 200)];
    swiper.delegate = self;
    swiper.autoScrollEnabled = YES;
    swiper.autoScrollInterval = 3.0;
    self.swiperView = swiper;
    [self.view addSubview:self.swiperView];

    // 初始数据
    NSArray *items = @[@"Item 1", @"Item 2", @"Item 3", @"Item 4"];
    [swiper reloadDataWithItems:items];

    // 3秒后更新部分数据（示例）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.swiperView updateItemsAtIndexes:@[@1, @2] withItems:@[@"Updated 1", @"Updated 2"]];
    });
}

#pragma mark - SwiperViewDelegate

- (UIView *)swiperView:(UIView *)swiperView viewForItemAtIndex:(NSInteger)index {
    UILabel *label = [[UILabel alloc] init];
    label.text = self.swiperView.items[index];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255) / 255.0
                                            green:arc4random_uniform(255) / 255.0
                                             blue:arc4random_uniform(255) / 255.0
                                            alpha:1.0];
    return label;
}

- (void)swiperView:(UIView *)swiperView didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"Selected item at index: %ld", (long)index);
}

@end
