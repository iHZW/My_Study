//
//  TestCoobjcPage.m
//  My_Study
//
//  Created by hzw on 2024/2/21.
//  Copyright © 2024 HZW. All rights reserved.
//

#import "TestCoobjcPage.h"
#import "coobjc/coobjc.h"
#import "UIImageCategory.h"

@interface TestCoobjcPage ()

@end

@implementation TestCoobjcPage

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadSubViews];
    
}

- (void)loadSubViews {
    self.view.backgroundColor = UIColor.whiteColor;
    
}

- (void)viewDidAppear:(BOOL)animated {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self fetchData];
    });
}

- (void)fetchData {
    NSLog(@"Start fetching data...");

    co_launch(^{
        // 异步网络请求
        COPromise *promise = [COPromise promise];
        [self fetchDataFromServerWithCompletion:^(id data, NSError *error) {
            if (error) {
                [promise reject:error];
            } else {
                [promise fulfill:data];
            }
        }];

        // 等待异步结果
        id result = await(promise);
        NSLog(@"Received data: %@", result);

        // 在主线程更新UI
        co_launch_onqueue(dispatch_get_main_queue(), ^{
            [self updateUIWithData:result];
        });
    });
}

- (void)fetchDataFromServerWithCompletion:(void (^)(id, NSError *))completion {
    // 模拟异步网络请求
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 模拟网络请求成功并返回数据
        BOOL success = YES;
        if (success) {
            id data = @"Sample Data";
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(data, nil);
            });
        } else {
            NSError *error = [NSError errorWithDomain:@"NetworkError" code:500 userInfo:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
        }
    });
}

- (void)updateUIWithData:(id)data {
    // 更新UI的操作
    NSLog(@"Updating UI with data: %@", data);
    
    
    UIImage *qrCodeImage = [UIImage creatQRCodeImageWithString:data logoImage:[UIImage imageNamed:@"AppIcon"]];
    UIImageView *codeImageView = [UIImageView imageViewForImage:qrCodeImage withFrame:CGRectMake(0, 0, 100, 100)];
    [self.view addSubview:codeImageView];
    
    [codeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    
}



@end
