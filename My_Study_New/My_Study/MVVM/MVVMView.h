//
//  MVVMView.h
//  My_Study
//
//  Created by HZW on 2021/9/6.
//  Copyright © 2021 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MVVMView, MVVMViewModel;

@protocol MVVMViewDelegate <NSObject>

@optional
- (void)mvvmViewClickDelegate:(MVVMView *_Nullable)mvpView;

@end

@interface MVVMView : UIView

- (instancetype)initWithViewModel:(MVVMViewModel *)viewModel;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *imageName;

@property (nonatomic, weak) id<MVVMViewDelegate>  delegate;

@end

NS_ASSUME_NONNULL_END
