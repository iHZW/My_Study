#import "CRMBabyAudio.h"
#import "CRMBabyStore.h"
#import <UIKit/UIKit.h>

NSNotificationName const CRMBabyAudioChanged = @"CRMBabyAudioChanged";
@interface CRMBabyAudio () <AVAudioPlayerDelegate, AVAudioRecorderDelegate>
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *playingTitle;
@property (nonatomic, strong) NSURL *recordingURL;
@property (nonatomic, strong) NSTimer *recordingTimer;
@property (nonatomic, strong) NSTimer *sleepTimer;
@property (nonatomic, strong) NSDate *sleepDeadline;
@end
@implementation CRMBabyAudio
+ (instancetype)shared {
    static CRMBabyAudio *audio;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ audio = [self new]; });
    return audio;
}
- (instancetype)init {
    if (self = [super init]) {
        _status = @"挑一段喜欢的声音，放慢一点";
        NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
        [center addObserver:self selector:@selector(interrupted:) name:AVAudioSessionInterruptionNotification object:nil];
        [center addObserver:self selector:@selector(routeChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
        [center addObserver:self selector:@selector(backgrounded) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [center addObserver:self selector:@selector(mediaReset) name:AVAudioSessionMediaServicesWereResetNotification object:nil];
        [center addObserver:self selector:@selector(foregrounded) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}
- (BOOL)recording { return self.recorder.isRecording; }
- (BOOL)playing { return self.player.isPlaying; }
- (NSTimeInterval)remaining { return MAX(0, [self.sleepDeadline timeIntervalSinceNow]); }
- (void)changed { [NSNotificationCenter.defaultCenter postNotificationName:CRMBabyAudioChanged object:self]; }
- (BOOL)activateCategory:(NSString *)category {
    NSError *error;
    AVAudioSession *session = AVAudioSession.sharedInstance;
    // 不启用混音；激活时让其他音频会话暂停，结束后通知其恢复。
    AVAudioSessionCategoryOptions options = [category isEqualToString:AVAudioSessionCategoryPlayAndRecord] ? AVAudioSessionCategoryOptionDefaultToSpeaker : 0;
    if (![session setCategory:category mode:AVAudioSessionModeDefault options:options error:&error] || ![session setActive:YES error:&error]) {
        self.status = error.localizedDescription ?: @"声音暂时无法使用";
        [self changed]; return NO;
    }
    return YES;
}
- (void)deactivate { [AVAudioSession.sharedInstance setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil]; }
- (void)playURL:(NSURL *)url title:(NSString *)title {
    [self stop];
    if (![self activateCategory:AVAudioSessionCategoryPlayback]) return;
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.player.delegate = self;
    self.player.volume = 0.6;
    if (!self.player || ![self.player play]) {
        self.status = error.localizedDescription ?: @"音频无法播放，请检查文件是否完整";
        self.player = nil; [self deactivate];
    } else {
        self.playingTitle = title;
        self.status = [@"正在播放 · " stringByAppendingString:title];
    }
    [self changed];
}
- (void)togglePause {
    if (self.recording) return;
    if (!self.player) { self.status = @"先选择一段声音吧"; [self changed]; return; }
    if (self.player.playing) {
        [self.player pause]; self.status = [@"已暂停 · " stringByAppendingString:self.playingTitle];
        [self deactivate];
    } else if ([self activateCategory:AVAudioSessionCategoryPlayback]) {
        if ([self.player play]) self.status = [@"正在播放 · " stringByAppendingString:self.playingTitle];
        else self.status = @"音频恢复播放失败，请重新选择";
    }
    [self changed];
}
- (void)stop {
    [self.player stop]; self.player = nil;
    [self.sleepTimer invalidate]; self.sleepTimer = nil; self.sleepDeadline = nil;
    if (self.recorder) {
        NSTimeInterval duration = self.recorder.currentTime;
        AVAudioRecorder *recorder = self.recorder;
        self.recorder = nil;
        [recorder stop];
        [self.recordingTimer invalidate]; self.recordingTimer = nil;
        NSError *error;
        if (duration < 0.5) self.status = @"录音太短，尚未加入手记";
        else if ([CRMBabyStore.shared addEntry:@{@"type": @"audio", @"file": self.recordingURL.lastPathComponent, @"text": @"爸爸妈妈的声音", @"duration": @(duration)} error:&error]) self.status = @"录音已保存到手记和声音小屋";
        else self.status = [@"录音索引保存失败，文件仍在本地，可导出备份：" stringByAppendingString:error.localizedDescription ?: @""];
        self.recordingURL = nil;
    } else self.status = @"声音已停止";
    [self deactivate]; [self changed];
}
- (void)startRecording {
    if (self.recording) { [self stop]; return; }
    if (CRMBabyStore.shared.loadError) { self.status = CRMBabyStore.shared.loadError.localizedDescription; [self changed]; return; }
    [AVAudioSession.sharedInstance requestRecordPermission:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 权限弹窗期间可能切到后台，此时不启动麦克风。
            if (!granted) { self.status = @"麦克风未授权，可在系统设置中开启"; [self changed]; return; }
            if (UIApplication.sharedApplication.applicationState != UIApplicationStateActive) return;
            [self stop];
            if (![self activateCategory:AVAudioSessionCategoryPlayAndRecord]) return;
            NSURL *url = [CRMBabyStore.shared.directory URLByAppendingPathComponent:[NSUUID.UUID.UUIDString stringByAppendingPathExtension:@"m4a"]];
            NSError *error;
            AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:url settings:@{AVFormatIDKey: @(kAudioFormatMPEG4AAC), AVSampleRateKey: @44100, AVNumberOfChannelsKey: @1, AVEncoderAudioQualityKey: @(AVAudioQualityMedium)} error:&error];
            recorder.delegate = self;
            if (!recorder || ![recorder record]) {
                self.status = error.localizedDescription ?: @"录音无法开始，请检查剩余空间";
                [self deactivate]; [self changed]; return;
            }
            self.recorder = recorder; self.recordingURL = url;
            self.status = @"正在录音 · 再点一次完成（最长 3 分钟）";
            __weak typeof(self) weakSelf = self;
            self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:180 repeats:NO block:^(NSTimer *timer) { [weakSelf stop]; }];
            [self changed];
        });
    }];
}
- (void)setSleepMinutes:(NSInteger)minutes {
    [self.sleepTimer invalidate]; self.sleepTimer = nil; self.sleepDeadline = nil;
    if (minutes > 0 && self.player) {
        self.sleepDeadline = [NSDate dateWithTimeIntervalSinceNow:minutes * 60];
        __weak typeof(self) weakSelf = self;
        self.sleepTimer = [NSTimer scheduledTimerWithTimeInterval:minutes * 60 repeats:NO block:^(NSTimer *timer) { [weakSelf stop]; }];
    }
    [self changed];
}
- (void)interrupted:(NSNotification *)notification {
    if ([notification.userInfo[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue] == AVAudioSessionInterruptionTypeBegan) [self stop];
}
- (void)routeChanged:(NSNotification *)notification {
    if ([notification.userInfo[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue] == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) [self stop];
}
- (void)backgrounded { if (self.recorder) [self stop]; }
- (void)foregrounded { if (self.sleepDeadline && self.remaining <= 0) [self stop]; }
- (void)mediaReset { [self stop]; }
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag { [self stop]; }
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error { [self stop]; self.status = @"音频解码失败，请选择其他文件"; [self changed]; }
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error { [self stop]; self.status = error.localizedDescription ?: @"录音保存失败"; [self changed]; }
@end
