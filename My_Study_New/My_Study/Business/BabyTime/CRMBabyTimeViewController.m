#import "CRMBabyTimeViewController.h"
#import "CRMBabyStore.h"
#import "CRMBabyAudio.h"
#import <MobileCoreServices/MobileCoreServices.h>

// 所有颜色由系统外观动态解析，保持与首页一致的绿色卡片语言。
static UIColor *BabyRGB(NSUInteger hex) {
    return [UIColor colorWithRed:((hex >> 16) & 255) / 255.0 green:((hex >> 8) & 255) / 255.0 blue:(hex & 255) / 255.0 alpha:1];
}
static UIColor *BabyColor(NSUInteger light, NSUInteger dark) {
    if (@available(iOS 13.0, *)) return [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traits) { return BabyRGB(traits.userInterfaceStyle == UIUserInterfaceStyleDark ? dark : light); }];
    return BabyRGB(light);
}
static UIColor *BabyBackground(void) { return BabyColor(0xF3F6F0, 0x151E1B); }
static UIColor *BabyCard(void) { return BabyColor(0xFFFFFF, 0x22302B); }
static UIColor *BabyInk(void) { return BabyColor(0x294B46, 0xE2EFE7); }
static UIColor *BabyMuted(void) { return BabyColor(0x72847B, 0xABC0B4); }
static UIColor *BabyAccent(void) { return BabyColor(0x3C7862, 0xA9D6B9); }
static UIFont *BabyFont(CGFloat size, UIFontWeight weight) {
    return [[UIFontMetrics metricsForTextStyle:UIFontTextStyleBody] scaledFontForFont:[UIFont systemFontOfSize:size weight:weight]];
}
static UILabel *BabyLabel(NSString *text, CGFloat size, UIColor *color) {
    UILabel *label = [UILabel new]; label.text = text; label.font = BabyFont(size, UIFontWeightRegular);
    label.textColor = color; label.numberOfLines = 0; label.adjustsFontForContentSizeCategory = YES;
    return label;
}
static void BabyAlert(UIViewController *vc, NSString *message) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
    [vc presentViewController:alert animated:YES completion:nil];
}
static void BabyAnchor(UIAlertController *alert, UIViewController *vc, UIView *source) {
    alert.popoverPresentationController.sourceView = source ?: vc.view;
    alert.popoverPresentationController.sourceRect = source ? source.bounds : CGRectMake(CGRectGetMidX(vc.view.bounds), CGRectGetMidY(vc.view.bounds), 1, 1);
}
@interface CRMBabyButton : UIButton
@property (nonatomic, copy) void (^action)(void);
@end
@implementation CRMBabyButton
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];
    return self;
}
- (void)tapped { if (self.action) self.action(); }
@end
static CRMBabyButton *BabyButton(NSString *title, void (^action)(void)) {
    CRMBabyButton *button = [CRMBabyButton new];
    [button setTitle:title forState:UIControlStateNormal]; [button setTitleColor:BabyAccent() forState:UIControlStateNormal];
    button.backgroundColor = BabyColor(0xE6F0E7, 0x2C4437); button.layer.cornerRadius = 14;
    button.titleLabel.font = BabyFont(15, UIFontWeightSemibold); button.titleLabel.adjustsFontForContentSizeCategory = YES;
    button.titleLabel.numberOfLines = 0; button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.contentEdgeInsets = UIEdgeInsetsMake(14, 16, 14, 16); button.action = action;
    return button;
}
static UIStackView *BabyStack(void) {
    UIStackView *stack = [UIStackView new]; stack.axis = UILayoutConstraintAxisVertical; stack.spacing = 14;
    return stack;
}
static UIView *BabyBox(NSArray<UIView *> *views) {
    UIView *box = [UIView new]; box.backgroundColor = BabyCard(); box.layer.cornerRadius = 22;
    UIStackView *stack = BabyStack(); stack.translatesAutoresizingMaskIntoConstraints = NO;
    [box addSubview:stack]; for (UIView *view in views) [stack addArrangedSubview:view];
    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:box.topAnchor constant:20], [stack.bottomAnchor constraintEqualToAnchor:box.bottomAnchor constant:-20],
        [stack.leadingAnchor constraintEqualToAnchor:box.leadingAnchor constant:20], [stack.trailingAnchor constraintEqualToAnchor:box.trailingAnchor constant:-20]
    ]]; return box;
}
static UIStackView *BabyScroll(UIViewController *vc, UIScrollView **outScroll) {
    UIScrollView *scroll = [UIScrollView new]; scroll.translatesAutoresizingMaskIntoConstraints = NO;
    scroll.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [vc.view addSubview:scroll];
    UIStackView *stack = BabyStack(); stack.translatesAutoresizingMaskIntoConstraints = NO; [scroll addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [scroll.topAnchor constraintEqualToAnchor:vc.view.safeAreaLayoutGuide.topAnchor], [scroll.bottomAnchor constraintEqualToAnchor:vc.view.bottomAnchor],
        [scroll.leadingAnchor constraintEqualToAnchor:vc.view.leadingAnchor], [scroll.trailingAnchor constraintEqualToAnchor:vc.view.trailingAnchor],
        [stack.topAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.topAnchor constant:18], [stack.bottomAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.bottomAnchor constant:-36],
        [stack.leadingAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.leadingAnchor constant:20], [stack.trailingAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.trailingAnchor constant:-20],
        [stack.widthAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.widthAnchor constant:-40]
    ]]; if (outScroll) *outScroll = scroll; return stack;
}

@interface CRMBabyReaderController : UIViewController <AVSpeechSynthesizerDelegate>
@property (nonatomic, strong) NSDictionary *reading;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UILabel *speechStatus;
@property (nonatomic, strong) CRMBabyButton *speechButton;
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;
@property (nonatomic, strong) AVSpeechSynthesisVoice *speechVoice;
@property (nonatomic, strong) UISegmentedControl *speechRate;
@property (nonatomic) BOOL speechSessionActive;
@property (nonatomic) BOOL large;
@end
@implementation CRMBabyReaderController
- (void)viewDidLoad {
    [super viewDidLoad]; self.title = self.reading[@"title"]; self.view.backgroundColor = BabyBackground();
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"收藏" style:UIBarButtonItemStylePlain target:self action:@selector(favorite)];
    [self updateFavorite];
    UIStackView *stack = BabyScroll(self, nil);
    [stack addArrangedSubview:BabyLabel(self.reading[@"icon"], 42, BabyInk())];
    UILabel *title = BabyLabel(self.reading[@"title"], 27, BabyInk()); title.font = BabyFont(27, UIFontWeightSemibold); [stack addArrangedSubview:title];
    BOOL podcast = [self.reading[@"sourceURL"] isKindOfClass:NSString.class];
    [stack addArrangedSubview:BabyLabel(podcast ? @"先读一段共读提示，再去原节目收听。把适合自己的观点留下，也允许自己有不同想法。" : @"找个舒服的位置，用自己的声音慢慢读。不必读完，也不必追求宝宝的回应。", 13, BabyMuted())];
    if (podcast) {
        NSString *address = self.reading[@"sourceURL"];
        [stack addArrangedSubview:BabyBox(@[BabyLabel(@"🎧  收听原节目", 19, BabyInk()),
                                          BabyLabel(@"音频及平台提供的文字请在 Apple 播客查看。这里是原创共读提示，不是书信原文或节目逐字稿。", 13, BabyMuted()),
                                          BabyButton(@"打开这期播客", ^{ [UIApplication.sharedApplication openURL:[NSURL URLWithString:address] options:@{} completionHandler:nil]; })])];
    }
    __weak typeof(self) weakSelf = self;
    self.synthesizer = [AVSpeechSynthesizer new]; self.synthesizer.delegate = self;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(speechInterrupted:) name:AVAudioSessionInterruptionNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(speechRouteChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
    self.speechVoice = [self preferredSpeechVoice];
    self.speechStatus = BabyLabel([self speechStatusText], 13, BabyMuted());
    self.speechButton = BabyButton(@"▶ 开始朗读", ^{ [weakSelf toggleSpeech]; });
    self.speechRate = [[UISegmentedControl alloc] initWithItems:@[@"舒缓", @"正常"]];
    self.speechRate.selectedSegmentIndex = 0;
    [self.speechRate addTarget:self action:@selector(speechRateChanged) forControlEvents:UIControlEventValueChanged];
    [stack addArrangedSubview:BabyBox(@[BabyLabel(podcast ? @"🔊  听听共读提示" : @"🔊  听听这篇", 19, BabyInk()),
                                      BabyLabel(podcast ? @"这里朗读的是本页原创导读。节目原声请点上方按钮前往 Apple 播客。" : @"使用 iPhone 系统中文语音，离线可听。设备已下载的增强语音会优先使用。", 13, BabyMuted()),
                                      self.speechStatus, self.speechButton,
                                      BabyButton(@"选择声音", ^{ [weakSelf chooseSpeechVoice]; }),
                                      BabyLabel(@"朗读速度", 13, BabyMuted()), self.speechRate,
                                      BabyButton(@"停止朗读", ^{ [weakSelf stopSpeech]; })])];
    [stack addArrangedSubview:BabyButton(@"切换大字阅读", ^{ weakSelf.large = !weakSelf.large; [weakSelf updateBody]; })];
    self.bodyLabel = BabyLabel(@"", 20, BabyInk()); self.bodyLabel.accessibilityIdentifier = @"baby.reading.body";
    [self updateBody]; [stack addArrangedSubview:BabyBox(@[self.bodyLabel])];
    [stack addArrangedSubview:BabyLabel(self.reading[@"source"], 12, BabyMuted())];
}
- (void)updateBody {
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new]; paragraph.lineSpacing = 10; paragraph.paragraphSpacing = 12;
    self.bodyLabel.attributedText = [[NSAttributedString alloc] initWithString:self.reading[@"body"] attributes:@{NSFontAttributeName: BabyFont(self.large ? 26 : 20, UIFontWeightRegular), NSForegroundColorAttributeName: BabyInk(), NSParagraphStyleAttributeName: paragraph}];
}
- (NSArray<AVSpeechSynthesisVoice *> *)chineseVoices {
    NSMutableArray *voices = [NSMutableArray new];
    for (AVSpeechSynthesisVoice *voice in AVSpeechSynthesisVoice.speechVoices) {
        // 个人声音的系统许可限个人非商业使用，不列入应用的朗读音色。
        if (@available(iOS 17.0, *)) {
            if (voice.voiceTraits & AVSpeechSynthesisVoiceTraitIsPersonalVoice) continue;
        }
        if ([voice.language hasPrefix:@"zh-CN"] || [voice.language hasPrefix:@"zh-Hans"]) [voices addObject:voice];
    }
    [voices sortUsingComparator:^NSComparisonResult(AVSpeechSynthesisVoice *left, AVSpeechSynthesisVoice *right) {
        if (left.quality != right.quality) return left.quality > right.quality ? NSOrderedAscending : NSOrderedDescending;
        return [left.name localizedCompare:right.name];
    }];
    return voices;
}
- (AVSpeechSynthesisVoice *)preferredSpeechVoice {
    NSString *saved = [NSUserDefaults.standardUserDefaults stringForKey:@"baby.reading.voice"];
    for (AVSpeechSynthesisVoice *voice in [self chineseVoices]) if ([voice.identifier isEqualToString:saved]) return voice;
    return [self chineseVoices].firstObject ?: [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
}
- (NSString *)speechStatusText {
    if (!self.speechVoice) return @"当前设备没有可用的普通话语音，请到系统设置检查语音资源。";
    NSString *quality = self.speechVoice.quality > AVSpeechSynthesisVoiceQualityEnhanced ? @"高品质" :
                        self.speechVoice.quality == AVSpeechSynthesisVoiceQualityEnhanced ? @"增强" : @"标准";
    return [NSString stringWithFormat:@"当前声音：%@ · %@", self.speechVoice.name, quality];
}
- (void)chooseSpeechVoice {
    NSArray *voices = [self chineseVoices];
    if (!voices.count) { BabyAlert(self, @"当前设备没有可选的普通话语音。"); return; }
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"选择朗读声音" message:@"这里只显示设备已经安装的普通话语音；更多语音可在 iPhone 设置中下载。切换声音会从文章开头重新朗读。" preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    for (AVSpeechSynthesisVoice *voice in voices) {
        NSString *quality = voice.quality > AVSpeechSynthesisVoiceQualityEnhanced ? @"高品质" :
                            voice.quality == AVSpeechSynthesisVoiceQualityEnhanced ? @"增强" : @"标准";
        NSString *title = [NSString stringWithFormat:@"%@ · %@%@", voice.name, quality, [voice.identifier isEqualToString:self.speechVoice.identifier] ? @" ✓" : @""];
        [sheet addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            BOOL wasSpeaking = weakSelf.synthesizer.isSpeaking;
            [weakSelf stopSpeech]; weakSelf.speechVoice = voice;
            [NSUserDefaults.standardUserDefaults setObject:voice.identifier forKey:@"baby.reading.voice"];
            [weakSelf updateSpeechControls];
            if (wasSpeaking) [weakSelf toggleSpeech];
        }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    BabyAnchor(sheet, self, self.speechButton); [self presentViewController:sheet animated:YES completion:nil];
}
- (void)toggleSpeech {
    if (self.synthesizer.isPaused) { [self.synthesizer continueSpeaking]; [self updateSpeechControls]; return; }
    if (self.synthesizer.isSpeaking) { [self.synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate]; [self updateSpeechControls]; return; }
    if (!self.speechVoice) { BabyAlert(self, @"当前设备没有可用的普通话语音。"); return; }
    [CRMBabyAudio.shared stop];
    NSError *error;
    AVAudioSession *session = AVAudioSession.sharedInstance;
    if (![session setCategory:AVAudioSessionCategoryPlayback mode:AVAudioSessionModeDefault options:0 error:&error] || ![session setActive:YES error:&error]) {
        BabyAlert(self, error.localizedDescription ?: @"朗读暂时无法开始"); return;
    }
    self.speechSessionActive = YES;
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:self.reading[@"body"]];
    utterance.voice = self.speechVoice;
    utterance.rate = self.speechRate.selectedSegmentIndex == 0 ? AVSpeechUtteranceDefaultSpeechRate * 0.82 : AVSpeechUtteranceDefaultSpeechRate;
    [self.synthesizer speakUtterance:utterance];
    [self updateSpeechControls];
}
- (void)speechRateChanged {
    if (self.synthesizer.isSpeaking) { [self stopSpeech]; [self toggleSpeech]; }
}
- (void)speechInterrupted:(NSNotification *)notification {
    if ([notification.userInfo[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue] == AVAudioSessionInterruptionTypeBegan) [self stopSpeech];
}
- (void)speechRouteChanged:(NSNotification *)notification {
    if ([notification.userInfo[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue] == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) [self stopSpeech];
}
- (void)stopSpeech {
    if (self.synthesizer.isSpeaking) [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    if (self.speechSessionActive) {
        self.speechSessionActive = NO;
        [AVAudioSession.sharedInstance setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    }
    [self updateSpeechControls];
}
- (void)updateSpeechControls {
    if (!self.speechButton) return;
    NSString *title = self.synthesizer.isPaused ? @"▶ 继续朗读" : self.synthesizer.isSpeaking ? @"Ⅱ 暂停朗读" : @"▶ 开始朗读";
    [self.speechButton setTitle:title forState:UIControlStateNormal];
    NSString *state = self.synthesizer.isPaused ? @"已暂停" : self.synthesizer.isSpeaking ? @"正在朗读" : @"";
    self.speechStatus.text = state.length ? [NSString stringWithFormat:@"%@ · %@", state, [self speechStatusText]] : [self speechStatusText];
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    if (!synthesizer.isSpeaking && self.speechSessionActive) {
        self.speechSessionActive = NO;
        [AVAudioSession.sharedInstance setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    }
    [self updateSpeechControls];
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance { [self updateSpeechControls]; }
- (void)viewWillDisappear:(BOOL)animated { [super viewWillDisappear:animated]; [self stopSpeech]; }
- (void)dealloc { [NSNotificationCenter.defaultCenter removeObserver:self]; self.synthesizer.delegate = nil; }
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection { [super traitCollectionDidChange:previousTraitCollection]; [self updateBody]; }
- (void)updateFavorite { self.navigationItem.rightBarButtonItem.title = [CRMBabyStore.shared.snapshot[@"favorites"] containsObject:self.reading[@"id"]] ? @"已收藏" : @"收藏"; }
- (void)favorite { NSError *error; if (![CRMBabyStore.shared toggleFavorite:self.reading[@"id"] error:&error]) BabyAlert(self, error.localizedDescription); [self updateFavorite]; }
@end

@interface CRMBabyProfileController : UIViewController
@property (nonatomic, strong) UISegmentedControl *stage;
@property (nonatomic, strong) UIDatePicker *picker;
@property (nonatomic, strong) UITextField *nickname;
@property (nonatomic, strong) UILabel *dateTitle;
@end
@implementation CRMBabyProfileController
- (void)viewDidLoad {
    [super viewDidLoad]; self.title = @"宝宝设置"; self.view.backgroundColor = BabyBackground();
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    UIStackView *stack = BabyScroll(self, nil);
    [stack addArrangedSubview:BabyLabel(@"每个阶段，都慢慢来", 26, BabyInk())];
    [stack addArrangedSubview:BabyLabel(@"预产期请使用产检确认的日期。这里只用于安排陪伴内容，不用于医疗判断。", 14, BabyMuted())];
    NSDictionary *profile = CRMBabyStore.shared.snapshot[@"profile"];
    self.nickname = [UITextField new]; self.nickname.placeholder = @"宝宝的小名（可不填）"; self.nickname.text = profile[@"nickname"]; self.nickname.font = BabyFont(18, UIFontWeightRegular); self.nickname.textColor = BabyInk(); self.nickname.borderStyle = UITextBorderStyleRoundedRect;
    self.nickname.accessibilityLabel = @"宝宝的小名";
    [stack addArrangedSubview:BabyBox(@[BabyLabel(@"怎么称呼宝宝", 15, BabyMuted()), self.nickname])];
    self.stage = [[UISegmentedControl alloc] initWithItems:@[@"孕期", @"已出生"]]; self.stage.selectedSegmentIndex = profile[@"birthDate"] ? 1 : 0;
    [self.stage addTarget:self action:@selector(stageChanged) forControlEvents:UIControlEventValueChanged]; [stack addArrangedSubview:self.stage];
    self.dateTitle = BabyLabel(@"", 17, BabyInk());
    self.picker = [UIDatePicker new]; self.picker.datePickerMode = UIDatePickerModeDate; self.picker.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
    if (@available(iOS 13.4, *)) self.picker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    [stack addArrangedSubview:BabyBox(@[self.dateTitle, self.picker])];
    [self stageChanged];
    [stack addArrangedSubview:BabyLabel(@"出生后请手动切换并记录出生日期；不会仅根据预产期自动切换。", 13, BabyMuted())];
}
- (void)stageChanged {
    NSDictionary *profile = CRMBabyStore.shared.snapshot[@"profile"];
    BOOL born = self.stage.selectedSegmentIndex == 1;
    self.dateTitle.text = born ? @"宝宝出生日期" : @"预产期";
    NSCalendar *calendar = NSCalendar.currentCalendar;
    self.picker.minimumDate = nil; self.picker.maximumDate = nil;
    self.picker.minimumDate = [calendar dateByAddingUnit:born ? NSCalendarUnitYear : NSCalendarUnitDay value:born ? -5 : -14 toDate:NSDate.date options:0];
    self.picker.maximumDate = born ? NSDate.date : [calendar dateByAddingUnit:NSCalendarUnitDay value:280 toDate:NSDate.date options:0];
    NSNumber *saved = profile[born ? @"birthDate" : @"dueDate"];
    self.picker.date = saved ? [NSDate dateWithTimeIntervalSince1970:saved.doubleValue] : (born ? NSDate.date : [calendar dateByAddingUnit:NSCalendarUnitDay value:154 toDate:NSDate.date options:0]);
}
- (void)save {
    NSString *name = [self.nickname.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (name.length > 20) { BabyAlert(self, @"小名请控制在 20 个字以内。"); return; }
    NSMutableDictionary *profile = [CRMBabyStore.shared.snapshot[@"profile"] mutableCopy];
    profile[@"nickname"] = name ?: @"";
    BOOL born = self.stage.selectedSegmentIndex == 1;
    NSDate *day = [NSCalendar.currentCalendar startOfDayForDate:self.picker.date];
    if (born) profile[@"birthDate"] = @(day.timeIntervalSince1970);
    else { [profile removeObjectForKey:@"birthDate"]; profile[@"dueDate"] = @(day.timeIntervalSince1970); }
    NSError *error; if (![CRMBabyStore.shared saveProfile:profile error:&error]) { BabyAlert(self, error.localizedDescription); return; }
    [self.navigationController popViewControllerAnimated:YES];
}
@end

@interface CRMBabyNoteEditor : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) UIImageView *preview;
@property (nonatomic, strong) UIScrollView *scroll;
@end
@implementation CRMBabyNoteEditor
- (void)viewDidLoad {
    [super viewDidLoad]; self.title = @"写给小小的你"; self.view.backgroundColor = BabyBackground();
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    UIScrollView *scroll;
    UIStackView *stack = BabyScroll(self, &scroll);
    self.scroll = scroll;
    [stack addArrangedSubview:BabyLabel(@"今天，有什么想留下？", 25, BabyInk())];
    [stack addArrangedSubview:BabyLabel(@"一件小事、一句期待，或一张值得记住的照片。", 14, BabyMuted())];
    self.textView = [UITextView new]; self.textView.font = BabyFont(18, UIFontWeightRegular); self.textView.textColor = BabyInk(); self.textView.backgroundColor = BabyCard(); self.textView.layer.cornerRadius = 18; self.textView.textContainerInset = UIEdgeInsetsMake(16, 12, 16, 12); self.textView.accessibilityLabel = @"手记内容";
    [self.textView.heightAnchor constraintEqualToConstant:230].active = YES; [stack addArrangedSubview:self.textView];
    __weak typeof(self) weakSelf = self;
    [stack addArrangedSubview:BabyButton(@"＋ 添加或替换照片", ^{ [weakSelf choosePhoto]; })];
    self.preview = [UIImageView new]; self.preview.contentMode = UIViewContentModeScaleAspectFit; self.preview.layer.cornerRadius = 18; self.preview.clipsToBounds = YES;
    [self.preview.heightAnchor constraintEqualToConstant:200].active = YES; self.preview.hidden = YES; [stack addArrangedSubview:self.preview];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboard:) name:UIKeyboardWillChangeFrameNotification object:nil];
}
- (void)dealloc { [NSNotificationCenter.defaultCenter removeObserver:self]; }
- (void)keyboard:(NSNotification *)note {
    CGRect frame = [self.view convertRect:[note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
    CGFloat overlap = MAX(0, CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(frame));
    self.scroll.contentInset = UIEdgeInsetsMake(0, 0, overlap, 0); self.scroll.scrollIndicatorInsets = self.scroll.contentInset;
}
- (void)choosePhoto {
    [self.view endEditing:YES];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) { BabyAlert(self, @"当前设备无法打开相册。"); return; }
    UIImagePickerController *picker = [UIImagePickerController new]; picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; picker.delegate = self; [self presentViewController:picker animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        CGFloat factor = MIN(1, 1600.0 / MAX(image.size.width, image.size.height));
        CGSize size = CGSizeMake(MAX(1, image.size.width * factor), MAX(1, image.size.height * factor));
        UIGraphicsBeginImageContextWithOptions(size, YES, 1); [image drawInRect:(CGRect){CGPointZero, size}]; self.photo = UIGraphicsGetImageFromCurrentImageContext(); UIGraphicsEndImageContext();
        self.preview.image = self.photo; self.preview.hidden = NO;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker { [picker dismissViewControllerAnimated:YES completion:nil]; }
- (void)save {
    NSString *text = [self.textView.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!text.length && !self.photo) { BabyAlert(self, @"写下一句话，或添加一张照片吧。"); return; }
    if (text.length > 10000) { BabyAlert(self, @"这篇手记较长，请控制在 10000 字以内。"); return; }
    NSMutableDictionary *entry = [@{@"type": self.photo ? @"photo" : @"text", @"text": text ?: @""} mutableCopy];
    NSError *error;
    if (self.photo) {
        NSData *data = UIImageJPEGRepresentation(self.photo, 0.82);
        NSURL *url = data ? [CRMBabyStore.shared saveAttachment:data extension:@"jpg" error:&error] : nil;
        if (!url) { BabyAlert(self, error.localizedDescription ?: @"照片保存失败，请重试。"); return; }
        entry[@"file"] = url.lastPathComponent;
    }
    if (![CRMBabyStore.shared addEntry:entry error:&error]) { BabyAlert(self, error.localizedDescription); return; }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)cancel {
    if (!self.textView.text.length && !self.photo) { [self.navigationController popViewControllerAnimated:YES]; return; }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"放弃这篇手记？" message:@"尚未保存的文字和照片将不会加入手记。" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"继续编辑" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"放弃" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) { [self.navigationController popViewControllerAnimated:YES]; }]];
    [self presentViewController:alert animated:YES completion:nil];
}
@end

@interface CRMBabyTimeViewController () <UIDocumentPickerDelegate>
@property (nonatomic, strong) UISegmentedControl *sections;
@property (nonatomic, strong) UIStackView *content;
@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) UILabel *audioStatus;
@property (nonatomic, strong) CRMBabyButton *pauseButton;
@property (nonatomic, strong) CRMBabyButton *recordButton;
@property (nonatomic, strong) CRMBabyButton *timerButton;
@property (nonatomic) BOOL favoritesOnly;
@property (nonatomic, strong) NSString *readingCategory;
@property (nonatomic) BOOL busy;
@property (nonatomic) BOOL wasRecording;
@property (nonatomic) NSUInteger journalLimit;
@property (nonatomic) NSUInteger readingLimit;
@property (nonatomic) NSInteger readingStage;
@property (nonatomic) BOOL didWarnLoadError;
@end
@implementation CRMBabyTimeViewController
- (void)viewDidLoad {
    [super viewDidLoad]; self.title = @"胎教与宝宝时光"; self.view.backgroundColor = BabyBackground();
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(settings)];
    self.sections = [[UISegmentedControl alloc] initWithItems:@[@"胎教", @"阅读", @"声音", @"手记", @"出生后"]];
    BOOL born = CRMBabyStore.shared.snapshot[@"profile"][@"birthDate"] != nil;
    self.sections.selectedSegmentIndex = born ? 4 : 0; self.readingStage = born ? 1 : 0;
    self.sections.translatesAutoresizingMaskIntoConstraints = NO;
    self.sections.accessibilityIdentifier = @"baby.sections";
    [self.sections addTarget:self action:@selector(sectionChanged) forControlEvents:UIControlEventValueChanged]; [self.view addSubview:self.sections];
    self.scroll = [UIScrollView new]; self.scroll.translatesAutoresizingMaskIntoConstraints = NO; [self.view addSubview:self.scroll];
    self.content = BabyStack(); self.content.spacing = 16; self.content.translatesAutoresizingMaskIntoConstraints = NO; [self.scroll addSubview:self.content];
    [NSLayoutConstraint activateConstraints:@[
        [self.sections.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10],
        [self.sections.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20], [self.sections.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.sections.heightAnchor constraintGreaterThanOrEqualToConstant:36],
        [self.scroll.topAnchor constraintEqualToAnchor:self.sections.bottomAnchor constant:8], [self.scroll.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [self.scroll.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor], [self.scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.content.topAnchor constraintEqualToAnchor:self.scroll.contentLayoutGuide.topAnchor constant:16], [self.content.bottomAnchor constraintEqualToAnchor:self.scroll.contentLayoutGuide.bottomAnchor constant:-32],
        [self.content.leadingAnchor constraintEqualToAnchor:self.scroll.contentLayoutGuide.leadingAnchor constant:20], [self.content.trailingAnchor constraintEqualToAnchor:self.scroll.contentLayoutGuide.trailingAnchor constant:-20],
        [self.content.widthAnchor constraintEqualToAnchor:self.scroll.frameLayoutGuide.widthAnchor constant:-40]
    ]];
    self.journalLimit = 20;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(audioChanged) name:CRMBabyAudioChanged object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(dayChanged) name:UIApplicationSignificantTimeChangeNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(dayChanged) name:UIApplicationWillEnterForegroundNotification object:nil];
    [self reload];
}
- (void)dealloc { [NSNotificationCenter.defaultCenter removeObserver:self]; }
- (void)viewWillAppear:(BOOL)animated { [super viewWillAppear:animated]; [self reload]; }
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (CRMBabyStore.shared.loadError && !self.didWarnLoadError && !self.presentedViewController) {
        self.didWarnLoadError = YES;
        BabyAlert(self, CRMBabyStore.shared.loadError.localizedDescription);
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController) [CRMBabyAudio.shared stop];
}
- (void)dayChanged { if (self.isViewLoaded && self.view.window && !self.presentedViewController) [self reload]; }
- (void)sectionChanged { self.scroll.contentOffset = CGPointZero; [self reload]; }
- (void)add:(UIView *)view { [self.content addArrangedSubview:view]; }
- (void)heading:(NSString *)title detail:(NSString *)detail {
    UILabel *label = BabyLabel(title, 26, BabyInk()); label.font = BabyFont(26, UIFontWeightSemibold); [self add:label];
    [self add:BabyLabel(detail, 14, BabyMuted())];
}
- (void)reload {
    for (UIView *view in self.content.arrangedSubviews) { [self.content removeArrangedSubview:view]; [view removeFromSuperview]; }
    self.audioStatus = nil; self.pauseButton = nil; self.recordButton = nil; self.timerButton = nil;
    switch (self.sections.selectedSegmentIndex) {
        case 1: [self readings]; break;
        case 2: [self sounds]; break;
        case 3: [self journal]; break;
        case 4: [self afterBirth]; break;
        default: [self prenatal]; break;
    }
}
- (void)openReading:(NSDictionary *)item {
    CRMBabyReaderController *reader = [CRMBabyReaderController new]; reader.reading = item; [self.navigationController pushViewController:reader animated:YES];
}
- (NSInteger)currentPregnancyWeek {
    NSNumber *due = CRMBabyStore.shared.snapshot[@"profile"][@"dueDate"];
    if (!due) return 18;
    NSInteger days = CRMBabyPregnancyDays([NSDate dateWithTimeIntervalSince1970:due.doubleValue], NSDate.date);
    return MIN(40, MAX(18, days / 7));
}
- (NSDictionary *)currentGuide {
    return CRMBabyWeekGuides()[(NSUInteger)([self currentPregnancyWeek] - 18)];
}
- (void)openWeekGuide:(NSDictionary *)guide {
    UIViewController *page = [UIViewController new]; page.title = [NSString stringWithFormat:@"孕 %@ 周 · %@", guide[@"week"], guide[@"title"]];
    page.view.backgroundColor = BabyBackground(); UIStackView *stack = BabyScroll(page, nil);
    [stack addArrangedSubview:BabyLabel(@"🌱  这周的陪伴主题", 26, BabyInk())];
    [stack addArrangedSubview:BabyBox(@[BabyLabel(guide[@"title"], 22, BabyInk()), BabyLabel(guide[@"prompt"], 17, BabyMuted())])];
    [stack addArrangedSubview:BabyLabel(@"可以这样开始", 20, BabyInk())];
    [stack addArrangedSubview:BabyBox(@[
        BabyLabel(@"1  先问问妈妈今天怎么样，选一个舒服的时间坐下。", 16, BabyInk()),
        BabyLabel([@"2  用平常的声音聊聊：" stringByAppendingString:guide[@"prompt"]], 16, BabyInk()),
        BabyLabel(@"3  再读一小段喜欢的文字，或哼唱熟悉的旋律。想停就停。", 16, BabyInk())
    ])];
    __weak typeof(self) weakSelf = self;
    [stack addArrangedSubview:BabyButton(@"打开胎教朗读", ^{ [page.navigationController popViewControllerAnimated:YES]; weakSelf.sections.selectedSegmentIndex = 1; weakSelf.readingStage = 0; [weakSelf sectionChanged]; })];
    [stack addArrangedSubview:BabyLabel(@"每周主题是陪伴灵感，并非胎儿发育评估。没有必须坚持的时长或次数。", 13, BabyMuted())];
    [self.navigationController pushViewController:page animated:YES];
}
- (void)chooseWeek {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"浏览孕期陪伴主题" message:@"每周一则，随时可以重读。" preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSDictionary *guide in CRMBabyWeekGuides()) {
        NSString *title = [NSString stringWithFormat:@"孕 %@ 周 · %@", guide[@"week"], guide[@"title"]];
        [sheet addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { [self openWeekGuide:guide]; }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    BabyAnchor(sheet, self, self.sections); [self presentViewController:sheet animated:YES completion:nil];
}
- (void)prenatal {
    NSDictionary *profile = CRMBabyStore.shared.snapshot[@"profile"];
    NSString *nickname = [profile[@"nickname"] length] ? profile[@"nickname"] : @"小小的你";
    NSString *stage = profile[@"birthDate"] ? @"留给我们的孕期回忆" : CRMBabyStageTitle(profile, NSDate.date);
    UILabel *welcome = BabyLabel([NSString stringWithFormat:@"你好呀，%@", nickname], 27, BabyInk()); welcome.font = BabyFont(27, UIFontWeightSemibold);
    [self add:BabyBox(@[BabyLabel(@"🌱", 48, BabyInk()), BabyLabel(stage, 15, BabyAccent()), welcome,
                        BabyLabel(@"和你说话，也好好照顾妈妈。\n从孕期开始，慢慢成为一家人。", 17, BabyMuted())])];
    __weak typeof(self) weakSelf = self;
    if (!profile[@"dueDate"] && !profile[@"birthDate"]) [self add:BabyButton(@"设置预产期，看到本周的陪伴主题", ^{ [weakSelf openProfile]; })];
    NSDictionary *guide = [self currentGuide];
    NSString *weekTitle = [NSString stringWithFormat:@"📅  %@孕 %@ 周 · %@", profile[@"dueDate"] ? @"" : @"示例 · ", guide[@"week"], guide[@"title"]];
    [self add:BabyBox(@[BabyLabel(weekTitle, 20, BabyInk()),
                        BabyLabel(guide[@"prompt"], 16, BabyMuted()),
                        BabyLabel(@"每周给家长一个聊天灵感；不用每天打卡，也不需要宝宝立刻回应。", 13, BabyMuted()),
                        BabyButton(@"看看本周怎么陪伴", ^{ [weakSelf openWeekGuide:guide]; }),
                        BabyButton(@"浏览 18—40 周的主题", ^{ [weakSelf chooseWeek]; })])];
    [self heading:@"今天想从哪件事开始？" detail:@"随心挑一件，几分钟就好。妈妈累了，休息就是最好的安排。"];
    NSInteger day = [NSCalendar.currentCalendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitEra forDate:NSDate.date];
    NSArray *topics = CRMBabyConversationPrompts(NO);
    [self add:BabyBox(@[BabyLabel(@"💬  和宝宝说说话", 19, BabyInk()), BabyLabel(topics[(NSUInteger)day % topics.count], 15, BabyMuted()), BabyButton(@"记下今天的一句话", ^{ [weakSelf newNote]; })])];
    NSArray *prenatal = CRMBabyPrenatalReadings(); NSDictionary *reading = prenatal[(NSUInteger)day % prenatal.count];
    [self add:BabyBox(@[BabyLabel(@"📖  胎教朗读", 19, BabyInk()), BabyLabel(reading[@"title"], 17, BabyInk()),
                        BabyLabel([NSString stringWithFormat:@"%lu 篇专门写给孕期的短文，可以念给宝宝，也可以读给妈妈听。", (unsigned long)prenatal.count], 14, BabyMuted()),
                        BabyButton(@"读今天这一篇", ^{ [weakSelf openReading:reading]; }),
                        BabyButton(@"去看全部孕期朗读", ^{ weakSelf.readingStage = 0; weakSelf.sections.selectedSegmentIndex = 1; [weakSelf sectionChanged]; })])];
    [self add:BabyBox(@[BabyLabel(@"🎵  听听熟悉的声音", 19, BabyInk()), BabyLabel(@"轻声哼唱，或播放一段自己也喜欢的旋律。舒服的音量就够了。", 15, BabyMuted()),
                        BabyButton(@"去声音小屋", ^{ weakSelf.sections.selectedSegmentIndex = 2; [weakSelf sectionChanged]; })])];
    [self add:BabyBox(@[BabyLabel(@"🌷  也照顾妈妈", 19, BabyInk()), BabyLabel(@"问问妈妈今天最需要什么：一个拥抱、一杯水，还是一会儿不被打扰的休息。", 15, BabyMuted()),
                        BabyButton(@"看看陪伴建议与来源", ^{ [weakSelf sources]; })])];
}
- (void)afterBirth {
    NSDictionary *profile = CRMBabyStore.shared.snapshot[@"profile"];
    NSString *stage = profile[@"birthDate"] ? CRMBabyStageTitle(profile, NSDate.date) : @"提前看看，出生后怎样陪宝宝";
    [self add:BabyBox(@[BabyLabel(@"🧸", 48, BabyInk()), BabyLabel(stage, 16, BabyAccent()),
                        BabyLabel(@"出生后的宝宝时光", 26, BabyInk()),
                        BabyLabel(@"面对面说话、一起翻书，让宝宝的兴趣带路。", 16, BabyMuted())])];
    __weak typeof(self) weakSelf = self;
    if (!profile[@"birthDate"]) [self add:BabyButton(@"宝宝出生后，再来记录出生日期", ^{ [weakSelf openProfile]; })];
    [self heading:@"以后，我们可以这样陪伴" detail:@"现在先收藏喜欢的故事，出生后再慢慢开始。"];
    [self add:BabyBox(@[BabyLabel(@"👀  看着彼此，轮流说话", 19, BabyInk()),
                        BabyLabel(@"抱着宝宝说说眼前的小事。停一停，看看宝宝的表情和声音；宝宝想休息时就停下来。", 15, BabyMuted())])];
    NSArray *readings = CRMBabyReadings();
    NSInteger day = [NSCalendar.currentCalendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitEra forDate:NSDate.date];
    NSDictionary *reading = readings[(NSUInteger)day % readings.count];
    [self add:BabyBox(@[BabyLabel(@"📚  一起翻翻书", 19, BabyInk()), BabyLabel(reading[@"title"], 17, BabyInk()),
                        BabyLabel([NSString stringWithFormat:@"%lu 篇出生后亲子共读短文，宝宝喜欢哪一页，就在那里多停一会儿。", (unsigned long)readings.count], 14, BabyMuted()),
                        BabyButton(@"看看这一篇", ^{ [weakSelf openReading:reading]; }),
                        BabyButton(@"全部出生后故事", ^{ weakSelf.readingStage = 1; weakSelf.sections.selectedSegmentIndex = 1; [weakSelf sectionChanged]; })])];
    [self add:BabyBox(@[BabyLabel(@"🎶  轻声唱一唱", 19, BabyInk()), BabyLabel(@"熟悉的歌、爸爸妈妈的声音，都可以放进日常。", 15, BabyMuted()), BabyButton(@"去声音小屋", ^{ weakSelf.sections.selectedSegmentIndex = 2; [weakSelf sectionChanged]; })])];
    NSArray *topics = CRMBabyConversationPrompts(YES);
    [self add:BabyBox(@[BabyLabel(@"💬  今天和宝宝聊聊", 19, BabyInk()), BabyLabel(topics[(NSUInteger)day % topics.count], 15, BabyMuted())])];
    [self add:BabyBox(@[BabyLabel(@"💌  把变化记下来", 19, BabyInk()), BabyLabel(@"照片、文字和录音都能留在成长手记，记下真实的日子。", 15, BabyMuted()), BabyButton(@"去成长手记", ^{ weakSelf.sections.selectedSegmentIndex = 3; [weakSelf sectionChanged]; })])];
}
- (void)readings {
    BOOL prenatal = self.readingStage == 0;
    BOOL podcast = self.readingStage == 2;
    NSArray *allReadings = podcast ? CRMBabyPodcastLetters() : prenatal ? CRMBabyPrenatalReadings() : CRMBabyReadings();
    NSString *detail = podcast ? [NSString stringWithFormat:@"%lu 期节目 · 原创共读提示与原节目入口", (unsigned long)allReadings.count] : [NSString stringWithFormat:@"%lu 篇原创%@短文 · 慢慢读，喜欢哪篇就再读一遍", (unsigned long)allReadings.count, prenatal ? @"孕期" : @"亲子"];
    [self heading:podcast ? @"写给孩子的信" : prenatal ? @"胎教朗读" : @"出生后共读" detail:detail];
    __weak typeof(self) weakSelf = self;
    UISegmentedControl *stage = [[UISegmentedControl alloc] initWithItems:@[@"孕期", @"出生后", @"家书播客"]]; stage.selectedSegmentIndex = self.readingStage;
    [stage addTarget:self action:@selector(readingStageChanged:) forControlEvents:UIControlEventValueChanged]; [self add:stage];
    if (podcast) [self add:BabyBox(@[BabyLabel(@"📬  陪孩子，也让自己成长", 19, BabyInk()),
                                   BabyLabel(@"这 38 期更适合家长先听，再挑值得分享的想法。系列书信的历史原件尚缺可靠核对依据，请把它当作播客观点，而非已证实的洛克菲勒原信。", 14, BabyMuted())])];
    [self add:BabyButton(self.favoritesOnly ? @"★ 只看收藏中 · 点击查看全部" : @"☆ 查看我的收藏", ^{ weakSelf.favoritesOnly = !weakSelf.favoritesOnly; [weakSelf reload]; })];
    if (!podcast) [self add:BabyButton([@"分类：" stringByAppendingString:self.readingCategory ?: @"全部分类"], ^{ [weakSelf chooseReadingCategory]; })];
    NSUInteger count = 0;
    NSUInteger limit = self.readingLimit ?: 12;
    NSMutableArray *filtered = [NSMutableArray new];
    for (NSDictionary *reading in allReadings) {
        if (self.favoritesOnly && ![CRMBabyStore.shared.snapshot[@"favorites"] containsObject:reading[@"id"]]) continue;
        if (self.readingCategory && ![self.readingCategory isEqual:reading[@"category"]]) continue;
        [filtered addObject:reading];
    }
    for (NSDictionary *reading in [filtered subarrayWithRange:NSMakeRange(0, MIN(limit, filtered.count))]) {
        count++;
        NSUInteger length = [reading[@"body"] length];
        NSString *meta = podcast ? @"原创导读 · 跳转收听原节目" : [NSString stringWithFormat:@"%@ · 约 %lu 分钟 · 原创", reading[@"category"], (unsigned long)MAX(1, (length + 149) / 150)];
        [self add:BabyBox(@[BabyLabel([NSString stringWithFormat:@"%@  %@", reading[@"icon"], reading[@"title"]], 19, BabyInk()), BabyLabel(meta, 12, BabyMuted()), BabyButton(podcast ? @"看导读与收听" : @"读这一篇", ^{ [weakSelf openReading:reading]; })])];
    }
    if (!count) [self add:BabyBox(@[BabyLabel(@"这里暂时没有内容", 19, BabyInk()), BabyLabel(@"试试切换分类或关闭收藏筛选。喜欢的短文可以打开后点右上角「收藏」。", 14, BabyMuted())])];
    if (filtered.count > limit) [self add:BabyButton([NSString stringWithFormat:@"再看一些 · 还有 %lu 篇", (unsigned long)(filtered.count - limit)], ^{ weakSelf.readingLimit = limit + 12; [weakSelf reload]; })];
}
- (void)readingStageChanged:(UISegmentedControl *)control { self.readingStage = control.selectedSegmentIndex; self.readingCategory = nil; self.readingLimit = 12; [self reload]; }
- (void)chooseReadingCategory {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"阅读分类" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray *categories = self.readingStage == 0 ? @[@"全部分类", @"和宝宝说话", @"爸爸来读", @"写给妈妈", @"五分钟朗读", @"轻声唱唱", @"写给宝宝", @"放松片刻"] : @[@"全部分类", @"爸爸来读", @"睡前短篇", @"温柔小诗", @"写给宝宝", @"亲子共读"];
    for (NSString *category in categories) [sheet addAction:[UIAlertAction actionWithTitle:category style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { self.readingCategory = [category isEqual:@"全部分类"] ? nil : category; self.readingLimit = 12; [self reload]; }]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]]; BabyAnchor(sheet, self, self.sections); [self presentViewController:sheet animated:YES completion:nil];
}
- (void)sounds {
    [self heading:@"声音小屋" detail:[NSString stringWithFormat:@"%lu 段原创与传统旋律的合成演奏，也可以导入你喜欢的声音。", (unsigned long)CRMBabyMelodies().count]];
    __weak typeof(self) weakSelf = self;
    self.audioStatus = BabyLabel(CRMBabyAudio.shared.status, 15, BabyInk()); self.audioStatus.accessibilityIdentifier = @"baby.audio.status";
    self.pauseButton = BabyButton(@"播放 / 暂停", ^{ [CRMBabyAudio.shared togglePause]; });
    self.recordButton = BabyButton(@"🎙 录下爸爸妈妈的声音", ^{ [CRMBabyAudio.shared startRecording]; });
    self.timerButton = BabyButton(@"定时停止", ^{ [weakSelf sleepTimer]; });
    [self add:BabyBox(@[self.audioStatus, self.pauseButton, BabyButton(@"停止播放 / 完成录音", ^{ [CRMBabyAudio.shared stop]; }), self.timerButton, self.recordButton])];
    [self add:BabyLabel(@"保持让家长感觉舒适的音量，不把耳机或音箱贴在肚子上。录音最长 3 分钟，切到后台会自动结束并保存；播放可在锁屏后继续，返回上级首页时停止。", 12, BabyMuted())];
    [self add:BabyLabel(@"内置旋律", 19, BabyInk())];
    NSUInteger melodyIndex = 0;
    for (NSDictionary *melody in CRMBabyMelodies()) {
        if (melodyIndex++ == 6) [self add:BabyLabel(@"长一点的舒缓旋律 · 约 1 分半", 19, BabyInk())];
        [self add:BabyBox(@[BabyLabel([@"♫  " stringByAppendingString:melody[@"title"]], 18, BabyInk()), BabyLabel(melody[@"detail"], 12, BabyMuted()), BabyButton(@"播放这段旋律", ^{
            NSString *file = melody[@"file"];
            NSURL *url = [NSBundle.mainBundle URLForResource:file.stringByDeletingPathExtension withExtension:file.pathExtension];
            if (!url) { BabyAlert(weakSelf, @"找不到内置音频资源，请检查应用打包。"); return; }
            [CRMBabyAudio.shared playURL:url title:melody[@"title"]];
        })])];
    }
    [self add:BabyButton(@"＋ 从「文件」导入音频", ^{ [weakSelf importAudio]; })];
    [self add:BabyBox(@[BabyLabel(@"🎼  想听更多？", 19, BabyInk()),
                        BabyLabel(@"试试搜索「轻柔钢琴」「自然声音」或 relaxing。下载到「文件」后，再点上方按钮导入。每首录音的授权条件请以曲目页面为准。", 14, BabyMuted()),
                        BabyButton(@"打开 Pixabay 音乐", ^{ [weakSelf openMusicWebsite:@"https://pixabay.com/music/"]; }),
                        BabyButton(@"打开 Musopen 古典音乐", ^{ [weakSelf openMusicWebsite:@"https://musopen.org/music/"]; })])];
    NSArray *entries = CRMBabyStore.shared.snapshot[@"entries"];
    NSMutableArray *audioEntries = [NSMutableArray new];
    for (NSDictionary *entry in entries) if ([entry[@"type"] isEqual:@"audio"]) [audioEntries addObject:entry];
    [self add:BabyLabel(@"我们的声音与收藏音频", 19, BabyInk())];
    if (!audioEntries.count) [self add:BabyLabel(@"录下一句问候，或导入自己有权使用的音频，就会出现在这里。", 14, BabyMuted())];
    for (NSDictionary *entry in audioEntries) {
        [self add:BabyBox(@[BabyLabel(entry[@"text"], 17, BabyInk()), BabyLabel([self dateText:entry], 12, BabyMuted()), BabyButton(@"播放", ^{ [weakSelf playEntry:entry]; })])];
    }
    [self audioChanged];
}
- (void)openMusicWebsite:(NSString *)address {
    NSURL *url = [NSURL URLWithString:address];
    if (![url.scheme isEqualToString:@"https"]) return;
    [UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];
}
- (void)audioChanged {
    CRMBabyAudio *audio = CRMBabyAudio.shared;
    self.audioStatus.text = audio.status;
    [self.pauseButton setTitle:audio.playing ? @"暂停播放" : @"继续播放" forState:UIControlStateNormal];
    [self.recordButton setTitle:audio.recording ? @"■ 完成并保存录音" : @"🎙 录下爸爸妈妈的声音" forState:UIControlStateNormal];
    NSString *timer = audio.remaining > 0 ? [NSString stringWithFormat:@"约 %.0f 分钟后停止 · 点击修改", ceil(audio.remaining / 60)] : @"定时停止";
    [self.timerButton setTitle:timer forState:UIControlStateNormal];
    // 录音完成后重新构建音频目录，保留刚刚更新的状态。
    BOOL finished = self.wasRecording && !audio.recording;
    self.wasRecording = audio.recording;
    if (finished && self.view.window) [self reload];
}
- (void)sleepTimer {
    if (!CRMBabyAudio.shared.playing) { BabyAlert(self, @"请先播放一段声音，再设置定时停止。"); return; }
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"多久后停止？" message:@"单首播放结束时也会自动停止。" preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSNumber *minutes in @[@5, @10, @15, @30, @0]) {
        [sheet addAction:[UIAlertAction actionWithTitle:minutes.integerValue ? [NSString stringWithFormat:@"%@ 分钟", minutes] : @"关闭定时" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { [CRMBabyAudio.shared setSleepMinutes:minutes.integerValue]; }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]]; BabyAnchor(sheet, self, self.timerButton); [self presentViewController:sheet animated:YES completion:nil];
}
- (NSString *)dateText:(NSDictionary *)entry {
    NSDateFormatter *format = [NSDateFormatter new]; format.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"]; format.dateFormat = @"yyyy年M月d日 HH:mm";
    return [format stringFromDate:[NSDate dateWithTimeIntervalSince1970:[entry[@"date"] doubleValue]]];
}
- (void)journal {
    [self heading:@"成长手记" detail:@"把平常的日子，留成以后可以翻看的礼物。"];
    __weak typeof(self) weakSelf = self;
    [self add:BabyButton(@"＋ 写一篇新手记", ^{ [weakSelf newNote]; })];
    [self add:BabyButton(@"导出手记与音频备份", ^{ [weakSelf exportBackup]; })];
    NSArray *entries = CRMBabyStore.shared.snapshot[@"entries"];
    if (!entries.count) [self add:BabyBox(@[BabyLabel(@"第一封信，从今天开始", 20, BabyInk()), BabyLabel(@"可以写一句「今天爸爸给你读了一个故事」，也可以留下一张照片或一段声音。所有记录只保存在这台设备，建议定期导出备份。", 15, BabyMuted())])];
    for (NSDictionary *entry in [entries subarrayWithRange:NSMakeRange(0, MIN(entries.count, self.journalLimit))]) {
        NSMutableArray *views = [NSMutableArray arrayWithObject:BabyLabel([self dateText:entry], 12, BabyMuted())];
        UILabel *text = BabyLabel([entry[@"text"] length] ? entry[@"text"] : @"今天的一张照片", 17, BabyInk()); text.numberOfLines = 5; [views addObject:text];
        if ([entry[@"type"] isEqual:@"photo"]) {
            NSURL *url = [CRMBabyStore.shared attachmentURL:entry[@"file"]];
            UIImage *image = url ? [UIImage imageWithContentsOfFile:url.path] : nil;
            if (image) { UIImageView *preview = [[UIImageView alloc] initWithImage:image]; preview.contentMode = UIViewContentModeScaleAspectFill; preview.clipsToBounds = YES; preview.layer.cornerRadius = 12; [preview.heightAnchor constraintEqualToConstant:180].active = YES; [views addObject:preview]; }
            else [views addObject:BabyLabel(@"照片文件缺失，文字仍然保留。", 13, BabyMuted())];
        }
        [views addObject:BabyButton([entry[@"type"] isEqual:@"audio"] ? @"播放与查看" : @"查看完整手记", ^{ [weakSelf showEntry:entry]; })];
        [self add:BabyBox(views)];
    }
    if (entries.count > self.journalLimit) [self add:BabyButton(@"再看更早的 20 条", ^{ weakSelf.journalLimit += 20; [weakSelf reload]; })];
}
- (void)showEntry:(NSDictionary *)entry {
    UIViewController *detail = [UIViewController new]; detail.title = @"那一天的我们"; detail.view.backgroundColor = BabyBackground();
    UIStackView *stack = BabyScroll(detail, nil);
    [stack addArrangedSubview:BabyLabel([self dateText:entry], 13, BabyMuted())];
    [stack addArrangedSubview:BabyBox(@[BabyLabel([entry[@"text"] length] ? entry[@"text"] : @"今天的一张照片", 19, BabyInk())])];
    if ([entry[@"type"] isEqual:@"photo"]) {
        NSURL *url = [CRMBabyStore.shared attachmentURL:entry[@"file"]]; UIImage *image = url ? [UIImage imageWithContentsOfFile:url.path] : nil;
        if (image) { UIImageView *view = [[UIImageView alloc] initWithImage:image]; view.contentMode = UIViewContentModeScaleAspectFit;
            [view.heightAnchor constraintEqualToAnchor:view.widthAnchor multiplier:MIN(2.5, image.size.height / MAX(1, image.size.width))].active = YES; [stack addArrangedSubview:view]; }
    }
    __weak typeof(self) weakSelf = self;
    __weak UIViewController *weakDetail = detail;
    if ([entry[@"type"] isEqual:@"audio"]) [stack addArrangedSubview:BabyButton(@"播放这段声音", ^{ [weakSelf playEntry:entry]; })];
    [stack addArrangedSubview:BabyButton(@"移除这条手记", ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"移除这条手记？" message:@"移除后将不再显示在手记和声音列表中。已有导出备份不受影响。" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"保留" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"移除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            NSError *error; if (![CRMBabyStore.shared removeEntry:entry[@"id"] error:&error]) { BabyAlert(weakDetail, error.localizedDescription); return; }
            [CRMBabyAudio.shared stop]; [weakDetail.navigationController popViewControllerAnimated:YES];
        }]];
        [weakDetail presentViewController:alert animated:YES completion:nil];
    })];
    [self.navigationController pushViewController:detail animated:YES];
}
- (void)playEntry:(NSDictionary *)entry {
    NSURL *url = [CRMBabyStore.shared attachmentURL:entry[@"file"]];
    if (!url) { BabyAlert(self.navigationController.topViewController, @"音频文件已不在本机，其他手记仍然保留。"); return; }
    [CRMBabyAudio.shared playURL:url title:entry[@"text"]];
}
- (void)newNote { [self.navigationController pushViewController:[CRMBabyNoteEditor new] animated:YES]; }
- (void)openProfile { [self.navigationController pushViewController:[CRMBabyProfileController new] animated:YES]; }
- (void)settings {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"宝宝时光" message:@"内容与记录可离线使用，照片和录音只保存在本机。" preferredStyle:UIAlertControllerStyleActionSheet];
    [sheet addAction:[UIAlertAction actionWithTitle:@"设置小名、预产期 / 出生日期" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { [self openProfile]; }]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"导出完整备份" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { [self exportBackup]; }]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"陪伴建议与资料来源" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { [self sources]; }]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    sheet.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem; [self presentViewController:sheet animated:YES completion:nil];
}
- (void)sources {
    UIViewController *page = [UIViewController new]; page.title = @"安心陪伴"; page.view.backgroundColor = BabyBackground();
    UIStackView *stack = BabyScroll(page, nil);
    [stack addArrangedSubview:BabyLabel(@"陪伴，比完成任务更重要", 25, BabyInk())];
    [stack addArrangedSubview:BabyBox(@[BabyLabel(@"孕期", 19, BabyInk()), BabyLabel(@"孕 18 周听觉仍在发育。可以用自然的声音说话、阅读、轻声唱歌；选择自己也喜欢的内容。不把耳机或音箱贴在腹部，也不靠加大音量追求回应。", 16, BabyMuted())])];
    [stack addArrangedSubview:BabyBox(@[BabyLabel(@"出生后", 19, BabyInk()), BabyLabel(@"把屏幕留给家长，多看宝宝的脸，给宝宝回应的时间。阅读和唱歌可以融入日常，跟随宝宝的兴趣，困倦或不愿继续时就停下。", 16, BabyMuted())])];
    [stack addArrangedSubview:BabyLabel(@"此模块用于家庭陪伴与记录，不评估胎儿或婴儿的健康与发育。具体孕期和育儿问题请咨询产检医生或儿科医生。", 13, BabyMuted())];
    NSArray *sources = @[
        @[@"NHS · 孕 18 周发育说明", @"https://www.nhs.uk/best-start-in-life/pregnancy/week-by-week-guide-to-pregnancy/2nd-trimester/week-18/"],
        @[@"NHS · 孕期阅读、唱歌与音乐", @"https://www.eput.nhs.uk/services/childrens-speech-language-therapy/universal-support-for-speech-language-and-communication-development-from-birth/bump/"],
        @[@"美国儿科学会 · 婴儿日常互动", @"https://www.healthychildren.org/English/ages-stages/baby/Pages/How-Active-is-Your-Baby.aspx"]
    ];
    for (NSArray *source in sources) [stack addArrangedSubview:BabyButton(source[0], ^{ [UIApplication.sharedApplication openURL:[NSURL URLWithString:source[1]] options:@{} completionHandler:nil]; })];
    [stack addArrangedSubview:BabyLabel(@"内置短文为本项目原创；《小星星》使用传统公版旋律并由项目合成演奏，其他两首为原创旋律。资料来源核对日期：2026-10-20。导入音频请使用自己有权使用的文件。", 12, BabyMuted())];
    [self.navigationController pushViewController:page animated:YES];
}
- (void)importAudio {
    if (self.busy) return;
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(NSString *)kUTTypeAudio] inMode:UIDocumentPickerModeImport]; picker.delegate = self; [self presentViewController:picker animated:YES completion:nil];
}
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *url = urls.firstObject; if (!url || self.busy) return;
    self.busy = YES;
    self.audioStatus.text = @"正在导入音频…";
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        BOOL scoped = [url startAccessingSecurityScopedResource];
        NSError *error;
        NSNumber *size; [url getResourceValue:&size forKey:NSURLFileSizeKey error:&error];
        NSData *data;
        if (!error && size.unsignedLongLongValue > 50 * 1024 * 1024) error = [NSError errorWithDomain:@"BabyTime" code:2 userInfo:@{NSLocalizedDescriptionKey: @"单个音频请控制在 50 MB 以内。"}];
        if (!error) data = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
        NSURL *saved;
        if (data) {
            AVAudioPlayer *probe = [[AVAudioPlayer alloc] initWithData:data error:&error];
            if (probe && probe.duration > 0) saved = [CRMBabyStore.shared saveAttachment:data extension:url.pathExtension error:&error];
            else if (!error) error = [NSError errorWithDomain:@"BabyTime" code:3 userInfo:@{NSLocalizedDescriptionKey: @"该文件没有可播放的音频内容。"}];
        }
        if (scoped) [url stopAccessingSecurityScopedResource];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.busy = NO;
            if (!saved) { BabyAlert(self, error.localizedDescription ?: @"导入失败，请选择其他音频。"); [self audioChanged]; return; }
            NSError *saveError;
            BOOL ok = [CRMBabyStore.shared addEntry:@{@"type": @"audio", @"text": url.lastPathComponent.stringByDeletingPathExtension, @"file": saved.lastPathComponent} error:&saveError];
            if (!ok) BabyAlert(self, saveError.localizedDescription);
            [self reload];
        });
    });
}
- (void)exportBackup {
    if (self.busy) { BabyAlert(self, @"正在处理文件，请稍等。"); return; }
    // 录音先封存，再读取目录，确保导出的是完整的音频文件。
    if (CRMBabyAudio.shared.recording) [CRMBabyAudio.shared stop];
    self.busy = YES;
    self.navigationItem.prompt = @"正在准备备份…";
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSError *error; NSURL *archive = [CRMBabyStore.shared exportArchive:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.busy = NO; self.navigationItem.prompt = nil;
            if (!archive) { BabyAlert(self, error.localizedDescription ?: @"备份生成失败，请检查剩余空间。"); return; }
            if (!self.view.window || self.presentedViewController) return;
            UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[archive] applicationActivities:nil];
            activity.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
            [self presentViewController:activity animated:YES completion:nil];
        });
    });
}
@end
