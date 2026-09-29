//
//  ZWBindingItem.m
//  My_Study
//
//  Created by hzw on 2024/1/17.
//  Copyright © 2024 HZW. All rights reserved.
//

#import "ZWBindingItem.h"

@implementation ZWBindingItem

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _itemName = name;
    }
    return self;
}

@end
