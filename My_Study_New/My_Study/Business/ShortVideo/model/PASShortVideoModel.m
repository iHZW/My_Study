//
//  PASShortVideoModel.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/12/28.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "PASShortVideoModel.h"

@implementation PASShortVideoModel

@end

/**< 短视频链接详情 */
@implementation PASShortVideoDetailModel

@end

@implementation PASShortVideoDetailInfo

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"video_id":@"id"}];
}

@end
