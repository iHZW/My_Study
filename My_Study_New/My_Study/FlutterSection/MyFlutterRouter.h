//
//  MyFlutterRouter.h
//  My_Study
//
//  Created by HZW on 2019/8/10.
//  Copyright © 2019 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <flutter_boost/FlutterBoost.h>


NS_ASSUME_NONNULL_BEGIN

@interface MyFlutterRouter : NSObject <FLBPlatform>
    
@property(nonatomic, weak) FlutterViewController *fvc;

+ (instancetype)sharedRouter;
    
@end

NS_ASSUME_NONNULL_END
