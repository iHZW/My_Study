//
//  ShareParam.h
//  My_Study
//
//  Created by Zhiwei Han on 2023/2/7.
//  Copyright © 2023 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShareParam : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *linkUrl;
// 分享的图片URL
@property (nonatomic, copy) NSString *imgUrl;
// 分享的图片
@property (nonatomic, strong) UIImage *img;

// 小程序原始id userName
@property (nonatomic, copy) NSString *miniProgramID;
// 小程序页面路径
@property (nonatomic, copy) NSString *miniProgramPath;
// 正式版:0，测试版:1，体验版:2  默认0
@property (nonatomic, copy) NSString *miniProgramType;
// 是否使用带 shareTicket 的分享 默认：false
@property (nonatomic, assign) BOOL withShareTicket;
@end

NS_ASSUME_NONNULL_END
