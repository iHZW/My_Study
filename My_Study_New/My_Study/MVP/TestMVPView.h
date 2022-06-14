//
//  TestMVPView.h
//  My_Study
//
//  Created by HZW on 2021/9/6.
//  Copyright © 2021 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TestMVPView;

@protocol TestMVPViewDelegate <NSObject>

@optional
- (void)mvpViewClickDelegate:(TestMVPView *_Nullable)mvpView;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TestMVPView : UIView

@property (nonatomic, weak) id<TestMVPViewDelegate>  delegate;

- (void)setName:(NSString *)name iamgeName:(NSString *)imageName;

@end

NS_ASSUME_NONNULL_END
