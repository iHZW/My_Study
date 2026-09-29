//
//  PASShortVideoModel.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/12/28.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWHttpResponseData.h"

@class PASShortVideoDetailInfo;

NS_ASSUME_NONNULL_BEGIN

@interface PASShortVideoModel : ZWHttpResponseData

@end


/**< 短视频链接详情 */
@interface PASShortVideoDetailModel : ZWHttpResponseData

@property (nonatomic, strong) PASShortVideoDetailInfo *data;

@end

@interface PASShortVideoDetailInfo : ZWHttpNetworkData

@property (nonatomic, copy) NSString *video_id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *dec;
@property (nonatomic, copy) NSString *imgUrl;
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *origin;

@end

NS_ASSUME_NONNULL_END
