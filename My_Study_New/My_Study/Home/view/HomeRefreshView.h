//
//  HomeRefreshView.h
//  My_Study
//
//  Created by hzw on 2022/9/24.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMView.h"
#import "HomeViewModel.h"

typedef void(^RefreshActionBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface HomeRefreshView : CMView

@property (nonatomic, weak) HomeViewModel *viewModel;

@property (nonatomic, copy) RefreshActionBlock actinBlock;

@property (nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
