//
//  UIViewController+Child.m
//  CRM
//
//  Created by Zhiwei Han on 2022/4/22.
//  Copyright © 2022 Zhiwei Han. All rights reserved.
//

#import "UIViewController+Child.h"
#import <objc/runtime.h>
@implementation UIViewController (Child)

- (UIViewController *)displayChildViewController{
    return objc_getAssociatedObject(self, @selector(displayChildViewController));
}

- (void)setDisplayChildViewController:(UIViewController *)displayChildViewController{
    objc_setAssociatedObject(self, @selector(displayChildViewController), displayChildViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
