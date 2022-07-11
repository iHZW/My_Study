//
//  PHAssetModel.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMObject.h"
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PHAssetModel : CMObject

@property (nonatomic ,strong) PHAsset * asset;

@property (nonatomic ,strong) UIImage * cropImage;

@property (nonatomic ,strong) UIImage * originalImage;

@property (nonatomic ,strong) NSString * thumPath;
/** 原始路径  */
@property (nonatomic ,strong) NSString * originalPath;
/** 媒体中心url  */
@property (nonatomic ,copy) NSString * mediaURL;
/** 判断是文件  */
@property (nonatomic, assign) BOOL isFile;
/** 文件名称,上传附件使用  */
@property (nonatomic, copy) NSString *fileName;
/** 真实的本地文件名  */
@property (nonatomic, copy) NSString *realFileName;

@property (nonatomic, assign) double fileSize;

@property (nonatomic, copy) NSString *fileUrl;
// UI逻辑
@property (nonatomic ,assign) BOOL hasMask;
// 选中状态 0未选中 1已选择
@property (nonatomic ,assign) NSInteger selStatus;

/** 默认item  */
+ (PHAssetModel *)defaultItem;

@end

NS_ASSUME_NONNULL_END
