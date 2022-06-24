//
//  UIAlertAction+Ext.m
//  CRM
//
//  Created by js on 2020/1/10.
//  Copyright © 2020 js. All rights reserved.
//

#import "UIAlertAction+Ext.h"

@implementation UIAlertAction (Ext)
- (void)setTextColor:(UIColor *)color{
    [self setValue:color forKey:@"titleTextColor"];
}
@end
