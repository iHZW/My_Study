//
//  ZWAlbumPopView.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/12.
//  Copyright © 2022 HZW. All rights reserved.
//
/** 相册列表弹窗  */
#import "ZWBaseView.h"
#import "ZWAlbumManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZWAlbumPopViewDelegate <NSObject>

- (void)popViewSelect:(PHAssetCollection *)collection;

- (void)popViewDidDismiss;

@end

@interface ZWAlbumPopView : ZWBaseView

@property (nonatomic, weak) id <ZWAlbumPopViewDelegate> delegate;

- (void)showAnimation;

- (void)dismissAnimation;

@end

NS_ASSUME_NONNULL_END
