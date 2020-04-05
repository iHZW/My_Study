//
//  EOCfamilly.h
//  My_Study
//
//  Created by HZW on 2019/5/22.
//  Copyright © 2019 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EOCfamilly : UIViewController

@property (nonatomic, strong) EOCfamilly *spouse;

@property (nonatomic, strong) NSMutableArray *famillyArray;

@property (nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
