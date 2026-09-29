//
//  MMShateItemCell.h
//  My_Study
//
//  Created by Zhiwei Han on 2023/2/8.
//  Copyright © 2023 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMShareItem.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kCellIdentifier_MMShareItemCell; // 循环利用的id

@interface MMShareItemCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *titleLable;

@property (nonatomic, strong) MMShareItem *shareItem;

@property (nonatomic) CGSize itemImageSize;        // item中image大小

@property (nonatomic) CGFloat itemImageTopSpace;   // item图片距离顶部大小

@property (nonatomic) CGFloat iconAndTitleSpace;   // item图片和文字距离

@property (nonatomic, assign) BOOL showBorderLine; // 是否显示边界线

@end

NS_ASSUME_NONNULL_END
