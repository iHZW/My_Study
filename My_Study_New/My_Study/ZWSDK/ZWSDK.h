//
//  ZWSDK.h
//  My_Study
//
//  Created by HZW on 2019/6/4.
//  Copyright © 2019 HZW. All rights reserved.
//

#ifndef ZWSDK_h
#define ZWSDK_h

#import "UIScreen+Suitable.h"

/**
 *  强弱引用转换，用于解决代码块（block）与强引用self之间的循环引用问题
 *  调用方式: `@weakify_self`实现弱引用转换，`@strongify_self`实现强引用转换
 *
 *  示例：
 *  @pas_weakify_self
 *  [obj block:^{
 *  @pas_strongify_self
 *      self.property = something;
 *  }];
 */
#ifndef    pas_weakify_self
#if __has_feature(objc_arc)
#define pas_weakify_self autoreleasepool{} __weak __typeof__(self) weakSelf = self;
#else
#define pas_weakify_self autoreleasepool{} __block __typeof__(self) blockSelf = self;
#endif
#endif
#ifndef    pas_strongify_self
#if __has_feature(objc_arc)
#define pas_strongify_self try{} @finally{} __typeof__(weakSelf) self = weakSelf;
#else
#define pas_strongify_self try{} @finally{} __typeof__(blockSelf) self = blockSelf;
#endif
#endif

/**
 *  强弱引用转换，用于解决代码块（block）与强引用对象之间的循环引用问题
 *  调用方式: `@weakify(object)`实现弱引用转换，`@strongify(object)`实现强引用转换
 *
 *  示例：
 *  @pas_weakify(object)
 *  [obj block:^{
 *      @pas_strongify(object)
 *      strong_object = something;
 *  }];
 */
#ifndef    pas_weakify
#if __has_feature(objc_arc)
#define pas_weakify(object)    autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define pas_weakify(object)    autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#endif
#ifndef    pas_strongify
#if __has_feature(objc_arc)
#define pas_strongify(object) try{} @finally{} __typeof__(object) strong##_##object = weak##_##object;
#else
#define pas_strongify(object) try{} @finally{} __typeof__(object) strong##_##object = block##_##object;
#endif
#endif


#ifndef __INT64
#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32
typedef unsigned long _uint64;
typedef long long _int64;
#else
typedef unsigned long long _uint64;
typedef long long _int64;
#endif
#endif


/**
 常用宏定义
 */
#define kNumberFontName     @"ArialMT"         //数字字体名称
#define kNumberBFontName     @"Arial-BoldMT"   //数字加粗字体名称
#define PASFactor(x) [UIScreen finalScreenValue:x]
#define PASSuitableFactor(x) [UIScreen suitableScreenValue:x]
#define PASFont(s) [UIFont systemFontOfSize:s]
#define PASBFont(s) [UIFont boldSystemFontOfSize:s]
#define PASFontWithName(name, s) [UIFont fontWithName:name size:s]
#define PASFacFont(s) PASFont(PASFactor(s))   //适配后的字体
#define PASFacBFont(s) PASBFont(PASFactor(s)) //适配后的加粗字体

/* block */
#define BlockSafeRun(block, ...) block ? block(__VA_ARGS__) : nil
//字符串转换为非空
#define __String_Not_Nil(str) (str?:@"")

#define kMainScreenSize     ([[UIScreen mainScreen] bounds].size)
#define kMainScreenBounds  [UIScreen mainScreen].bounds
#define kMainScreenWidth    MIN([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)
#define kMainScreenHeight   MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width)
#define kCustomKeyBoardHeight (IS_IPHONE_X ?(244+30+kPORTRAIT_SAFE_AREA_BOTTOM_SPACE):(IS_IPHONE_5?(244*0.9):244+30))     // 大智慧自定义键盘高度
#define kMainTabbarHeight           49
#define kMainNavHeight              44   // 系统导航栏高度
#define kSysStatusBarHeight        MIN([UIApplication sharedApplication].statusBarFrame.size.width, [UIApplication sharedApplication].statusBarFrame.size.height)        // 系统状态栏高度
#define kMainContentFrame CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight- (kSysStatusBarHeight + kMainNavHeight))
#define kMainCenterContentFrame CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight- (kSysStatusBarHeight + kMainNavHeight + kMainTabbarHeight))
#define SegmentBarHeight        PASFactor(40)   // Segment高度


//IPhone5适配项
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double )568) < DBL_EPSILON )
//IPhone4适配项
#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double )480) < DBL_EPSILON )
//IPhone6适配项
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double )667) < DBL_EPSILON )
// IPhone6P适配项
#define IS_IPHONE_6P (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double )736) < DBL_EPSILON )
// IPhoneX适配项
// 6.14 解决:个股详情页多次屏幕旋转布局错乱问题; 取高和宽的最大值-保证拿到的是真实高度
#define IS_IPHONE_X (fabs((double)MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width) - (double )812) < DBL_EPSILON )

//判断iPhoneX系列
#define iPhoneX_Series ( MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width) > 811.9 && !isPad )

// 判断iPhone iPad
#define isPad       (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define isPhone     (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define kAppWindow  [[[UIApplication sharedApplication] delegate] window]


/**
 *  系统版本比较
 *
 *  @param v 当前版本号
 *
 *  @return 返回当前版本是否大于、等于或小于系统SDK版本
 */
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4_OR_LESS (IS_IPHONE && kMainScreenWidth < 568.0)
#define IS_IPHONE_6_OR_ABOVE AppContext.predictDeviceType >= Device_Type_6
#define IS_IPHONE_6P_OR_ABOVE AppContext.predictDeviceType >= Device_Type_6P


// 状态栏+导航栏高度
#define SafeAreaTopStatusNavBarHeight   ( kSysStatusBarHeight + kMainNavHeight )
// 底部安全区域高度
#define SafeAreaBottomAreaHeight        ( iPhoneX_Series ? 34 : 0 )

// IPhoneX 竖屏安全区域顶部空白
#define kPORTRAIT_SAFE_AREA_TOP_SPACE  (iPhoneX_Series?44:0)
// IPhoneX 竖屏安全区域底部空白
#define kPORTRAIT_SAFE_AREA_BOTTOM_SPACE (iPhoneX_Series?34:0)
// IPhoneX 横屏安全区域左部空白
#define kLANDSCAPE_SAFE_AREA_LEFT_SPACE (iPhoneX_Series?44:0)
// IPhoneX 横屏安全区域右部空白
#define kLANDSCAPE_SAFE_AREA_RIGHT_SPACE (iPhoneX_Series?44:0)
// IPhoneX 横屏安全区域底部空白
#define kLANDSCAPE_SAFE_AREA_BOTTOM_SPACE (iPhoneX_Series?21:0)

#define KLeftNavbarSpace    8

/* 通用的左边距 16 */
#define kCommonLeftSpace    16

#ifndef dimof
#define dimof(a)    (sizeof(a) / sizeof(a[0]))
#endif

/**
 *  布点适配宏
 */
#define __PASBI

#endif /* ZWSDK_h */
