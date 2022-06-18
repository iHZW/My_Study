//
//  ModuleContainer.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/17.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingletonTemplate.h"
#import "HttpClient.h"

#define ZWM   [ModuleContainer sharedModuleContainer]

NS_ASSUME_NONNULL_BEGIN


@interface ModuleContainer : NSObject
DEFINE_SINGLETON_T_FOR_HEADER(ModuleContainer)

@property (nonatomic, strong, readonly) HttpClient *http;

- (void)registerConfig;

@end


NS_ASSUME_NONNULL_END
