//
//  ShareClient.m
//  My_Study
//
//  Created by Zhiwei Han on 2023/2/7.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "MMShareManager.h"
#import "ShareObject+Platform.h"
#import <MessageUI/MessageUI.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <WechatOpenSDK/WXApi.h>
#import <WechatOpenSDK/WXApiObject.h>
#import <WechatOpenSDK/WechatAuthSDK.h>
#import "LogUtil.h"

@interface MMShareManager () <QQApiInterfaceDelegate, MFMessageComposeViewControllerDelegate, WXApiDelegate>

@property (nonatomic, weak) id<ShareClientDelegte> delegate;

@property (nonatomic, copy) ShareCompleteBlock completeBlock;

@property (nonatomic, copy) WXLoginCompleteBlock wxLoginBlock;

@property (nonatomic, copy) ShareCompleteBlock openMiniAppCompleteBlock;

@end

@implementation MMShareManager

+ (instancetype)sharedInstance {
    static MMShareManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MMShareManager alloc] init];
    });
    return _instance;
}


#pragma mark - Register

+ (void)registerDelegate:(id<ShareClientDelegte>)delegate {
    [MMShareManager sharedInstance].delegate = delegate;
}

+ (void)registerWechat:(NSString *)appid universalLink:(NSString *)universalLink {
    [WXApi registerApp:appid universalLink:universalLink];
}

#pragma mark - Util
+ (BOOL)isWXAppInstalled {
    return [WXApi isWXAppInstalled];
}

+ (BOOL)isQQInstalled {
    return [QQApiInterface isQQInstalled];
}

#pragma mark -

+ (void)shareObject:(ShareObject *)shareObject
           complete:(ShareCompleteBlock)completeBlock {
    [MMShareManager sharedInstance].completeBlock = completeBlock;
    if (shareObject.isWechat || shareObject.isWechatMoments) {
        [[MMShareManager sharedInstance] shareWechat:shareObject];
    } else if (shareObject.isQQ) {
        [[MMShareManager sharedInstance] shareQQ:shareObject];
    } else if (shareObject.isMiniProgramApp) {
        [MMShareManager openMiniApp:shareObject complete:completeBlock];
    }
}

+ (BOOL)isSupportShare:(ShareObject *)shareObject {
    if (shareObject.isWechat || shareObject.isWechatMoments || shareObject.isMiniProgramApp) {
        return [WXApi isWXAppInstalled];
    } else if (shareObject.isQQ) {
        return [QQApiInterface isQQInstalled];
    }
    return YES;
}

#pragma mark - Wechat Share
- (void)shareWechat:(ShareObject *)shareObject {
    ShareParam *shareParam = shareObject.shareParam;

    enum WXScene scene = WXSceneSession;
    if (shareObject.isWechatMoments) {
        scene = WXSceneTimeline;
    }

    if (shareObject.isMiniProgram) {
        [self.delegate downloadImage:shareObject
                            complete:^(UIImage *image, NSError *error) {
                                if (error) {
                                    [LogUtil debug:[NSString stringWithFormat:@"下载图片失败:%@", [JSONUtil modelToJSONString:shareObject]] flag:@"分享" context:self];
                                    NSError *error2 = [NSError errorWithDomain:@"ShareClient" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"分享失败"}];
                                    BlockSafeRun(self.completeBlock, NO, error2);
                                } else {
                                    [LogUtil debug:[NSString stringWithFormat:@"下载图片成功:%@", [JSONUtil modelToJSONString:shareObject]] flag:@"分享" context:self];
                                    NSData *thumbImage          = [self.delegate compressImage:shareObject source:image type:CompressImageTypeMiniThumb];
                                    NSData *hdImage             = [self.delegate compressImage:shareObject source:image type:CompressImageTypeMiniProgramHD];
                                    WXMiniProgramObject *object = [WXMiniProgramObject object];
                                    object.webpageUrl           = shareParam.linkUrl;
                                    object.userName             = shareParam.miniProgramID;
                                    object.path                 = shareParam.miniProgramPath;
                                    object.hdImageData          = hdImage;
                                    object.withShareTicket      = shareParam.withShareTicket;
                                    object.miniProgramType      = [shareParam.miniProgramType integerValue];
                                    WXMediaMessage *message     = [WXMediaMessage message];
                                    message.title               = shareParam.title;
                                    message.description         = shareParam.desc;
                                    message.thumbData           = thumbImage; // 兼容旧版本节点的图片，小于32KB，新版本优先
                                                                    // 使用WXMiniProgramObject的hdImageData属性
                                    message.mediaObject     = object;
                                    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
                                    req.bText               = NO;
                                    req.message             = message;
                                    req.scene               = WXSceneSession; // 目前只支持会话
                                    [WXApi sendReq:req completion:^(BOOL success) {
                                        [self handleWechatSendResp:success];
                                    }];
                                }
                            }];
    } else if (shareObject.isText) {
        SendMessageToWXReq *sendMessageToWXReq = [[SendMessageToWXReq alloc] init];
        sendMessageToWXReq.text                = shareParam.desc;
        sendMessageToWXReq.bText               = YES;
        sendMessageToWXReq.scene               = scene;
        [WXApi sendReq:sendMessageToWXReq completion:^(BOOL success) {
            [self handleWechatSendResp:success];
        }];
    } else if (shareObject.isWeb) {
        [self.delegate downloadImage:shareObject
                            complete:^(UIImage *image, NSError *error) {
                                if (error) {
                                    [LogUtil debug:[NSString stringWithFormat:@"下载图片失败:%@", [JSONUtil modelToJSONString:shareObject]] flag:@"分享" context:self];
                                    NSError *error2 = [NSError errorWithDomain:@"ShareClient" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"分享失败"}];
                                    BlockSafeRun(self.completeBlock, NO, error2);
                                } else {
                                    [LogUtil debug:[NSString stringWithFormat:@"下载图片成功:%@", [JSONUtil modelToJSONString:shareObject]] flag:@"分享" context:self];
                                    NSData *thumbImage                     = [self.delegate compressImage:shareObject source:image type:CompressImageTypeThumb];
                                    SendMessageToWXReq *sendMessageToWXReq = [[SendMessageToWXReq alloc] init];
                                    WXMediaMessage *urlMessage             = [WXMediaMessage message];
                                    urlMessage.title                       = shareParam.title;
                                    urlMessage.description                 = shareParam.desc;
                                    urlMessage.thumbData                   = thumbImage;

                                    WXWebpageObject *webObj = [WXWebpageObject object];
                                    webObj.webpageUrl       = shareParam.linkUrl;
                                    urlMessage.mediaObject  = webObj;

                                    sendMessageToWXReq.message = urlMessage;
                                    sendMessageToWXReq.bText   = NO;
                                    sendMessageToWXReq.scene   = scene;
                                    [WXApi sendReq:sendMessageToWXReq completion:^(BOOL success) {
                                        [self handleWechatSendResp:success];
                                    }];
                                }
                            }];

    } else if (shareObject.isImage) {
        [self.delegate downloadImage:shareObject
                            complete:^(UIImage *image, NSError *error) {
                                if (error) {
                                    NSError *error2 = [NSError errorWithDomain:@"ShareClient" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"分享失败"}];
                                    BlockSafeRun(self.completeBlock, NO, error2);
                                } else {
                                    NSData *thumbImageData  = [self.delegate compressImage:shareObject source:image type:CompressImageTypeThumb];
                                    NSData *bigImage        = [self.delegate compressImage:shareObject source:image type:CompressImageTypeBig];
                                    WXMediaMessage *message = [WXMediaMessage message];
                                    UIImage *thumbImage     = [UIImage imageWithData:thumbImageData];
                                    [message setThumbImage:thumbImage];

                                    WXImageObject *imageObject = [WXImageObject object];
                                    imageObject.imageData      = bigImage;

                                    SendMessageToWXReq *sendMessageToWXReq = [[SendMessageToWXReq alloc] init];
                                    message.mediaObject                    = imageObject;
                                    sendMessageToWXReq.message             = message;
                                    sendMessageToWXReq.bText               = NO;
                                    sendMessageToWXReq.scene               = scene;
                                    [WXApi sendReq:sendMessageToWXReq completion:^(BOOL success) {
                                        [self handleWechatSendResp:success];
                                    }];
                                }
                            }];

    } else if (shareObject.isSMS) {
        [self shareSMS:shareObject];
    }
}

- (void)handleWechatSendResp:(BOOL)isSuccess {
    [LogUtil debug:[NSString stringWithFormat:@"WXApi sendReq 返回:%d", isSuccess] flag:@"分享" context:self];
    if (isSuccess) {
        BlockSafeRun(self.completeBlock, YES, nil);
    } else {
        NSError *error = [NSError errorWithDomain:@"ShareClient" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"分享失败"}];
        BlockSafeRun(self.completeBlock, NO, error);
    }
}

#pragma mark - Wechat Login

+ (void)wxLogin:(WXLoginCompleteBlock)completeBlock {
    [[MMShareManager sharedInstance] simpleWxLoginWithBlock:completeBlock];
}

- (void)simpleWxLoginWithBlock:(WXLoginCompleteBlock)block {
    self.wxLoginBlock = block;
    SendAuthReq *req  = [[SendAuthReq alloc] init];
    req.scope         = @"snsapi_userinfo";
    req.state         = @"233";
    [WXApi sendReq:req completion:^(BOOL success) {
        [self handleWechatLoginResp:success];
    }];
}

- (void)handleWechatLoginResp:(BOOL)isSuccess {
    if (!isSuccess) {
        NSError *error = [NSError errorWithDomain:@"WXLogin" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"登录失败"}];
        BlockSafeRun(self.wxLoginBlock, nil, error);
    }
}

#pragma mark - MiniApp
+ (void)openMiniApp:(ShareObject *)shareObject
           complete:(ShareCompleteBlock)completeBlock {
    [MMShareManager sharedInstance].openMiniAppCompleteBlock = completeBlock;
    ShareParam *shareParam                                = shareObject.shareParam;
    WXLaunchMiniProgramReq *launchMiniProgramReq          = [WXLaunchMiniProgramReq object];
    launchMiniProgramReq.userName                         = shareParam.miniProgramID;                  // 拉起的小程序的username
    launchMiniProgramReq.path                             = shareParam.miniProgramPath;                ////拉起小程序页面的可带参路径，不填默认拉起小程序首页，对于小游戏，可以只传入 query 部分，来实现传参效果，如：传入 "?foo=bar"。
    launchMiniProgramReq.miniProgramType                  = [shareParam.miniProgramType integerValue]; // 拉起小程序的类型
    [WXApi sendReq:launchMiniProgramReq completion:^(BOOL success) {
        [[MMShareManager sharedInstance] handleOpenMiniAppResp:success];
    }];
}

- (void)handleOpenMiniAppResp:(BOOL)isSuccess {
    if (!isSuccess) {
        NSError *error = [NSError errorWithDomain:@"MiniApp" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"打开失败"}];
        BlockSafeRun(self.openMiniAppCompleteBlock, NO, error);
    }
}

#pragma mark - QQ

- (void)shareQQ:(ShareObject *)shareObject {
    ShareParam *shareParam = shareObject.shareParam;
    if (shareObject.isText) {
        QQApiTextObject *txtObj = [QQApiTextObject objectWithText:shareParam.desc];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txtObj];
        // 将内容分享到qq
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        [self handleQQSendResultCode:sent];
        // TODO:返回处理
    } else if (shareObject.isImage) {
        [self.delegate downloadImage:shareObject
                            complete:^(UIImage *image, NSError *error) {
                                if (error) {
                                } else {
                                    NSData *imgData = [self.delegate compressImage:shareObject source:image type:CompressImageTypeBig];

                                    QQApiImageObject *imgObj = [QQApiImageObject objectWithData:imgData previewImageData:imgData title:shareParam.title description:shareParam.desc];
                                    SendMessageToQQReq *req  = [SendMessageToQQReq reqWithContent:imgObj];
                                    // 将内容分享到qq
                                    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
                                    [self handleQQSendResultCode:sent];
                                }
                            }];
    } else if (shareObject.isWeb) {
        NSString *utf8String      = shareParam.linkUrl;
        NSString *title           = shareParam.title;
        NSString *description     = shareParam.desc;
        NSString *previewImageUrl = shareParam.imgUrl;
        QQApiNewsObject *newsObj  = [QQApiNewsObject
              objectWithURL:[NSURL URLWithString:utf8String]
                      title:title
                description:description
            previewImageURL:[NSURL URLWithString:previewImageUrl]];
        SendMessageToQQReq *req   = [SendMessageToQQReq reqWithContent:newsObj];
        // 将内容分享到qq
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        [self handleQQSendResultCode:sent];
    }
}

- (void)handleQQSendResultCode:(QQApiSendResultCode)resultCode {
    if (EQQAPISENDSUCESS != resultCode) {
        NSError *error = [NSError errorWithDomain:@"ShareClient" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"分享失败"}];
        BlockSafeRun(self.completeBlock, NO, error);
    } else {
        BlockSafeRun(self.completeBlock, YES, nil);
    }
}

#pragma mark - Response

- (void)onResp:(id)resp {
    if ([resp isKindOfClass:[QQBaseResp class]]) {
        // QQ
    } else if ([resp isKindOfClass:[BaseResp class]]) {
        // 微信
        if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        } else if ([resp isKindOfClass:[SendAuthResp class]]) {
            SendAuthResp *aresp = (SendAuthResp *)resp;
            if (aresp.errCode == 0) {
                BlockSafeRun(self.wxLoginBlock, aresp.code, nil);
            } else {
                NSError *error = [NSError errorWithDomain:@"WXLogin" code:aresp.errCode userInfo:nil];
                BlockSafeRun(self.wxLoginBlock, nil, error);
            }
        } else if ([resp isKindOfClass:[PayResp class]]) {
            NSDictionary *param = [JSONUtil modelToJSONObject:resp];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WX_PAY_COMPLETE" object:nil userInfo:param];
        } else if ([resp isKindOfClass:[WXLaunchMiniProgramResp class]]) {
            NSString *extMsg = [(WXLaunchMiniProgramResp *)resp extMsg];
            // 对应JsApi navigateBackApplication中的extraData字段数据
            if (self.delegate && [self.delegate respondsToSelector:@selector(handleMiniProgramExtMsg:extMsg:)]) {
                [self.delegate handleMiniProgramExtMsg:self extMsg:extMsg];
            }
            BlockSafeRun(self.openMiniAppCompleteBlock, YES, nil);
        }
    }
}

- (void)isOnlineResponse:(NSDictionary *)response {
    // QQAPIDelegate
}

- (void)onReq:(QQBaseReq *)req {
    // QQAPIDelegate
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    BOOL isHandled = [WXApi handleOpenURL:url delegate:[MMShareManager sharedInstance]];
    if (!isHandled) {
        isHandled = [QQApiInterface handleOpenURL:url delegate:[MMShareManager sharedInstance]];
    }
    return isHandled;
}

#pragma mark - SMS

- (void)shareSMS:(ShareObject *)shareObject {
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        // controller.recipients = @[@"10086"];//发送短信的号码，数组形式入参
        // controller.navigationBar.tintColor = [UIColor redColor];
        controller.body                   = shareObject.shareParam.desc; // 此处的body就是短信将要发生的内容
        controller.messageComposeDelegate = self;

        [[self.delegate topOfRootViewController] presentViewController:controller animated:YES completion:nil];
        //[[[[controller viewControllers] lastObject] navigationItem] setTitle:@"title"];//修改短信界面标题
    } else {
        NSError *error = [NSError errorWithDomain:@"ShareClient" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"该设备不支持短信功能"}];
        BlockSafeRun(self.completeBlock, NO, error);
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [[self.delegate topOfRootViewController] dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MessageComposeResultSent:
            // 信息传送成功
            {
                BlockSafeRun(self.completeBlock, YES, nil);
            }
            break;
        case MessageComposeResultFailed: {
            NSError *error = [NSError errorWithDomain:@"ShareClient" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"短信发送失败"}];
            BlockSafeRun(self.completeBlock, NO, error);
        }
        // 信息传送失败
        break;
        case MessageComposeResultCancelled:
            // 信息被用户取消传送
            {
                NSError *error = [NSError errorWithDomain:@"ShareClient" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"短信取消失败"}];
                BlockSafeRun(self.completeBlock, NO, error);
            }
            break;
        default:
            break;
    }
}


@end
