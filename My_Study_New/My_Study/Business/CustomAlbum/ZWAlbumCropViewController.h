//
//  ZWAlbumCropViewController.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWBaseViewController.h"

@class PHAssetModel;
NS_ASSUME_NONNULL_BEGIN

@interface ZWAlbumCropViewController : ZWBaseViewController

@property (nonatomic ,strong) PHAssetModel *data;

@end

NS_ASSUME_NONNULL_END