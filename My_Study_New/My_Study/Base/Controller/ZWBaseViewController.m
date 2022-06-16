//
//  BaseViewController.m
//  MainSubControllerDemo
//
//  Created by HZW on 2019/5/22.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "ZWBaseViewController.h"

@interface ZWBaseViewController ()

@end

@implementation ZWBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];// [UIColor randomColor];
    // Do any additional setup after loading the view.
    
    /* 默认加载 */
    if (!self.isTabVc) {
        [self initLeftNav];
        [self initRightNav];
    }

}

- (void)setIsTabVc:(BOOL)isLoadBackBtn
{
    _isTabVc = isLoadBackBtn;
}


/* 初始化导航 */
- (void)initLeftNav{
    UIButton * backBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 40, 40, 40)];
    backBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [backBtn setImage:[UIImage imageNamed:@"icon_nav_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    backBtn.titleLabel.font = PASFont(15);
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)initRightNav
{
    
}

- (void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.navigationBarHidden = YES;
}



#pragma mark --摇一摇功能 和 LookinServer功能
//让当前控制器成为第一响应者，只有这样才能接收事件，所以此段代码必须加到控制器中
- (BOOL)canBecomeFirstResponder
{
    return YES;// default is NO
}
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"开始摇动手机");
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"结束");
    if (motion == UIEventSubtypeMotionShake) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"Lookin功能列表" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"导出为 Lookin 文档" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Lookin_Export" object:nil];
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"进入 2D 模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Lookin_2D" object:nil];
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"进入 3D 模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Lookin_3D" object:nil];
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"取消");
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
