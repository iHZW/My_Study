//
//  UploadItem.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/12.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UploadItem : NSObject

@property (nonatomic ,copy) NSString * url;

@property (nonatomic ,copy) NSString * size;

@property (nonatomic ,copy) NSString * localPath;

//@property (nonatomic ,assign) UploadStatus status;

+ (UploadItem *)defaultItem;

@end

NS_ASSUME_NONNULL_END
