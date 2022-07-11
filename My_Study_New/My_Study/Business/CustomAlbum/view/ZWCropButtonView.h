//
//  ZWCropButtonView.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWBaseView.h"

NS_ASSUME_NONNULL_BEGIN
// 裁剪页底部按钮视图
typedef void(^CropButtonClickBlock)(NSInteger);

@interface ZWCropButtonView : ZWBaseView

@property (nonatomic, copy) CropButtonClickBlock buttonHander;

@end

NS_ASSUME_NONNULL_END
