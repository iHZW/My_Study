//
//  ZWAbstractModule.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/29.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWAbstractModule.h"

@interface ZWAbstractModule ()
{
    BOOL _reloadTableView;
}

@end

@implementation ZWAbstractModule
@synthesize reloadTableView = _reloadTableView;

- (id)initWithData:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        self.reloadTableView = NO;
    }
    return self;
}

- (NSInteger)numberOfRows
{
    [NSException raise:@"subClass should override this method" format:@"methd:%s", __FUNCTION__];
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndex:(NSInteger)row
{
    [NSException raise:@"subClass should override this method" format:@"methd:%s", __FUNCTION__];
    return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndex:(NSInteger)row
{
    [NSException raise:@"subClass should override this method" format:@"methd:%s", __FUNCTION__];
    return nil;
}

@end
