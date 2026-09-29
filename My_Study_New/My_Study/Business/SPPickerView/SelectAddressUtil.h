//
//  SelectAddressUtil.h
//  CRM
//
//  Created by js on 2019/12/2.
//  Copyright © 2019 js. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPArea.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SelectAddressCompleteBlock)(SPArea *,SPArea *,SPArea *);
@interface SelectAddressUtil : NSObject
@property (nonatomic ,copy) NSString * pagename;
+ (instancetype)sharedInstance;

- (void)showInViewController:(UIViewController *)viewController
                    complete:(SelectAddressCompleteBlock)completeBlock;
- (void)autoFetchGPRSLocation:(SelectAddressCompleteBlock)completeBlock;
@end

NS_ASSUME_NONNULL_END
