//
//  ZWAlbumCell.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/12.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWBaseTableViewCell.h"
#import "ZWAlbumManager.h"
//#import "UITableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWAlbumCell : UITableViewCell

- (void)update:(PHAssetCollection *)collection;

- (void)selectStatus;

- (void)unSelectStatus;

@end

NS_ASSUME_NONNULL_END
