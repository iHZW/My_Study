// 独立 iOS 回归程序：用可控网络替身验证真实控制器回调，不建立无线连接。
#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "CRMNearbyDrawingViewController.h"
#import "CRMNearbyDrawingDocument.h"

@interface CRMNearbyDrawingViewController (ConnectionTesting)
- (void)acceptInvitation;
- (void)checkSyncHealth;
- (void)startSyncHealthCheck;
- (void)repairSynchronization;
- (void)rejectInvitation;
- (void)stopConnection;
- (void)startConnectionTimeout:(NSTimeInterval)seconds message:(NSString *)message;
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peer withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))handler;
- (void)session:(MCSession *)session peer:(MCPeerID *)peer didChangeState:(MCSessionState)state;
- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peer certificateHandler:(void (^)(BOOL))handler;
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peer;
@end
@interface CRMConnectionFakeSession : NSObject
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSArray *connectedPeers;
@property (nonatomic, strong) NSMutableArray *sentMessages;
@property (nonatomic) NSUInteger disconnectCount;
@end
@implementation CRMConnectionFakeSession
- (BOOL)sendData:(NSData *)data toPeers:(NSArray *)peers withMode:(MCSessionSendDataMode)mode error:(NSError **)error {
    [self.sentMessages addObject:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
    return YES;
}
- (void)disconnect { self.disconnectCount++; }
@end
@interface CRMConnectionFakeAdvertiser : NSObject
@property (nonatomic, weak) id delegate;
@property (nonatomic) NSUInteger stopCount;
@end
@implementation CRMConnectionFakeAdvertiser
- (void)stopAdvertisingPeer { self.stopCount++; }
@end
@interface CRMConnectionTestController : CRMNearbyDrawingViewController
@property (nonatomic) BOOL simulateModal;
@property (nonatomic) BOOL simulateMoving;
@end
@implementation CRMConnectionTestController
- (BOOL)isMovingFromParentViewController { return self.simulateMoving || [super isMovingFromParentViewController]; }
- (UIViewController *)presentedViewController { return self.simulateModal ? [UIViewController new] : [super presentedViewController]; }
@end
static void Check(BOOL value, NSString *message) {
    if (!value) @throw [NSException exceptionWithName:@"连接回归失败" reason:message userInfo:nil];
}
static void Next(dispatch_block_t block) { dispatch_async(dispatch_get_main_queue(), block); }
static void Deliver(CRMNearbyDrawingViewController *vc, id session, MCPeerID *peer, NSString *type) {
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"type":type,@"version":@1} options:0 error:nil];
    [vc session:session didReceiveData:data fromPeer:peer];
}
static void RunSyncRecoveryTests(dispatch_block_t completion) {
    CRMConnectionTestController *vc = [CRMConnectionTestController new];
    [vc loadViewIfNeeded];
    CRMConnectionFakeSession *session = [CRMConnectionFakeSession new];
    session.sentMessages = [NSMutableArray array];
    MCPeerID *peer = [[MCPeerID alloc] initWithDisplayName:@"恢复测试"];
    session.connectedPeers = @[peer];
    [vc setValue:session forKey:@"session"];
    [vc setValue:peer forKey:@"acceptedPeer"];
    [vc setValue:@YES forKey:@"host"];
    [vc setValue:@YES forKey:@"ready"];
    CRMNearbyDrawingDocument *doc = [vc valueForKey:@"document"];
    NSDictionary *begin = @{@"type":@"begin", @"version":@1, @"revision":@1, @"stroke":@{@"id":@"s1", @"color":@0, @"width":@4, @"points":@[@[@0.2,@0.3]]}};
    Check([doc applyOperation:begin], @"创建测试笔迹");
    [vc startSyncHealthCheck];
    [vc checkSyncHealth];
    Check([session.sentMessages.lastObject[@"type"] isEqual:@"state"], @"就绪后应定期发送修订确认");
    [vc repairSynchronization];
    Check([session.sentMessages.lastObject[@"type"] isEqual:@"snapshot"], @"观看端落后时创建端应补发完整画布");
    NSUInteger count = session.sentMessages.count;
    [vc repairSynchronization];
    Check(session.sentMessages.count == count, @"补偿必须限频，不能不停发送快照");
    [vc setValue:@NO forKey:@"host"];
    [vc setValue:@2 forKey:@"peerRevision"];
    [vc setValue:@0 forKey:@"lastRepairTime"];
    [vc repairSynchronization];
    Check([session.sentMessages.lastObject[@"type"] isEqual:@"sync"], @"观看端检测落后应主动请求快照");
    NSData *data = [NSJSONSerialization dataWithJSONObject:begin options:0 error:nil];
    [vc session:(id)session didReceiveData:data fromPeer:peer];
    Next(^{
        Check([[vc valueForKey:@"ready"] boolValue] && doc.revision == 1, @"重复旧操作应忽略，不能触发同步循环");
        [vc setValue:@(NSProcessInfo.processInfo.systemUptime - 21) forKey:@"lastPeerMessage"];
        [vc checkSyncHealth];
        Check([vc valueForKey:@"session"] == nil && [vc valueForKey:@"healthTimer"] == nil, @"失去响应应结束假连接并清理健康检查");
        Check(doc.revision == 1, @"断流不能清除本地画布");
        completion();
    });
}
@interface CRMConnectionTestDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow *window;
@end
@implementation CRMConnectionTestDelegate
- (BOOL)application:(UIApplication *)app didFinishLaunchingWithOptions:(NSDictionary *)options {
    CRMConnectionTestController *vc = [CRMConnectionTestController new];
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.window makeKeyAndVisible];
    CRMConnectionFakeSession *session = [CRMConnectionFakeSession new];
    session.sentMessages = [NSMutableArray array];
    CRMConnectionFakeAdvertiser *advertiser = [CRMConnectionFakeAdvertiser new];
    MCPeerID *peer = [[MCPeerID alloc] initWithDisplayName:@"观看者"];
    MCPeerID *stranger = [[MCPeerID alloc] initWithDisplayName:@"其他设备"];
    [vc setValue:session forKey:@"session"];
    [vc setValue:advertiser forKey:@"advertiser"];
    [vc setValue:@YES forKey:@"host"];
    vc.simulateModal = YES;
    __block NSUInteger replies = 0;
    [vc advertiser:(id)advertiser didReceiveInvitationFromPeer:peer withContext:nil invitationHandler:^(BOOL accept, MCSession *result) {
        Check(accept && (id)result == session, @"允许应只调用一次并使用当前会话"); replies++;
    }];
    Next(^{
        Check([vc valueForKey:@"pendingInvitation"] != nil && ![[vc valueForKey:@"invitationPanel"] isHidden], @"已有模态页面也必须保留并展示邀请");
        Check(replies == 0, @"用户确认前不能自动接受");
        [vc acceptInvitation]; [vc acceptInvitation];
        Check(replies == 1, @"重复点击允许不能重复调用邀请回调");
        vc.simulateModal = NO;
        vc.simulateMoving = YES;
        [vc viewWillDisappear:NO];
        Check([vc valueForKey:@"session"] == session, @"转场开始不能立即断开会话");
        vc.simulateMoving = NO;
        [vc viewDidDisappear:NO];
        Check([vc valueForKey:@"session"] == session, @"模态页面生命周期不能断开会话");
        [vc session:(id)session didReceiveCertificate:@[] fromPeer:peer certificateHandler:^(BOOL accept) { Check(accept, @"应接受已选目标"); }];
        [vc session:(id)session didReceiveCertificate:@[] fromPeer:stranger certificateHandler:^(BOOL accept) { Check(!accept, @"不能放行非目标证书"); }];
        [vc session:(id)session peer:stranger didChangeState:MCSessionStateNotConnected];
        Next(^{
            Check([vc valueForKey:@"session"] == session, @"页面仍在导航栈时不能因转场标记断开会话");
            Check([vc valueForKey:@"acceptedPeer"] == peer, @"其他设备断开不能清除当前目标");
            session.connectedPeers = @[peer];
            [vc session:(id)session peer:peer didChangeState:MCSessionStateConnected];
            Next(^{
                Check(advertiser.stopCount == 0, @"不能在单边已连接时提前停止广播");
                Deliver(vc, session, peer, @"sync");
                Next(^{
                    Check([session.sentMessages.lastObject[@"type"] isEqual:@"snapshot"], @"收到同步请求必须返回画布");
                    Deliver(vc, session, peer, @"ready");
                    Next(^{
                        Check([[vc valueForKey:@"ready"] boolValue] && advertiser.stopCount == 1, @"对方确认就绪后才完成连接");
                        Check([vc valueForKey:@"connectionTimer"] == nil, @"就绪后应取消超时");
                        CRMConnectionFakeSession *old = [CRMConnectionFakeSession new];
                        [vc session:(id)old peer:peer didChangeState:MCSessionStateNotConnected];
                        Next(^{
                            Check([vc valueForKey:@"session"] == session, @"旧会话回调不能断开新会话");
                            [vc startConnectionTimeout:45 message:@"测试超时"];
                            NSTimer *staleTimer = [vc valueForKey:@"connectionTimer"];
                            CRMConnectionFakeSession *replacement = [CRMConnectionFakeSession new];
                            [vc setValue:replacement forKey:@"session"];
                            [staleTimer fire];
                            Check([vc valueForKey:@"session"] == replacement, @"旧超时不能断开新会话");
                            [vc stopConnection];
                            Check(replacement.disconnectCount == 1, @"显式断开应释放当前会话");
                            RunSyncRecoveryTests(^{
                            NSString *result = @"通过：转场开始及取消保留连接、模态期间邀请、重复允许、页面生命周期、目标证书、非目标/旧会话回调、应用层就绪、过期超时、修订确认、漏包补偿、补偿限频、重复操作、断流检测及画布保留。";
                            NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/connection-test-result.txt"];
                            [result writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
                            NSLog(@"%@", result);
                            });
                        });
                    });
                });
            });
        });
    });
    return YES;
}
@end
int main(int argc, char *argv[]) { @autoreleasepool { return UIApplicationMain(argc, argv, nil, NSStringFromClass(CRMConnectionTestDelegate.class)); } }
