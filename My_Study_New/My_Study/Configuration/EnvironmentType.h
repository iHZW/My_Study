//
//  EnvironmentType.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/5.
//  Copyright © 2022 HZW. All rights reserved.
//

#ifndef EnvironmentType_h
#define EnvironmentType_h

/** 环境类型  */
typedef NS_ENUM(NSUInteger,EnvironmentType) {
    EnvironmentTypeDev = 0,
    EnvironmentTypeQA,
    EnvironmentTypePL,
    EnvironmentTypeOnline,
    EnvironmentTypeNotFound = NSNotFound
};



#endif /* EnvironmentType_h */
