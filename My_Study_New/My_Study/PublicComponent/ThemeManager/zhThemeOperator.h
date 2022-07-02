//
//  zhThemeOperator.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/1.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const AppThemeLight;
UIKIT_EXTERN NSString *const AppThemeNight;
UIKIT_EXTERN NSString *const AppThemeStyle1;
UIKIT_EXTERN NSString *const AppThemeStyle2;
UIKIT_EXTERN NSString *const AppThemeStyle3;


@interface zhThemeOperator : NSObject

+ (void)themeConfiguration;

+ (void)changeThemeDayOrNight;

+ (void)changeThemeStyleWithKey:(NSString *)styleKey;

@end

NS_ASSUME_NONNULL_END
