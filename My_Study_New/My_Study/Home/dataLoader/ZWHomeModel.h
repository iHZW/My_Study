//
//  ZWHomeModel.h
//  My_Study
//
//  Created by hzw on 2022/9/23.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWHttpResponseData.h"

@class ZWHomeDataModel, ZWHomeItemInfo;

@protocol ZWHomeItemInfo;

NS_ASSUME_NONNULL_BEGIN

@interface ZWHomeModel : ZWHttpResponseData

@property (nonatomic, strong) ZWHomeDataModel *data;

@end


@interface ZWHomeDataModel : ZWHttpNetworkData

@property (nonatomic, assign) NSInteger errcode;

@property (nonatomic, assign) NSInteger pageSize;

@property (nonatomic, assign) NSInteger totalCount;

@property (nonatomic, assign) NSInteger totalPage;

@property (nonatomic, assign) NSInteger pageNum;

@property (nonatomic, assign) BOOL hasNext;

@property (nonatomic, copy) NSArray<ZWHomeItemInfo> *list;

@end


@interface ZWHomeItemInfo : ZWHttpNetworkData

@property (nonatomic, assign) NSInteger status;

@property (nonatomic, copy) NSString *initiatorName;

@property (nonatomic, copy) NSString *code;

@property (nonatomic, copy) NSString *statusName;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *createTime;

@end



NS_ASSUME_NONNULL_END
