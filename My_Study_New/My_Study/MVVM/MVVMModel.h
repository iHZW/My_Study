//
//  MVVMModel.h
//  My_Study
//
//  Created by HZW on 2021/9/6.
//  Copyright © 2021 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MVVMModel : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *imageName;

- (instancetype)initWithName:(NSString *)name imageName:(NSString *)imageName;

@end

NS_ASSUME_NONNULL_END
