//
//  UIDevice+Tool.m
//  My_Study
//
//  Created by Zhiwei Han on 2023/1/17.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "UIDevice+Tool.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "ZWSDK.h"

@implementation UIDevice (Tool)

- (BOOL)isIPhoneXSeries{
    BOOL iPhoneXSeries = NO;
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneXSeries = YES;
        }
    }
    return iPhoneXSeries;
}

+(NSString *)getCarrierName{
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];

    CTCarrier *ca = networkInfo.subscriberCellularProvider;
    NSString *carrierName =ca.carrierName;
    return __String_Not_Nil(carrierName);
}

+(NSString *)getCarrierMCCAndMNC{
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];

    CTCarrier *ca = networkInfo.subscriberCellularProvider;
    NSString *MCC =ca.mobileCountryCode;
    NSString *MNC =ca.mobileNetworkCode;
    
    NSString *mCCAndMNC = [MCC stringByAppendingString:MNC];
    return __String_Not_Nil(mCCAndMNC);
}


+(NSString *)getCarrierType{
    NSString *operator = [self getCarrierMCCAndMNC];
    if([operator isEqualToString: @"46000"] ||
       [operator isEqualToString: @"46002"] ||
       [operator isEqualToString: @"46007"] ||
       [operator isEqualToString: @"46020"]){  //移动
        return @"0";
    } else if([operator isEqualToString: @"46003"] ||
              [operator isEqualToString: @"46005"] ||
              [operator isEqualToString: @"46011"]){  //电信
        return @"1";
    }  else if([operator isEqualToString: @"46001"] ||
                 [operator isEqualToString: @"46006"] ||
                 [operator isEqualToString: @"46009"]){  //联通
        return @"2";
    }
    
    return @"";
}


//获取手机中sim卡数量（推荐）
+ (int)getSimCardNumInPhone {
     CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
     if (@available(iOS 12.0, *)) {
          NSDictionary *ctDict = networkInfo.serviceSubscriberCellularProviders;
          if ([ctDict allKeys].count > 1) {
               NSArray *keys = [ctDict allKeys];
               CTCarrier *carrier1 = [ctDict objectForKey:[keys firstObject]];
               CTCarrier *carrier2 = [ctDict objectForKey:[keys lastObject]];
               if (carrier1.mobileCountryCode.length && carrier2.mobileCountryCode.length) {
                    return 2;
               }else if (!carrier1.mobileCountryCode.length && !carrier2.mobileCountryCode.length) {
                    return 0;
               }else {
                    return 1;
               }
          }else if ([ctDict allKeys].count == 1) {
               NSArray *keys = [ctDict allKeys];
               CTCarrier *carrier1 = [ctDict objectForKey:[keys firstObject]];
               if (carrier1.mobileCountryCode.length) {
                    return 1;
               }else {
                    return 0;
               }
          }else {
               return 0;
          }
     }else {
          CTCarrier *carrier = [networkInfo subscriberCellularProvider];
          NSString *carrier_name = carrier.mobileCountryCode;
          if (carrier_name.length) {
               return 1;
          }else {
               return 0;
          }
     }
}

+ (BOOL)isAPPInstalled:(ThirdAppType)type{
    switch (type) {
        case ThirdAppTypeWechat:
            return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"wechat://"]];
            break;
        case ThirdAppTypeQQ:
            return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]];
            break;
        case ThirdAppTypeWechatWork:
            return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"wxwork://"]];
            break;
            
        default:
            break;
    }
    return YES;
}

@end
