//
//  JSWeakObject.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMObject.h"
#import <WebKit/WebKit.h>


NS_ASSUME_NONNULL_BEGIN

// js注入方法传selfu会引起强引用，导致页面无法释放,创建一个对象中间处理

@protocol JSWeakObjectDeleaget <NSObject>

@optional
- (void)WkUserContentView:(WKUserContentController *)contentView didReceiveScriptMessage:(WKScriptMessage *)message;

@end


@interface JSWeakObject : CMObject <WKScriptMessageHandler>

@property (nonatomic ,weak) id <JSWeakObjectDeleaget> delegate;


@end

NS_ASSUME_NONNULL_END
