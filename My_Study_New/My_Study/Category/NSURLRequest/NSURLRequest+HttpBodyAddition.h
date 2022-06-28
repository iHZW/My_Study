//
//  NSURLRequest+HttpBodyAddition.h
//  WMOA
//
//  Created by fhkvsou on 2019/1/28.
//  Copyright © 2019年 weimob. All rights reserved.
//
#if DOKIT
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLRequest (HttpBodyAddition)

- (NSURLRequest *)cyl_getPostRequestIncludeBody;


@end

NS_ASSUME_NONNULL_END
#endif
