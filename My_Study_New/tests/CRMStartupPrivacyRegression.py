from pathlib import Path
import subprocess,plistlib,tempfile,json,time,signal
signal.signal(signal.SIGALRM, lambda *_: (_ for _ in ()).throw(SystemExit("回归验证超过60秒，已终止。")))
signal.alarm(60)
root=Path(__file__).resolve().parents[1]
r=Path(tempfile.mkdtemp(prefix='crm-startup-tests-'))
main=(root/'My_Study/PublicComponent/Manager/AppDelegateManager/ZWMainAppDelegateService.m').read_text();manager=(root/'My_Study/PublicComponent/CMBusMedia/ZWPrivacyPolicyManager.m').read_text()
photos=main[main.index('- (BOOL)canHandleScreenshot'):main.index('- (void)applicationDidBecomeActive:')]+main[main.index('- (void)startObservingScreenshots'):main.index('- (UIImage *)captureCurrentAppImage')]+main[main.index('- (void)userDidTakeScreenshot:'):main.index('#pragma mark - 显示截屏图片')]
check=manager[manager.index('+ (BOOL)checkShowPrivacyPolicy'):manager.index('+ (void)initializeAction')]
start=manager[manager.index('+ (void)startServicesAfterPrivacyConsent {'):manager.index('+ (BOOL)application:',manager.index('+ (void)startServicesAfterPrivacyConsent {'))]
active=manager[manager.index('+ (void)applicationDidBecomeActive:'):manager.index('+ (void)applicationWillTerminate:')]
src='''#import <UIKit/UIKit.h>

static NSUInteger sdkStarts, businessStarts, activeCalls;
@interface MMPrivacyManager : NSObject
@property BOOL allowed;
+ (instancetype)sharedInstance;
- (BOOL)hasShowedAppPrivacy;
@end
@implementation MMPrivacyManager
+ (instancetype)sharedInstance { static id obj; if (!obj) obj=[self new]; return obj; }
- (BOOL)hasShowedAppPrivacy { return self.allowed; }
@end
@interface ZWMainAppDelegateService : NSObject
- (void)startServicesAfterPrivacyConsent;
@end
@implementation ZWMainAppDelegateService
- (void)startServicesAfterPrivacyConsent { businessStarts++; }
- (void)applicationDidBecomeActive:(UIApplication *)application { activeCalls++; }
@end
@interface ZWPushAppDelegateService : NSObject
- (BOOL)application:(UIApplication *)app didFinishLaunchingWithOptions:(NSDictionary *)options;
@end
@implementation ZWPushAppDelegateService
- (BOOL)application:(UIApplication *)app didFinishLaunchingWithOptions:(NSDictionary *)options { return YES; }
@end
@interface CMBusMediaAppDelegate : NSObject
+ (id)service:(Class)cls;
+ (void)serviceManager:(SEL)selector withParameters:(NSArray *)params;
@end
@implementation CMBusMediaAppDelegate
+ (id)service:(Class)cls { static id main, push; if(!main) {main=[ZWMainAppDelegateService new];push=[ZWPushAppDelegateService new];}return cls==ZWMainAppDelegateService.class?main:push; }
+ (void)serviceManager:(SEL)selector withParameters:(NSArray *)params { [[self service:ZWMainAppDelegateService.class] applicationDidBecomeActive:params.firstObject]; }
@end
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic,strong) UIWindow *window;
- (void)startServicesAfterPrivacyConsentWithLaunchOptions:(NSDictionary *)options;
@end
static NSDictionary *ZWPrivacyLaunchOptions;
static BOOL ZWPrivacyServicesStarted;
@interface ZWPrivacyPolicyManager : NSObject
+ (BOOL)checkShowPrivacyPolicy;
+ (void)startServicesAfterPrivacyConsent;
+ (void)applicationDidBecomeActive:(UIApplication *)application;
@end
@implementation ZWPrivacyPolicyManager
'''+check+start+active+'''
@end
@interface ScreenshotTester : NSObject
@property BOOL observingScreenshots;
@property NSUInteger screenshotGeneration;
@property NSUInteger loads;
@property NSUInteger captures;
- (UIImage *)captureCurrentAppImage;
- (void)_handleShowScreenShotImage:(UIImage *)image;
@end
@implementation ScreenshotTester
- (UIImage *)captureCurrentAppImage {self.captures++;return [UIImage new];}
- (void)_handleShowScreenShotImage:(UIImage *)image {self.loads++;}
'''+photos+'''
@end
static void Check(BOOL val, NSString *msg) { if(!val) @throw [NSException exceptionWithName:@"启动回归失败" reason:msg userInfo:nil]; }
static void Next(dispatch_block_t block) {dispatch_async(dispatch_get_main_queue(),block);}
@implementation AppDelegate
- (void)startServicesAfterPrivacyConsentWithLaunchOptions:(NSDictionary *)options {sdkStarts++;}
- (BOOL)application:(UIApplication *)app didFinishLaunchingWithOptions:(NSDictionary *)options {
 self.window=[[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];self.window.rootViewController=[UIViewController new];[self.window makeKeyAndVisible];
 dispatch_after(dispatch_time(DISPATCH_TIME_NOW,500*NSEC_PER_MSEC),dispatch_get_main_queue(),^{
    Check([ZWPrivacyPolicyManager checkShowPrivacyPolicy],@"未同意协议必须阻止业务启动");
    [ZWPrivacyPolicyManager startServicesAfterPrivacyConsent];
    Check(sdkStarts==0 && businessStarts==0,@"未同意不能启动SDK和业务");
    ScreenshotTester *photo=[ScreenshotTester new];
    [photo startObservingScreenshots];
    Check(!photo.observingScreenshots,@"协议未同意不能注册截屏监听");
    [photo userDidTakeScreenshot:nil];
    Check(photo.captures==0 && photo.loads==0,@"未同意不能抓取画面或弹窗");
    MMPrivacyManager.sharedInstance.allowed=YES;
    [ZWPrivacyPolicyManager startServicesAfterPrivacyConsent];[ZWPrivacyPolicyManager startServicesAfterPrivacyConsent];
    Check(sdkStarts==1 && businessStarts==1 && activeCalls==1,@"同意后只初始化一次且恢复前台业务");
    [photo startObservingScreenshots];[photo startObservingScreenshots];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationUserDidTakeScreenshotNotification object:nil];
    Next(^{
        Check(photo.captures==1 && photo.loads==1,@"无需相册授权，新截屏应弹出且重复启动监听不能重复弹窗");
        [photo userDidTakeScreenshot:nil];
        [photo stopObservingScreenshots];
        Next(^{
            Check(photo.loads==1,@"后台或停止监听后的排队回调不能弹窗");
            [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationUserDidTakeScreenshotNotification object:nil];
            Check(photo.captures==2,@"停止监听后不能继续截取画面");
            [photo startObservingScreenshots];
            Next(^{
                Check(photo.loads==1,@"重新进入前台不能补弹旧截图");
                MMPrivacyManager.sharedInstance.allowed=NO;
                [photo userDidTakeScreenshot:nil];
                Check(photo.captures==2,@"截屏处理时必须再次检查协议门槛");
                [photo stopObservingScreenshots];
                [@"通过：协议门控、同意后只初始化一次、截屏通知触发、无相册授权依赖、重复注册保护、停止监听及迟到回调拦截、回前台不补弹。" writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/result.txt"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
            });
        });
    });
 });return YES;
}
@end
int main(int argc,char **argv) {@autoreleasepool{return UIApplicationMain(argc,argv,nil,NSStringFromClass(AppDelegate.class));}}
'''
src=src.replace('Documents/result.txt', 'Documents/'+r.name+'.txt')
(r/'tests.m').write_text(src)
app=r/'StartupTests.app';app.mkdir(exist_ok=True)
sdk=subprocess.check_output(['xcrun','--sdk','iphonesimulator','--show-sdk-path'],text=True).strip()
subprocess.run(['xcrun','clang','-fobjc-arc','-fmodules','-fmodules-cache-path='+str(r/'module-cache'),'-target','arm64-apple-ios12.0-simulator','-isysroot',sdk,'-framework','UIKit','-framework','Photos',str(r/'tests.m'),'-o',str(app/'StartupTests')],check=True,timeout=60)
(app/'Info.plist').write_bytes(plistlib.dumps(dict(CFBundleIdentifier='com.crm.startup.tests',CFBundleExecutable='StartupTests',CFBundlePackageType='APPL',MinimumOSVersion='12.0',UILaunchScreen={})))
subprocess.run(['codesign','--force','--sign','-',str(app)],check=True,timeout=15)

# 需要已有启动的模拟器；整段运行在一分钟内完成。
devices=json.loads(subprocess.check_output(['xcrun','simctl','list','devices','booted','-j'],text=True))
booted=[d['udid'] for group in devices['devices'].values() for d in group if d['state']=='Booted']
if not booted: raise SystemExit('请先在Xcode启动一台iPhone模拟器，再运行此脚本。')
udid=booted[0]
for args in [['install',udid,str(app)],['launch',udid,'com.crm.startup.tests']]:
 subprocess.run(['xcrun','simctl']+args,check=True,timeout=15)
container=subprocess.check_output(['xcrun','simctl','get_app_container',udid,'com.crm.startup.tests','data'],text=True,timeout=10).strip()
result=Path(container)/'Documents'/(r.name+'.txt')
for _ in range(20):
 if result.exists(): print(result.read_text());break
 time.sleep(0.25)
else: raise SystemExit('未生成通过结果，请查看模拟器测试进程崩溃记录。')
