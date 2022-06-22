//
//  LeftDrawerModel.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/22.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "LeftDrawerModel.h"

@implementation LeftDrawerModel

@end

@implementation ClientChatDataModel

- (void)setTotal:(NSInteger)total
{
    _total = total;
    self.count = total;
}

- (void)setChatDataInfoList:(NSArray<ClientChatReccord> *)chatDataInfoList
{
    _chatDataInfoList = chatDataInfoList;
    self.rows = chatDataInfoList;
}

@end


@implementation ClientChatReccord

+(JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"kDescription":@"description"}];
}

//+ (JSONKeyMapper *)keyMapper
//{
//    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
//                                                                  @"nodeList":@"data.nodeList"
//                                                                  }];
//}

//
//+ (NSDictionary *)mj_replacedKeyFromPropertyName{
//    return @{@"kDescription": @"description",
//    };
//}

- (void)setMsgId:(NSString *)msgId
{
    _msgId = msgId;
    self.msgid = msgId;
}

- (void)setFromUserName:(NSString *)fromUserName
{
    _fromUserName = fromUserName;
    self.fromname = fromUserName;
}

- (void)setMsgType:(NSString *)msgType
{
    _msgType = msgType;
    self.msgtype = msgType;
}

- (void)setMsgTime:(NSString *)msgTime
{
    _msgTime = msgTime;
    self.msgtime = msgTime;
}

- (void)setContent:(ClientChatInfo *)content
{
    _content = content;
    self.text = content.text;
    self.image = content.image;
    self.voice = content.voice;
    self.video = content.video;
    self.file = content.file;
    self.link = content.link;
    self.weapp = content.weapp;
}

- (void)setChatMediaList:(NSArray<ChatMediaModel *> *)chatMediaList
{
    _chatMediaList = chatMediaList;
    self.video.url = [chatMediaList firstObject].path;
    self.image.url = [chatMediaList firstObject].path;
    self.file.url = [chatMediaList firstObject].path;
    self.voice.fileUrl = [chatMediaList firstObject].path;
}

- (ClientChatType)MessageType{
    if ([self.msgtype isEqualToString:@"text"]) {
        return 1;
    }else if ([self.msgtype isEqualToString:@"image"]){
        return 2;
    }else if ([self.msgtype isEqualToString:@"revoke"]){
        return 3;
    }else if ([self.msgtype isEqualToString:@"voice"]){
        return 4;
    }else if ([self.msgtype isEqualToString:@"video"]){
        return 5;
    }else if ([self.msgtype isEqualToString:@"card"]){
        return 6;
    }else if ([self.msgtype isEqualToString:@"location"]){
        return 7;
    }else if ([self.msgtype isEqualToString:@"emotion"]){
        return 8;
    }else if ([self.msgtype isEqualToString:@"file"]){
        return 9;
    }else if ([self.msgtype isEqualToString:@"link"]){
        return 10;
    }else if ([self.msgtype isEqualToString:@"weapp"]){
        return 11;
    }else if ([self.msgtype isEqualToString:@"news"]){
        return 12;
    }else if ([self.msgtype isEqualToString:@"markdown"]){
        return 13;
    }else if ([self.msgtype isEqualToString:@"agree"]){
        return 14;
    }else if ([self.msgtype isEqualToString:@"disagree"]){
        return 15;
    }else if ([self.msgtype isEqualToString:@"chatrecord"]){
        return 16;
    }else if ([self.msgtype isEqualToString:@"redpacket"]){
        return 17;
    }else if ([self.msgtype isEqualToString:@"vote"]){
        return 18;
    }else if ([self.msgtype isEqualToString:@"collect"]){
        return 19;
    }else if ([self.msgtype isEqualToString:@"meeting"]){
        return 20;
    }else if ([self.msgtype isEqualToString:@"calendar"]){
        return 21;
    }else if ([self.msgtype isEqualToString:@"meeting_voice_call"]){
        return 22;
    }else if ([self.msgtype isEqualToString:@"voip_doc_share"]){
        return 23;
    }else if ([self.msgtype isEqualToString:@"docmsg"]){
        return 24;
    }else if ([self.msgtype isEqualToString:@"external_redpacket"]){
        return 25;
    }else if ([self.msgtype isEqualToString:@"mixed"]){
        return 26;
    }
    return 0;
}

//+ (NSDictionary *)mj_objectClassInArray{
//    return @{
//        @"text" : @"TextInfo",
//        @"image" : @"ImageInfo",
//        @"voice" : @"VoiceInfo",
//        @"video" : @"VideoInfo",
//        @"file" : @"FileInfo",
//        @"link" : @"LinkInfo",
//        @"weapp" : @"WeappInfo",
//        @"content" : @"ClientChatInfo",
//        @"chatMediaList" : @"ChatMediaModel",
//    };
//}

@end


@implementation ClientChatInfo

//+ (NSDictionary *)mj_objectClassInArray{
//    return @{
//        @"text" : @"TextInfo",
//        @"image" : @"ImageInfo",
//        @"voice" : @"VoiceInfo",
//        @"video" : @"VideoInfo",
//        @"file" : @"FileInfo",
//        @"link" : @"LinkInfo",
//        @"weapp" : @"WeappInfo",
//    };
//}

@end


@implementation ChatMediaModel


@end

@implementation TextInfo

@end

@implementation ImageInfo

- (void)setFileSize:(NSInteger)fileSize
{
    _fileSize = fileSize;
    _filesize = fileSize;
}

@end

@implementation VoiceInfo

- (void)setVoiceSize:(NSString *)voiceSize
{
    _voiceSize = voiceSize;
    _voice_size = voiceSize;
}

- (void)setPlayLength:(NSString *)playLength
{
    _playLength = playLength;
    _play_length = playLength;
}

@end

@implementation VideoInfo

@end

@implementation FileInfo

- (void)setFileName:(NSString *)fileName
{
    _fileName = fileName;
    _filename = fileName;
}

- (void)setFileExt:(NSString *)fileExt
{
    _fileExt = fileExt;
    _fileext = fileExt;
}

- (void)setFileSize:(int)fileSize
{
    _fileSize = fileSize;
    _filesize = fileSize;
}

@end
@implementation LinkInfo

//+ (NSDictionary *)mj_replacedKeyFromPropertyName{
//    return @{@"kDescription":@"description"};
//}

+(JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"kDescription":@"description"}];
}

- (void)setImageUrl:(NSString *)imageUrl
{
    _imageUrl = imageUrl;
    self.image_url = imageUrl;
}

- (void)setLinkUrl:(NSString *)linkUrl
{
    _linkUrl = linkUrl;
    self.link_url = linkUrl;
}

@end
@implementation WeappInfo

+(JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"kDescription":@"description"}];
}

- (void)setDisplayName:(NSString *)displayName
{
    _displayName = displayName;
    _displayname = displayName;
}

- (void)setUserName:(NSString *)userName
{
    _userName = userName;
    _username = userName;
}

@end


@implementation ClientBindInfoModel


@end
