//
//  Monkey.h
//  My_Study
//
//  Created by HZW on 2020/4/4.
//  Copyright © 2020 HZW. All rights reserved.
//
/**< 猴哥🐵 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Monkey : NSObject

@property (nonatomic, copy) NSString *monkeyName;

/**< 响应式编程 */
- (Monkey * (^)(NSString *name))work;

- (Monkey * (^)(NSString *name))play;

- (void)sendMessage:(NSString *)msg;


+ (void)sendClassMessage:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
