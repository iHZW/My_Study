//
//  URLProtocolHelper.h
//  WMOA
//
//  Created by fhkvsou on 2019/1/28.
//  Copyright © 2019年 weimob. All rights reserved.
//
#if APPLOGOPEN
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DebugLogHelper : NSObject

@property (nonatomic ,strong) UIButton * logButton;

@property (nonatomic,assign) BOOL isSwizzle;

+ (DebugLogHelper *)shared;


- (void)addLogButton;
///**
// *  swizzle NSURLSessionConfiguration's protocolClasses method
// */
//- (void)load;
//
///**
// *  make NSURLSessionConfiguration's protocolClasses method is normal
// */
//- (void)unload;

@end
NS_ASSUME_NONNULL_END
#endif
