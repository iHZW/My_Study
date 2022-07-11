//
//  FileItemCell.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "PASBorderTableViewCell.h"
#import "PHAssetModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^FileCloseActionBlock) (NSInteger index);

@interface FileItemCell : PASBorderTableViewCell

@property (nonatomic, copy) FileCloseActionBlock closeActoinBlock;

@property (nonatomic, assign) NSInteger index;

- (void)configItemModel:(PHAssetModel *)itemModel;

@end

NS_ASSUME_NONNULL_END
