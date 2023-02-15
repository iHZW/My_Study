//
//  PASShortVideoAgreeResponse.h
//  PASInfoLib
//
//  Created by 张勇勇(证券总部经纪业务事业部技术开发团队) on 2020/12/2.
//

#import "ZWHttpResponseData.h"

NS_ASSUME_NONNULL_BEGIN

@interface PASShortVideoAgreeModel : ZWHttpNetworkData

@property (nonatomic, copy) NSString *status;

@end

@interface PASShortVideoAgreeResponse : ZWHttpResponseData

@property (nonatomic, strong) PASShortVideoAgreeModel *results;

@end

NS_ASSUME_NONNULL_END