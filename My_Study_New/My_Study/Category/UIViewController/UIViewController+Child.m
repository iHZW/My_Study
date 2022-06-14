//
//  UIViewController+Child.m
//  CRM
//
//  Created by js on 2019/9/5.
//  Copyright © 2019 js. All rights reserved.
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
