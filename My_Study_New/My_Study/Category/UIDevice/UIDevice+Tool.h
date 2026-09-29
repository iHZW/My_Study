//
//  UIDevice+Tool.h
//  My_Study
//
//  Created by Zhiwei Han on 2023/1/17.
//  Copyright © 2023 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,ThirdAppType) {
    ThirdAppTypeWechat,
    ThirdAppTypeQQ,
    ThirdAppTypeWechatWork
};


@interface UIDevice (Tool)

- (BOOL)isIPhoneXSeries;

//运营商名字
+(NSString *)getCarrierName;

//运营商编码
+(NSString *)getCarrierMCCAndMNC;

//(运营商)=0（移动）；1（电信）；2（联通）
+(NSString *)getCarrierType;

//获取手机中sim卡数量（推荐）
+ (int)getSimCardNumInPhone;

+ (BOOL)isAPPInstalled:(ThirdAppType)type;

@end

NS_ASSUME_NONNULL_END
