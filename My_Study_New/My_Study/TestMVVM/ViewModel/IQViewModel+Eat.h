//
//  IQViewModel+Eat.h
//  My_Study
//
//  Created by HZW on 2021/8/11.
//  Copyright © 2021 HZW. All rights reserved.
//

#import "IQViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface IQViewModel (Eat)<NSCoding, NSCopying>

@property (nonatomic, strong) NSString *wf_name;

@property (nonatomic, assign) int wf_count;

- (void)eat:(NSString *)someting;

+ (void)play;


@end

NS_ASSUME_NONNULL_END
