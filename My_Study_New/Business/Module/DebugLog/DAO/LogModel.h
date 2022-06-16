//
//  LogModel.h
//  CRM
//
//  Created by js on 2019/8/27.
//  Copyright © 2019 js. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LogModel : NSObject
@property (nonatomic, assign) NSUInteger identifier;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, copy) NSString *level;
@property (nonatomic, copy) NSString *flag;
@property (nonatomic, copy) NSString *thread;
@property (nonatomic, copy) NSString *context;
@property (nonatomic, strong) NSDate *createTime;
@property (nonatomic, assign) NSUInteger count;
@end

NS_ASSUME_NONNULL_END
