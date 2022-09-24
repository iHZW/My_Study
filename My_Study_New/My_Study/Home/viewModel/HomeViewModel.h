//
//  HomeViewModel.h
//  My_Study
//
//  Created by hzw on 2022/9/24.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeViewModel : NSObject

@property (nonatomic, copy) NSString *name;

- (void)sendReauestForHomeRefresh;

@end

NS_ASSUME_NONNULL_END
