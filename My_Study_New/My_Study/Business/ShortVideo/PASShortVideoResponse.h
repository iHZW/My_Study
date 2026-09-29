//
//  PASShortVideoResponse.h
//  PASInfoLib
//
//  Created by 张勇勇(证券总部经纪业务事业部技术开发团队) on 2020/11/24.
//

#import "ZWHttpResponseData.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PASShortVideoItemModel;

@interface PASShortVideoModelInfo : ZWHttpNetworkData

@property (nonatomic, assign) NSInteger count;

@end

@interface PASShortVideoItemModel : ZWHttpNetworkData

@property (nonatomic, copy) NSString *infoId;  //内容id
@property (nonatomic, copy) NSString *fromId;  //源id
@property (nonatomic, copy) NSString *sceneId;  //场景id
@property (nonatomic, copy) NSString *title;  //标题
@property (nonatomic, copy) NSString *desc;  //摘要
@property (nonatomic, copy) NSString *images;  //图片
@property (nonatomic, copy) NSString *detailLink;
@property (nonatomic, assign) NSInteger videoTime;  //视频时长(秒)
@property (nonatomic, strong) PASShortVideoModelInfo *commentInfo;   //评论
@property (nonatomic, strong) PASShortVideoModelInfo *shareInfo;     //分享
@property (nonatomic, strong) PASShortVideoModelInfo *praiseInfo;    //点赞

@property (nonatomic, assign) BOOL isAgree;
@end

@interface PASShortVideoResult : ZWHttpNetworkData

@property (nonatomic, assign) NSInteger pageSize;  //每页条数
@property (nonatomic, assign) NSInteger nt;   //下一页标识
@property (nonatomic, strong) NSArray<PASShortVideoItemModel> *list;

@end

@interface PASShortVideoResponse : ZWHttpResponseData

@property (nonatomic, strong) PASShortVideoResult *results;

@end

NS_ASSUME_NONNULL_END
