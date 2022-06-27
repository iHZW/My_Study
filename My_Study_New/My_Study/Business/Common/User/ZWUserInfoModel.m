//
//  ZWUserInfoModel.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWUserInfoModel.h"
#import "NSObject+MJCoding.h"
#import "DataFormatter.h"

@implementation ZWUserInfoModel

MJExtensionCodingImplementation

- (instancetype)init
{
    if (self =[super init]) {
        self.accountMutArray = [NSMutableArray array];
    }
    return self;
}


+(NSArray *)mj_ignoredCodingPropertyNames
{
    return @[@"myCardList",@"mainCardItem", @"oldBankTransferModel",@"growthValue",@"haveShowOpenAccount"];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

// 是否是游客
- (BOOL)isVisitor{
    return NO;
}

@end
