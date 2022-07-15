//
//  ZWAlbumPreViewController.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/12.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
@class  PHAssetModel;

@protocol ZWAlbumPreViewControllerDelegate <NSObject>

- (void)imageDidSelect:(UIViewController *)vc selectArr:(NSArray <PHAssetModel *> *)selectArr;

- (void)isOriginalDidChange:(BOOL)isOriginal;

@end

@interface ZWAlbumPreViewController : ZWBaseViewController

@property (nonatomic ,assign) NSInteger index;

@property (nonatomic ,assign) BOOL isOriginal;

@property (nonatomic ,strong) NSMutableArray <PHAssetModel *> * imageList;

@property (nonatomic ,strong) NSMutableArray <PHAssetModel *> * selectArr;

@property (nonatomic ,weak) id<ZWAlbumPreViewControllerDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
