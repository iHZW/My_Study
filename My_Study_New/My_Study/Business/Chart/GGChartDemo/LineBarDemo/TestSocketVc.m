//
//  TestSocketVc.m
//  My_Study
//
//  Created by hzw on 2023/9/9.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "TestSocketVc.h"
#import <SDWebImage/SDWeakProxy.h>
#import <SocketRocket/SocketRocket.h>

static NSString *const server_ip = @"ws://";

@interface TestSocketVc () <SRWebSocketDelegate>

@property(strong, nonatomic) SRWebSocket *socket;
@property(strong, nonatomic) NSTimer *heatBeat;
@property(assign, nonatomic) NSTimeInterval reConnectTime;

@end

@implementation TestSocketVc

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initWebSocket];
}

// 初始化 WebSocket
- (void)initWebSocket {
    if (_socket) {
        return;
    }
    // Url
    NSURL *url = [NSURL URLWithString:server_ip];
    // 请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    // 初始化请求`
    _socket = [[SRWebSocket alloc] initWithURLRequest:request];
    // 代理协议`
    _socket.delegate = self;
    // 实现这个 SRWebSocketDelegate 协议啊`
    // 直接连接`
    [_socket open]; // open 就是直接连接了
}

#pragma mark - 保活机制  探测包
- (void)initHeart {
    __weak typeof(self) weakSelf = self;
    if (@available(iOS 10.0, *)) {
        _heatBeat = [NSTimer scheduledTimerWithTimeInterval:3 * 60 repeats:YES block:^(NSTimer *_Nonnull timer) {
            NSError *error;
            [weakSelf.socket sendString:@"heart" error:&error];
            NSLog(@"已发送");
        }];
    } else {
        _heatBeat = [NSTimer scheduledTimerWithTimeInterval:3 * 60 target:[SDWeakProxy proxyWithTarget:self] selector:@selector(handleHeatBeat:) userInfo:nil repeats:YES];
    }
    [[NSRunLoop currentRunLoop] addTimer:_heatBeat forMode:NSRunLoopCommonModes];
}

#pragma mark - 处理心跳
- (void)handleHeatBeat:(NSTimer *)sender {
    NSError *error;
    [self.socket sendString:@"heart" error:&error];
    NSLog(@"已发送--error:%@", error);
}

#pragma mark - 断开连接时销毁心跳
- (void)destoryHeart {
    
}

#pragma mark - 重连机制
- (void)reConnect {
    // 每隔一段时间重连一次
    // 规定64不在重连,2的指数级
    if (_reConnectTime > 60) {
        return;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_reConnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.socket = nil;
        [self initWebSocket];
    });

    if (_reConnectTime == 0) {
        _reConnectTime = 2;
    } else {
        _reConnectTime *= 2;
    }
}

#pragma mark-- SRWebSocketDelegate
#pragma mark - 收到服务器消息是回调
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"收到服务器返回消息：%@", message);
}

#pragma mark - 连接成功
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"连接成功，可以立刻登录你公司后台的服务器了，还有开启心跳");
    [self initHeart]; // 开启心跳

    if (self.socket != nil) {
        // 只有 SR_OPEN 开启状态才能调 send 方法啊，不然要崩
        if (_socket.readyState == SR_OPEN) {
            NSString *jsonString = @"{\"sid\": \"13b313a3-fea9-4e28-9e56-352458f7007f\"}";
            NSError *error;
            [_socket sendString:jsonString error:&error]; // 发送数据包

        } else if (_socket.readyState == SR_CONNECTING) {
            NSLog(@"正在连接中，重连后其他方法会去自动同步数据");
            // 每隔2秒检测一次 socket.readyState 状态，检测 10 次左右
            // 只要有一次状态是 SR_OPEN 的就调用 [ws.socket send:data] 发送数据
            // 如果 10 次都还是没连上的，那这个发送请求就丢失了，这种情况是服务器的问题了，小概率的
            // 代码有点长，我就写个逻辑在这里好了

        } else if (_socket.readyState == SR_CLOSING || _socket.readyState == SR_CLOSED) {
            // websocket 断开了，调用 reConnect 方法重连
        }
    } else {
        NSLog(@"没网络，发送失败，一旦断网 socket 会被我设置 nil 的");
        NSLog(@"其实最好是发送前判断一下网络状态比较好，我写的有点晦涩，socket==nil来表示断网");
    }
}

#pragma mark - 连接失败的回调
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"连接失败，这里可以实现掉线自动重连，要注意以下几点");
    NSLog(@"1.判断当前网络环境，如果断网了就不要连了，等待网络到来，在发起重连");
    NSLog(@"2.判断调用层是否需要连接，例如用户都没在聊天界面，连接上去浪费流量");
    // 关闭心跳包
    [webSocket close];

    [self reConnect];
}

#pragma mark - 连接断开的回调
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"Close");
}
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;
{
    NSLog(@"Pong");
}

@end
