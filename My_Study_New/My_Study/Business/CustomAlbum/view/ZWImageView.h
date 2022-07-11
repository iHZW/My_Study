//
//  ZWImageView.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWBaseView.h"
#import "ZWAlbumManager.h"

NS_ASSUME_NONNULL_BEGIN

@class PHAssetModel;


typedef void(^TapActionBlock)(void);

typedef void(^LongTapActionBlock)(UIImage * image);


@interface ZWImageView : ZWBaseView

@property (nonatomic ,assign) CGFloat maxZoomScale;

@property (nonatomic ,copy) TapActionBlock tapAction;

@property (nonatomic ,copy) LongTapActionBlock longTapAction;

- (void)resetScale;

- (void)loadUrlAndPath:(NSString *)str;

- (void)update:(PHAsset *)asset;

- (void)updateModel:(PHAssetModel *)data;

@end

NS_ASSUME_NONNULL_END
