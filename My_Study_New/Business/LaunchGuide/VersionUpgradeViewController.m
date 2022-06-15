//
//  VersionUpgradeViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/15.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "VersionUpgradeViewController.h"
#import "StoreUtil.h"

#define IS_IPHONE_X (fabs((double)MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width) - (double )812) < DBL_EPSILON )

//IPhone5适配项
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double )568) < DBL_EPSILON )
//IPhone4适配项
#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double )480) < DBL_EPSILON )
//IPhone6适配项
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double )667) < DBL_EPSILON )

@interface VersionUpgradeViewController ()

@end

@implementation VersionUpgradeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadGuidPage];
}

- (void)loadGuidPage
{
    NSArray *imageNameArray = @[@"launch_guide_1.png",
                                @"launch_guide_2.png",
                                @"launch_guide_3.png",
                                @"launch_guide_4.png"];
    if (IS_IPHONE_X) {
        imageNameArray = @[@"launch_guide_1_X.png",
                           @"launch_guide_2_X.png",
                           @"launch_guide_3_X.png",
                           @"launch_guide_4_X.png"];
    } else if (IS_IPHONE_4 || IS_IPHONE_5 || IS_IPHONE_6){
        //适配小屏使用2倍图
        imageNameArray = @[@"launch_guide_1_min.png",
                           @"launch_guide_2_min.png",
                           @"launch_guide_3_min.png",
                           @"launch_guide_4_min.png"];
    }
    DHGuidePageHUD *guidePage = [[DHGuidePageHUD alloc] dh_initWithFrame:self.view.frame imageNameArray:imageNameArray buttonIsHidden:NO];
    
    /* 可以加载视频 */
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"XYVideo" ofType:@"mp4"];
//    guidePage = [[DHGuidePageHUD alloc] dh_initWithFrame:self.view.frame videoURL:[NSURL fileURLWithPath:filePath]];
    
    @pas_weakify_self
    guidePage.guideCompleteBlock = ^(NSInteger index, GuideActionType type) {
        @pas_strongify_self
        // 打点
        if (type == GuideActionTypeJump) {
//            [StatisticsUtil addStatistic:@"skip" eventType:@"tap" pageName:@"guide_page" additionInfo:@{ @"code":@(index+1)}];
        } else {
//            [StatisticsUtil addStatistic:@"quick_experience" eventType:@"tap" pageName:@"guide_page" additionInfo:@{}];
        }
        
        /* 标记已经显示过启动页,已经启动过app了 */
        [self makeFirstStartApp];
        BlockSafeRun(self.guideCompleteBlock, index, type);
        
//        if (self.isPresentPage) {
//            /* 通过路由 present 进入的引导页,  关闭 */
//            [self dismissViewControllerAnimated:YES completion:nil];
//        } else {
//            [self showProgress];
//            [self.loginViewModel visitorLogin];
//        }
    };
    
    [self.view addSubview:guidePage];
}

#pragma mark - 是否第一次启动判断
+ (NSString *)isFirstStartAppKey{
    return @"isFirstStartAppKey";
}

+ (BOOL)isFirstStartApp{
    NSString *value = [StoreUtil stringForKey:[VersionUpgradeViewController isFirstStartAppKey] isPermanent:NO];
    if (value.length > 0){
        return [value boolValue];
    }
    return NO;
}

- (void)makeFirstStartApp{
    NSString *value = [NSString stringWithFormat:@"%d",YES];
    [StoreUtil setString:value forKey:[VersionUpgradeViewController isFirstStartAppKey] isPermanent:NO];
}



@end
