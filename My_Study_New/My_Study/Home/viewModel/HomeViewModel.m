//
//  HomeViewModel.m
//  My_Study
//
//  Created by hzw on 2022/9/24.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "HomeViewModel.h"
#import "HomeDataLoader.h"
#import "ZWHomeModel.h"

@interface HomeViewModel ()

@property (nonatomic, strong) HomeDataLoader *homeDataLoader;

@end

@implementation HomeViewModel

- (instancetype)init
{
    if (self = [super init]) {
        
        self.homeDataLoader = [[HomeDataLoader alloc] init];
    }
    return self;
}

- (void)sendReauestForHomeRefresh
{
    @pas_weakify_self
    [self.homeDataLoader sendRequestTest:^(NSInteger status, id  _Nullable obj) {
        @pas_strongify_self
        if ([obj isKindOfClass:[ZWHomeModel class]] && status == 1)
        {
            ZWHomeModel *model = obj;
            NSArray *list = model.data.list;
            NSInteger index = arc4random() % (list.count);
            ZWHomeItemInfo *itemInfo = PASArrayAtIndex(list, index);
            self.name = itemInfo.name;
        }
    }];
}

@end
