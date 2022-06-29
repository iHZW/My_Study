//
//  ZWBaseViewModel.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/29.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMObject.h"
#import "ZWBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PASBaseViewModelAdapter <NSObject>

@property (nonatomic, strong, readonly) ZWBaseView * _Nonnull view;

@required
- (CGFloat)heightView; //view高度

- (NSString *_Nonnull)reuseIdentifier; //cell复用标识符

- (void)refreshView; //刷新view 内容

- (void)themeChangeNotification; //主题色变更通知

@end

@interface ZWBaseViewModel : CMObject <PASBaseViewModelAdapter>



@end

NS_ASSUME_NONNULL_END
