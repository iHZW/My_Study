//
//  EHAddressCompHelper.h
//  My_Study
//
//  Created by hzw on 2022/11/18.
//  Copyright © 2022 HZW. All rights reserved.
//

/** 城市选择器  */
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EHAddressCompHelperDelegate <NSObject>

- (void)areaViewEndChange:(NSString *)text areaCode:(NSString *)areaCode;

@end

@interface EHAddressCompHelper : NSObject

@property (nonatomic, weak) id<EHAddressCompHelperDelegate> delegate;

- (void)showAddressView;

@end

NS_ASSUME_NONNULL_END
