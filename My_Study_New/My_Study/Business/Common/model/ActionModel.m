//
//  ActionModel.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/2.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ActionModel.h"

@implementation ActionModel

+ (instancetype)initWithTitle:(NSString *)title actionName:(NSString *)actionName
{
    ActionModel *model = [[ActionModel alloc] init];
    model.title = title;
    model.actionName = actionName;
    return model;
}

@end
