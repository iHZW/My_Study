//
//  ZWPreCell.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/12.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWBaseCollectionCell.h"
#import "ZWImageView.h"
#import "UploadItem.h"

@class PHAssetModel;
NS_ASSUME_NONNULL_BEGIN

@interface ZWPreCell : ZWBaseCollectionCell

@property (nonatomic ,strong) ZWImageView * imageView;

- (void)update:(PHAssetModel *)model;

- (void)updateItem:(UploadItem *)item;

@end

NS_ASSUME_NONNULL_END
