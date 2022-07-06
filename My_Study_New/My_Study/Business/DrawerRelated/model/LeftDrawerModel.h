//
//  LeftDrawerModel.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/22.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWHttpResponseData.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,ClientChatType){
    ChatTypeNone = 0,            //其他   自定义字段
    
    ChatTypeText = 1,            //文本
    ChatTypeImage = 2,           //图片
    ChatTypeRevoke = 3,          //撤回消息
    ChatTypeVoice = 4,           //语音
    ChatTypeVideo = 5,           //视频
    ChatTypeCard = 6,            //名片
    ChatTypeLocation = 7,        //位置
    ChatTypeEmotion = 8,         //表情
    ChatTypeFile = 9,            //文件
    ChatTypeLink = 10,           //链接
    ChatTypeWeapp = 11,          //小程序消息
    ChatTypeNews = 12,           //图文
    ChatTypeMarkdown = 13,       //MarkDown格式消息
    ChatTypeAgree = 14,          //同意消息
    ChatTypeDisagree = 15,       //不同意消息
    ChatTypeChatrecord = 16,     //会话记录消息
    ChatTypeRedpacket = 17,      //红包消息
    ChatTypeVote = 18,           //投票消息
    ChatTypeCollect = 19,        //填表消息
    ChatTypeMeeting = 20,        //会议邀请消息
    ChatTypeCalendar = 21,       //日程消息
    ChatTypeMeetingVoiceCall = 22,//音频存档消息
    ChatTypeVoipDocShare = 23,   //音频共享文档消息
    ChatTypeDocmsg = 24,         //在线文档消息
    ChatTypeExternalRedpacket = 25,//互通红包消息
    ChatTypeMixed = 26,          //混合消息
};

@class TextInfo,ImageInfo,VoiceInfo,VideoInfo,FileInfo,LinkInfo,WeappInfo,VideoInfo,ClientChatInfo, ClientChatDataModel;

@protocol ClientChatReccord, ChatMediaModel;

@interface ChatMediaModel : ZWHttpNetworkData
/// 视频/图片的链接地址
@property (nonatomic, copy) NSString *path;

@property (nonatomic, copy) NSString *sdkfileid;

@end



@interface ClientChatReccord : ZWHttpNetworkData

// common
@property (nonatomic ,copy) NSString * msgid;
@property (nonatomic ,copy) NSString * msgId;
@property (nonatomic ,assign) NSInteger seq;
@property (nonatomic ,copy) NSString * from;
@property (nonatomic ,copy) NSString * fromname;
@property (nonatomic ,copy) NSString * action;
@property (nonatomic ,copy) NSString * msgtype;
@property (nonatomic ,copy) NSString * msgtime;
@property (nonatomic ,copy) NSString * msgType;
@property (nonatomic ,copy) NSString * msgTime;

@property (nonatomic, assign) NSInteger fromType; // 查看方是否是接收方：0不是1是
@property (nonatomic, assign) NSInteger toType;
@property (nonatomic, copy) NSString *fromUserName;
@property (nonatomic, copy) NSString *toUserName;
@property (nonatomic, copy) NSString *fromUserAvatar; // 查看方头像
@property (nonatomic, copy) NSString *toUserAvatar;
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, assign) BOOL recall;
@property (nonatomic, copy) NSString *to; // 聊天对象用户id

@property (nonatomic, strong) ClientChatInfo *content;

//info
@property (nonatomic ,strong) TextInfo * text;
@property (nonatomic ,strong) ImageInfo * image;
@property (nonatomic ,strong) VoiceInfo * voice;
@property (nonatomic ,strong) VideoInfo * video;
@property (nonatomic ,strong) FileInfo * file;
@property (nonatomic ,strong) LinkInfo * link;
@property (nonatomic ,strong) WeappInfo * weapp;

@property (nonatomic, strong) NSArray<ChatMediaModel> *chatMediaList;

// 自定义字段  用于枚举类型区分  兼容后台字符串类型
@property (nonatomic ,assign) ClientChatType MessageType;

- (ClientChatType)MessageType;

@end


@interface ClientChatInfo : ZWHttpNetworkData

@property (nonatomic ,strong) TextInfo * text;
@property (nonatomic ,strong) ImageInfo * image;
@property (nonatomic ,strong) VoiceInfo * voice;
@property (nonatomic ,strong) VideoInfo * video;
@property (nonatomic ,strong) FileInfo * file;
@property (nonatomic ,strong) LinkInfo * link;
@property (nonatomic ,strong) WeappInfo * weapp;

@end


@interface TextInfo : ZWHttpNetworkData

@property (nonatomic ,copy) NSString * content;

@end

@interface ImageInfo : ZWHttpNetworkData

@property (nonatomic ,copy) NSString * url;
@property (nonatomic ,assign) NSInteger filesize;
@property (nonatomic ,assign) NSInteger fileSize;

@end

@interface VoiceInfo : ZWHttpNetworkData

@property (nonatomic ,copy) NSString * fileUrl;
@property (nonatomic ,copy) NSString * voice_size;
@property (nonatomic ,copy) NSString * voiceSize;
@property (nonatomic ,copy) NSString * play_length;
@property (nonatomic ,copy) NSString * playLength;

@end

@interface VideoInfo : ZWHttpNetworkData

@property (nonatomic ,copy) NSString * frameUrl;
@property (nonatomic ,copy) NSString * url;
@property (nonatomic ,assign) NSInteger playLength;
@property (nonatomic ,assign) NSInteger fileSize;

@end

@interface FileInfo : ZWHttpNetworkData

@property (nonatomic ,copy) NSString * filename;
@property (nonatomic ,copy) NSString * fileName;
@property (nonatomic ,assign) int filesize;
@property (nonatomic ,assign) int fileSize;
@property (nonatomic ,copy) NSString * fileext;
@property (nonatomic ,copy) NSString * fileExt;
@property (nonatomic ,copy) NSString * url;

@end

@interface LinkInfo : ZWHttpNetworkData
@property (nonatomic ,copy) NSString * title;
@property (nonatomic ,copy) NSString * image_url;
@property (nonatomic ,copy) NSString * imageUrl;
@property (nonatomic ,copy) NSString * kDescription;
@property (nonatomic ,copy) NSString * link_url;
@property (nonatomic ,copy) NSString * linkUrl;

@end

@interface WeappInfo : ZWHttpNetworkData

@property (nonatomic ,copy) NSString * displayname;
@property (nonatomic ,copy) NSString * displayName;
@property (nonatomic ,copy) NSString * kDescription;
@property (nonatomic ,copy) NSString * title;
@property (nonatomic ,copy) NSString * username;
@property (nonatomic ,copy) NSString * userName;

@end


/// 企微私域版模式信息
@interface ClientBindInfoModel : ZWHttpNetworkData
/// 0 默认版本  1 触客版  2 私域版
@property (nonatomic, assign) NSInteger wecomType;
/// 是否开通了自建版会话存档，0 未开通 1 已开通
@property (nonatomic, assign) NSInteger selfBuildChatRecordValid;
/// 套餐开始/结束时间
@property (nonatomic, copy) NSString *startDate;
@property (nonatomic, copy) NSString *endDate;
/// 企业微信id
@property (nonatomic, copy) NSString *thirdCorpId;

@end



@interface ClientChatDataModel : ZWHttpNetworkData

@property (nonatomic ,assign) NSInteger count;
@property (nonatomic ,strong) NSArray <ClientChatReccord> *rows;

@property (nonatomic, copy) NSString *scrollId; //使用scrollId查询时会返回，查下一页要带上这个参数
@property (nonatomic, assign) NSInteger total; //消息总数

@property (nonatomic ,strong) NSArray <ClientChatReccord> *chatDataInfoList;

@end



@interface LeftDrawerModel : ZWHttpResponseData

@property (nonatomic ,assign) BOOL hasLoadAll;

@property (nonatomic, strong) ClientChatDataModel *data;

@end


NS_ASSUME_NONNULL_END
