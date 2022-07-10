//
//  LocationAuthority.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/6.
//  Copyright © 2022 HZW. All rights reserved.
//
/**
 判断应用定位是否开启
 */
#import "CMObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface LocationAuthority : CMObject

+ (BOOL)determineWhetherTheAPPOpensTheLocation;

+ (void)showActionView;


+ (void)showActionViewWithNoPop;


@end

NS_ASSUME_NONNULL_END
