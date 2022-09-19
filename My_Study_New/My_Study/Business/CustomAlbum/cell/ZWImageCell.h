//
//  ZWImageCell.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/12.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWBaseCollectionCell.h"
#import "ZWAlbumManager.h"

@class PHAssetModel;

NS_ASSUME_NONNULL_BEGIN


@protocol ZWImageCellDelegate <NSObject>

- (void)zwImageCellDidChangeStatus:(UIView *)cell data:(PHAssetModel *)data;

@end

@interface ZWImageCell : ZWBaseCollectionCell

@property (nonatomic ,strong) PHAssetModel * model;

@property (nonatomic ,strong) UIImageView * chooseIcon;

@property (nonatomic ,weak) id<ZWImageCellDelegate> delegate;


- (void)update:(PHAssetModel *)model
      selIndex:(NSInteger)selindex
  hasSelectMax:(BOOL)hasSelectMax;

@end

NS_ASSUME_NONNULL_END
