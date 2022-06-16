//
//  BaseCellModel.m
//  MainSubControllerDemo
//
//  Created by HZW on 2019/5/22.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "BaseCellModel.h"

@implementation BaseCellModel
+ (instancetype)modelWithTitle:(NSString *)title clazz:(Class)clazz
{
    BaseCellModel *model = [BaseCellModel new];
    model.title = title;
    model.clazz = clazz;
    return model;
}
+ (instancetype)modelWithTitle:(NSString *)title flutterPageName:(NSString *)pageName
{
    BaseCellModel *model = [BaseCellModel new];
    model.title = title;
    model.flutterPageName = pageName;
    model.isFlutterPage = YES;
    return model;
}
@end
