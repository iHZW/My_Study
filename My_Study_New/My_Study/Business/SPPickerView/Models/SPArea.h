//
//  SPProvince.h
//  SPPickerView
//
//  Created by develop1 on 2018/8/24.
//  Copyright © 2018年 Cookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPLocation;

@interface SPArea : NSObject
@property (nonatomic, strong) NSArray *children;
@property (nonatomic, copy) NSString *areaCode;
@property (nonatomic, copy) NSString *areaName;
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, assign) NSInteger levelType;
@property (nonatomic, copy) NSString *parentCode;
@end
