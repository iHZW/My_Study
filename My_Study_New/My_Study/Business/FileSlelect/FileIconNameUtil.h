//
//  FileIconNameUtil.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//
/** 获取文件icon名称  */
#import "CMObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface FileIconNameUtil : CMObject

/**
 *  根据url链接 转换为本地显示的文件图片名称
 *
 *  @param url   文件链接
 */
+ (NSString *)transFileIconUrl:(NSString *)url;

/**
 *  根据文件转换为本地显示的文件图片名称
 *
 *  @param iconName    文件名
 */
+ (NSString *)transFileIconName:(NSString *)iconName;



@end

NS_ASSUME_NONNULL_END
