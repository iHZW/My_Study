//
//  PHAssetModel.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "PHAssetModel.h"

@implementation PHAssetModel

+ (PHAssetModel *)defaultItem
{
    PHAssetModel * model = [[PHAssetModel alloc]init];
    model.selStatus = 0;
    model.hasMask = NO;
    return model;
}

@end
