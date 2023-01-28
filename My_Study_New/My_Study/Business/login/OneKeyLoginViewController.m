//
//  OneKeyLoginViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2023/1/17.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "OneKeyLoginViewController.h"
#import <CL_ShanYanSDK/CL_ShanYanSDK.h>
#import "OneKeyLogin.h"
#import "OneKeyLoginBgView.h"

@interface OneKeyLoginViewController ()<OneKeyLoginBgViewDelegate>

@property (nonatomic, strong) OneKeyLoginBgView* oneKeyLoginBgView;

@property (nonatomic, strong) UIViewController *authTopViewController;

@end

@implementation OneKeyLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [OneKeyLogin sharedOneKeyLogin].viewController = self;
    [[OneKeyLogin sharedOneKeyLogin] preGetPhonenumber];
    [[OneKeyLogin sharedOneKeyLogin] quickAuthLogin:@"一键登录"];
    
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion{
    if ([viewControllerToPresent isKindOfClass:[UINavigationController class]]){
        
        UIViewController *authPageVC = [(UINavigationController *)viewControllerToPresent topViewController];;
        if (authPageVC != nil){
            Class uaAuthViewControllerClass =  NSClassFromString(@"CLShanYanAuthPageViewController");
            Class publicLoginViewControllerClass =  NSClassFromString(@"PublicLoginViewController");
            if ([authPageVC isKindOfClass:uaAuthViewControllerClass]
                || [authPageVC isKindOfClass:publicLoginViewControllerClass]){
                self.authTopViewController = authPageVC;
                [self setAuthPageSubView:self.authTopViewController.view];
            }
        }
    }
    
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}







#pragma mark - 牛逼
// 将要关闭
- (void)viewDidClickClose:(OneKeyLoginBgView *)view {
    
}

//微信登录
//- (void)viewWxButtonDidClickClicked:(OneKeyLoginBgView *)view {
//
//}

// 手机号登录
- (void)viewPhoneButtonDidClickClicked:(OneKeyLoginBgView *)view {
    
}

//其它账号绑定
//- (void)otherLoginButtonDidClickClicked:(OneKeyLoginBgView *)view {
//
//}



#pragma mark -  Lazy loading
- (OneKeyLoginBgView *)oneKeyLoginBgView{
    if (!_oneKeyLoginBgView){
        _oneKeyLoginBgView = [[OneKeyLoginBgView alloc] initWithFrame:CGRectZero];
        _oneKeyLoginBgView.delegate = self;
    }
    return _oneKeyLoginBgView;
}

- (void)setAuthPageSubView:(UIView *)containerView{
    self.oneKeyLoginBgView.frame = containerView.bounds;
    [containerView addSubview:self.oneKeyLoginBgView];
    
}

@end
