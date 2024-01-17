//
//  ZWBindingViewModel.h
//  My_Study
//
//  Created by hzw on 2024/1/17.
//  Copyright © 2024 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZWBindingItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWBindingViewModel : NSObject

@property (nonatomic, copy) NSArray <ZWBindingItem *>*data;

- (void)fetchData;

- (void)_handleCellAction:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
