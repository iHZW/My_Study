//
//  CustomTabbarObject.m
//  CRM
//
//  Created by js on 2021/11/2.
//  Copyright © 2021 CRM. All rights reserved.
//

#import "CustomTabbarObject.h"

@implementation CustomTabbarObject
+ (instancetype)initWith:(NSString *)title iconURL:(NSString *)iconURL icon:(UIImage *)icon color:(NSString *)color selectedColor:(NSString *)selectedColor{
    CustomTabbarObject *object = [[CustomTabbarObject alloc] init];
    object.title = title;
    object.iconUrl = iconURL;
    object.icon = icon;
    object.fontColor = color;
    object.selectedFontColor = selectedColor;
    return object;
}

- (NSString *)displayColor{
    return self.fontColor;
}
@end
