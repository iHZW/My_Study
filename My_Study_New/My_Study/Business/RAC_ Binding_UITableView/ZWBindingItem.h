//
//  ZWBindingItem.h
//  My_Study
//
//  Created by hzw on 2024/1/17.
//  Copyright © 2024 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZWBindingItem : NSObject

@property (nonatomic, strong) NSString *itemName;

- (instancetype)initWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
