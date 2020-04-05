//
//  Dog.h
//  My_Study
//
//  Created by HZW on 2020/4/4.
//  Copyright © 2020 HZW. All rights reserved.
//
/**< 狗🐶 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Dog : NSObject

- (void)sendMessage:(NSString *)msg;

- (void)sendMessageName:(NSString *)msg age:(NSInteger)age;


+ (void)sendClassMessage:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
