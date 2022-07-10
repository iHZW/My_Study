//
//  WKWebViewConfiguration+Conslog.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "WKWebViewConfiguration+Conslog.h"
#import <objc/runtime.h>

static const void *associateKey = "associateKey";

@implementation WKWebViewConfiguration (Conslog)

- (void)setShowConsole:(BOOL)showConsole {
    objc_setAssociatedObject(self, associateKey, @(showConsole), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)showConsole {
    NSNumber *numberValue = objc_getAssociatedObject(self, associateKey);
    return [numberValue boolValue];
}

@end
