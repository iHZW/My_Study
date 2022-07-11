//
//  FileSelectManager.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMObject.h"
#import "PHAssetModel.h"

NS_ASSUME_NONNULL_BEGIN

/** 选择完成回调  */
typedef void (^SelectFileComple) (NSArray<PHAssetModel *> *modelArr);

@interface FileSelectManager : CMObject
DEFINE_SINGLETON_T_FOR_HEADER(FileSelectManager)

@property (nonatomic ,copy ,readonly) NSString *fileRootPath;

@property (nonatomic, copy) SelectFileComple selectFileComplete;

/**
 *  打开文件选择控制器
 */
- (void)openFileSelectVc;

@end

NS_ASSUME_NONNULL_END
