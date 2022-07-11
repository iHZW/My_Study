//
//  ZWCameraPreViewController.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class PHAssetModel;

typedef void(^ZWPreComplete) (NSArray <PHAssetModel *> *);

@interface ZWCameraPreViewController : ZWBaseViewController

@property (nonatomic ,copy) ZWPreComplete completeHander;

@property (nonatomic ,strong) PHAssetModel * data;

@end

NS_ASSUME_NONNULL_END
