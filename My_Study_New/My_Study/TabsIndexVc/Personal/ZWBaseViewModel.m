//
//  ZWBaseViewModel.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/29.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWBaseViewModel.h"

@interface ZWBaseViewModel ()

@property (nonatomic, strong, readwrite) ZWBaseView *view;

@end

@implementation ZWBaseViewModel


- (CGFloat)heightView
{
    [NSException raise:@"subClass should override this method" format:@"methd:%s", __FUNCTION__];
    return 0.0f;
}

- (NSString *)reuseIdentifier
{
    [NSException raise:@"subClass should override this method" format:@"methd:%s", __FUNCTION__];
    return @"";
}

- (void)refreshView
{
    
}

- (void)themeChangeNotification
{
    
}


@end
