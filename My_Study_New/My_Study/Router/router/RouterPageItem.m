//
//  RouterPageConfig.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "RouterPageItem.h"

@implementation RouterPageItem

+ (instancetype)makeWithUrl:(NSString *)url
                    clsName:(NSString *)clsName
                       type:(RouterType)type
                attachValue:(NSDictionary *)value
{
    RouterPageItem *routerPage = [[RouterPageItem alloc] init];
    routerPage.url = url;
    routerPage.clsName = clsName;
    routerPage.type = type;
    routerPage.attachValue = value;
    return routerPage;
}

@end
