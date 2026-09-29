//
//  ZWCustomData.m
//  My_Study
//
//  Created by hzw on 2025/1/23.
//  Copyright © 2025 HZW. All rights reserved.
//

#import "ZWCustomData.h"

@implementation ZWCustomData

- (instancetype)initWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
                        image:(UIImage *)image {
    self = [super init];
    if (self) {
        _title = title;
        _subtitle = subtitle;
        _image = image;
    }
    return self;
}

@end
