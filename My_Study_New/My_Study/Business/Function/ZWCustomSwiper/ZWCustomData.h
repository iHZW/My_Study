//
//  ZWCustomData.h
//  My_Study
//
//  Created by hzw on 2025/1/23.
//  Copyright © 2025 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZWCustomData : NSObject

@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *subtitle;
@property(nonatomic, strong) UIImage *image;

- (instancetype)initWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
                        image:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
