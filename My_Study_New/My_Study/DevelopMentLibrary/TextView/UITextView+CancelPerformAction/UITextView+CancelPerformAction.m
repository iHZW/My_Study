//
//  UITextView+CancelPerformAction.m
//  PASecuritiesApp
//
//  Created by iBarretLee on 2019/3/22.
//  Copyright © 2019 PAS. All rights reserved.
//

#import "UITextView+CancelPerformAction.h"
#import <objc/runtime.h>

@implementation UITextView (CancelPerformAction)

+(void)load
{
    [super load];
    method_exchangeImplementations(class_getInstanceMethod(self.class, NSSelectorFromString(@"canPerformAction:withSender:")),
                                   class_getInstanceMethod(self.class, @selector(cancelPerformAction:withSender:)));
}

- (BOOL)cancelPerformAction:(SEL)action withSender:(id)sender
{
    if (!self.isCancelPerformAction) {
        return [self cancelPerformAction:action withSender:sender];
    }
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController)
    {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    return NO;
}

- (void)setIsCancelPerformAction:(BOOL)isCancelPerformAction{
    objc_setAssociatedObject(self, &"isCancelPerformAction", @(isCancelPerformAction), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isCancelPerformAction{
    return objc_getAssociatedObject(self,  &"isCancelPerformAction");
}


@end
