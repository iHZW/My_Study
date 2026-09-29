//
//  ZWBindingViewModel.m
//  My_Study
//
//  Created by hzw on 2024/1/17.
//  Copyright © 2024 HZW. All rights reserved.
//

#import "ZWBindingViewModel.h"

@implementation ZWBindingViewModel

- (void)fetchData {
    // 模拟数据获取过程
    NSMutableArray *items = [NSMutableArray array];
    for (NSInteger i = 1; i <= 5; i++) {
        ZWBindingItem *item = [[ZWBindingItem alloc] initWithName:[NSString stringWithFormat:@"Item %ld", (long)i]];
        [items addObject:item];
    }
    self.data = [items copy];
}

- (void)_handleCellAction:(NSIndexPath *)indexPath {
    NSString *itemName = [NSString stringWithFormat:@"Item %@", @(arc4random()%100)];
    ZWBindingItem *tempItem = [[ZWBindingItem alloc] initWithName:itemName];
    NSMutableArray *tempArray = [NSMutableArray array];

    if (indexPath.row > 3) {
        // 减少
        [self.data enumerateObjectsUsingBlock:^(ZWBindingItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx != indexPath.row) {
                [tempArray addObject:obj];
            }
        }];
    } else {
        // 增加
        [self.data enumerateObjectsUsingBlock:^(ZWBindingItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [tempArray addObject:obj];
            if (idx == indexPath.row) {
                [tempArray addObject:tempItem];
            }
        }];
    }
    self.data = tempArray;
}

@end
