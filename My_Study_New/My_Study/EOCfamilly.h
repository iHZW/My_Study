//
//  EOCfamilly.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/3/8.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EOCfamilly : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) EOCfamilly *spouse;

@end

NS_ASSUME_NONNULL_END
