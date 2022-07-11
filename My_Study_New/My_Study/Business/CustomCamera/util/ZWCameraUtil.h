//
//  ZWCameraUtil.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMObject.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZWCameraUtil : CMObject

+ (AVAssetExportSession *)changeMp4:(NSURL *)url complete:(void(^)(NSURL * resultUrl))complete;

@end

NS_ASSUME_NONNULL_END
