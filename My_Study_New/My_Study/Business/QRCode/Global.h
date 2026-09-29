//
//  Global.h
//  My_Study
//
//  Created by hzw on 2023/8/29.
//  Copyright © 2023 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LBXScan/LBXScanViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface Global : NSObject

////当前选择的扫码库
@property (nonatomic, assign) SCANLIBRARYTYPE libraryType;
////当前选择的识别码制
@property (nonatomic, assign) SCANCODETYPE scanCodeType;

@property (nonatomic, assign) BOOL continuous;

+ (instancetype)sharedManager;


//返回native选择的识别码的类型
- (NSString*)nativeCodeType;

- (NSString*)nativeCodeWithType:(SCANCODETYPE)type;

//返回SCANCODETYPE 类别数组
- (NSArray*)nativeTypes;

@end

NS_ASSUME_NONNULL_END
