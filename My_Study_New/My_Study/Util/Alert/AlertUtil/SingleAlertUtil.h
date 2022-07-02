//
//  SingleAlertUtil.h
//  CRM
//
//  Created by js on 2019/12/6.
//  Copyright © 2019 js. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SingleAlertUtil : NSObject

+ (void)confirm:(nullable NSString*)title
            msg:(nullable NSString *)msg
        okBlock:(nullable void(^)(void))okBlock;

+ (void)logoutChangeCorp:(nullable NSString*)title
                     msg:(nullable NSString *)msg
              cancelText:(NSString *)cancelText
             confirmText:(NSString *)confirmText
             cancelBlock:(void(^)(void))cancelBlock
            confirmBlock:(void(^)(void))okBlock;
@end

NS_ASSUME_NONNULL_END
