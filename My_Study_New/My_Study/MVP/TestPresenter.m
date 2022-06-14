//
//  TestPresenter.m
//  My_Study
//
//  Created by HZW on 2021/9/6.
//  Copyright © 2021 HZW. All rights reserved.
//

#import "TestPresenter.h"
#import "TestMVPView.h"
#import "TestMVPModel.h"

@interface TestPresenter ()<TestMVPViewDelegate>

@property (nonatomic, weak) UIViewController *presenterCtrl;

@property (nonatomic, strong) TestMVPView *testMVPView;

@end

@implementation TestPresenter

- (instancetype)initWithController:(UIViewController *)controller
{
    if (self = [super init]) {
        self.presenterCtrl = controller;
        
        self.testMVPView = [[TestMVPView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight - 200)];
        self.testMVPView.backgroundColor = [UIColor grayColor];
        self.testMVPView.delegate = self;
        [self.presenterCtrl.view addSubview:self.testMVPView];
        
        TestMVPModel *model = [[TestMVPModel alloc] init];
        model.name = @"张三";
        model.imageName = @"mvp";
        
        [self.testMVPView setName:model.name iamgeName:model.imageName];
        
    }
    return self;
}

- (void)mvpViewClickDelegate:(TestMVPView *)mvpView
{
    NSLog(@"%s", __func__);
    
    [self.testMVPView setName:@"李四" iamgeName:@"mvp"];;

}

@end
