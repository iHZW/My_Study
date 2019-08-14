//
//  PASSegmentViewController.m
//  PASecuritiesApp
//
//  Created by Weirdln on 16/7/18.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "PASSegmentViewController.h"

@interface PASSegmentViewController ()

@end

@implementation PASSegmentViewController

#pragma mark ----- Overload super methods

- (void)receiveLowMemoryWarning
{
    [super receiveLowMemoryWarning];
    self.segmentCtrl = nil;
}

- (void)loadUIData
{
    [super loadUIData];
    self.view.frame = kMainContentFrame;

    self.segmentCtrl = [[CMSegmentViewController alloc] init];
    self.segmentCtrl.segmentType = self.segmentType;
    self.segmentCtrl.view.frame = self.view.bounds;
    self.segmentCtrl.titles = @[@"", @""];
    self.segmentCtrl.segmentControl.font = PASFont(12);
    self.segmentCtrl.segmentControl.selectFont = PASFont(12);
    self.segmentCtrl.segmentControl.textColor = UIColorFromRGB(0x999999);
    self.segmentCtrl.segmentControl.selectTextColor = UIColorFromRGB(0xaf292e);
    self.segmentCtrl.segmentControl.indicatorColor = [UIColor clearColor];
    self.segmentCtrl.segmentControl.borderColor = [UIColor clearColor];
    self.segmentCtrl.segmentControl.seporatorColor = UIColorFromRGB(0x444444);
    self.segmentCtrl.segmentControl.segmentItemWidth = self.view.width / self.segmentCtrl.titles.count;
    [self addChildViewController:self.segmentCtrl];
    [self.view addSubview:self.segmentCtrl.view];

    CGFloat segmentHeight           = 45;
    self.segmentCtrl.segmentRect    = CGRectMake(0, 0, self.view.width, segmentHeight);
    self.segmentCtrl.containerFrame = CGRectMake(0, segmentHeight, self.view.width, self.view.height - segmentHeight);
}

//- (void)customViewWillAppear:(BOOL)animated
//{
//    [super customViewWillAppear:animated];
//    [(PASBaseViewController *)self.segmentCtrl.currentSelectedViewController customViewWillAppear:animated];
//}
//
//- (void)customViewDidAppear:(BOOL)animated
//{
//    [super customViewDidAppear:animated];
//    [(PASBaseViewController *)self.segmentCtrl.currentSelectedViewController customViewDidAppear:animated];
//}
//
//- (void)customViewWillDisappear:(BOOL)animated
//{
//    [super customViewWillDisappear:animated];
//    [(PASBaseViewController *)self.segmentCtrl.currentSelectedViewController customViewWillDisappear:animated];
//}
//
//- (void)customViewDidDisappear:(BOOL)animated
//{
//    [super customViewDidDisappear:animated];
//    [(PASBaseViewController *)self.segmentCtrl.currentSelectedViewController customViewDidDisappear:animated];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
