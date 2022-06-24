//
//  AlertUtil.h
//  CRM
//
//  Created by js on 2019/11/8.
//  Copyright © 2019 js. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlertUtil : NSObject
+ (void)confirm:(nullable NSString*)title
            msg:(nullable NSString *)msg
    cancelBlock:(void(^)(void))cancelBlock
        okBlock:(void(^)(void))okBlock;
@end

NS_ASSUME_NONNULL_END
