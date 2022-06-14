//
//  IQViewModel.h
//  My_Study
//
//  Created by HZW on 2019/5/27.
//  Copyright © 2019 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IQViewModel : NSObject

@property (nonatomic, assign) int age;

@property (nonatomic, copy, readonly) NSString *userName;

@property (nonatomic, copy, readonly) NSString *userPwd;

/**< 初始化ViewModel */
+ (IQViewModel *)demoViewWithName:(NSString *)userName
                          withPwd:(NSString *)userPed;

/**< 更新数据 */
- (void)updateViewModelWithName:(NSString *)userName
                        withPwd:(NSString *)userPwd;

- (void)test;

- (void)print;


@end

NS_ASSUME_NONNULL_END
