//
//  JSWeakObject.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "JSWeakObject.h"

@implementation JSWeakObject

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if (_delegate && [_delegate respondsToSelector:@selector(WkUserContentView:didReceiveScriptMessage:)]) {
        [_delegate WkUserContentView:userContentController didReceiveScriptMessage:message];
    }
}

@end
