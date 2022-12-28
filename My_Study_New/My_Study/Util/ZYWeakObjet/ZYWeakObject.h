//
//  ZYWeakObject.h
//  test1
//
//  Created by zhouyang on 2018/8/2.
//  Copyright © 2018年 zhouyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYWeakObject : NSObject

- (instancetype)initWithWeakObject:(id)obj;

+ (instancetype)proxyWithWeakObject:(id)obj;

@end
