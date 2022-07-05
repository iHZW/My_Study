//
//  EnvConfigObject.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/5.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EnvConfigObject : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) NSUInteger envType;

@property (nonatomic, copy) NSString *bundleID;

@property (nonatomic, assign) BOOL canManualChange;

@property (nonatomic, strong) NSDictionary *AppConfiguration;

@end

NS_ASSUME_NONNULL_END
