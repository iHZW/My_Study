//
//  PhotoActionSheetUtil.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMObject.h"
#import "ZWAlbumManager.h"
#import "ZWCameraManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotoActionSheetUtil : CMObject

+ (void)showPhotoAlert:(void(^)(NSArray<PHAssetModel *>*))complete;

+ (void)showPhotoAlert:(NSInteger)maxCount
              complete:(void(^)(NSArray<PHAssetModel *>*))complete
            isShowFile:(BOOL)isShowFile;

@end

NS_ASSUME_NONNULL_END
