//
//  ZWAlbumDetailsViewController.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/12.
//  Copyright © 2022 HZW. All rights reserved.
//
/** 相册图片列表页面  */
#import "ZWBaseViewController.h"
#import "ZWAlbumManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWAlbumDetailsViewController : ZWBaseViewController

@property (nonatomic ,strong) PHAssetCollection * collection;

@end

NS_ASSUME_NONNULL_END
