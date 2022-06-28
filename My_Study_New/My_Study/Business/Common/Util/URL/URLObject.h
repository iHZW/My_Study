//
//  URLObject.h
//  CRM
//
//  Created by js on 2021/12/10.
//  Copyright © 2021 CRM. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface URLObject : NSObject
@property (nonatomic, copy) NSString *host;
@property (nonatomic, strong, nullable) NSDictionary *params;

+ (instancetype)makeObject:(NSString *)host params:(nullable NSDictionary *)params;
@end

NS_ASSUME_NONNULL_END
