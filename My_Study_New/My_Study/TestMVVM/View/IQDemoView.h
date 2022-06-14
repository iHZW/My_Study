//
//  IQDemoView.h
//  My_Study
//
//  Created by HZW on 2019/5/27.
//  Copyright © 2019 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class IQViewModel;

@interface IQDemoView : UITableViewCell

- (void)updateViewWithViewModel:(IQViewModel *)viewModel;


@end

NS_ASSUME_NONNULL_END
