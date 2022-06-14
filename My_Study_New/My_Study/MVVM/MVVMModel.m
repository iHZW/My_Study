//
//  MVVMModel.m
//  My_Study
//
//  Created by HZW on 2021/9/6.
//  Copyright © 2021 HZW. All rights reserved.
//

#import "MVVMModel.h"

@implementation MVVMModel

- (instancetype)initWithName:(NSString *)name imageName:(NSString *)imageName
{
    if (self = [super init]) {
        self.name = name;
        self.imageName = imageName;
    }
    return self;
}

@end
