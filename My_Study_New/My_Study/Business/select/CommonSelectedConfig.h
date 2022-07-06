//
//  CommonSelectedConfig.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/5.
//  Copyright © 2022 HZW. All rights reserved.
//

#ifndef CommonSelectedConfig_h
#define CommonSelectedConfig_h

/** 1: 数组字典中必须包含  selectName 这个key 用来展示用的  2: 可以设置默认选中的名称   */
static NSString * _Nonnull const kSelectName = @"selectName";
/** 列表数组   数组中存储的是 NSDictionary  */
static NSString * _Nonnull const kDataList = @"dataList";
/** 是否加载 顶部的确定按钮   默认不加载  */
static NSString * _Nonnull const kIsLoadSureBtn = @"isLoadSureBtn";
/** 可以设置导航title  默认为 @"选择页"  */
static NSString * _Nonnull const kTitleName = @"titleName";



#endif /* CommonSelectedConfig_h */
