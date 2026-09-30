#import "CRMDigimonAtlasViewController.h"
#import "CRMAtlasParsing.h"

static UIColor *AtlasColor(NSUInteger hex) {
    return [UIColor colorWithRed:((hex >> 16) & 255) / 255.0 green:((hex >> 8) & 255) / 255.0 blue:(hex & 255) / 255.0 alpha:1];
}
static UILabel *AtlasLabel(NSString *text, CGFloat size, UIFontWeight weight) {
    UILabel *label = [[UILabel alloc] init];
    label.text = text; label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:size weight:weight];
    label.textColor = AtlasColor(0x315F57);
    return label;
}

// 简介按官方图鉴重新概括，保留逐条来源，不混用不同作品的进化设定。
static NSArray<NSDictionary<NSString *, NSString *> *> *AtlasEntries(void) {
    static NSArray *entries;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSArray *classics = @[
            @{@"id":@"agumon", @"name":@"亚古兽", @"english":@"AGUMON", @"level":@"成长期", @"type":@"爬虫型", @"attribute":@"疫苗种", @"move":@"小型火焰 · Pepper Breath", @"intro":@"像小恐龙一样用双足行走的数码宝贝。虽然尚在成长，亚古兽已经拥有坚硬的利爪和勇往直前的性格。它能从口中吐出火焰，体内蕴藏着向更强形态进化的潜力。"},
            @{@"id":@"gabumon", @"name":@"加布兽", @"english":@"GABUMON", @"level":@"成长期", @"type":@"爬虫型", @"attribute":@"数据种", @"move":@"爆炎火焰弹 · Blue Blaster", @"intro":@"身披毛皮，却属于爬虫型的数码宝贝。害羞的加布兽收集加鲁鲁兽留下的数据，制成保护自己的毛皮；披上它之后，性格也会变得大胆。蓝色火焰是它的拿手攻击。"},
            @{@"id":@"piyomon", @"name":@"比丘兽", @"english":@"BIYOMON", @"level":@"成长期", @"type":@"雏鸟型", @"attribute":@"疫苗种", @"move":@"魔法火焰 · Spiral Twister", @"intro":@"翅膀像手臂一样灵活，能够抓住物品。比丘兽还不擅长长时间飞行，平时多在地面活动，却一直向往自由翱翔的天空。它充满好奇心，能释放旋转的幻影火焰。"},
            @{@"id":@"tentomon", @"name":@"甲虫兽", @"english":@"TENTOMON", @"level":@"成长期", @"type":@"昆虫型", @"attribute":@"疫苗种", @"move":@"飞翼闪电 · Super Shocker", @"intro":@"拥有坚硬甲壳，却不喜欢争斗的昆虫型数码宝贝。甲虫兽喜欢花草和树荫，中间一对脚十分灵巧。需要战斗时，它会振动翅膀，将静电放大成电击。"},
            @{@"id":@"palmon", @"name":@"巴鲁兽", @"english":@"PALMON", @"level":@"成长期", @"type":@"植物型", @"attribute":@"数据种", @"move":@"毒蔓藤 · Poison Ivy", @"intro":@"头顶盛开着热带花朵，能够通过光合作用和根状双脚吸收养分。巴鲁兽开心时散发甜香，生气时花朵的气味则会改变。战斗中会伸出带毒的藤蔓，缠住对手。"},
            @{@"id":@"gomamon", @"name":@"哥玛兽", @"english":@"GOMAMON", @"level":@"成长期", @"type":@"海兽型", @"attribute":@"疫苗种", @"move":@"鱼群大暴走 · Marching Fishes", @"intro":@"披着保暖白毛、也能在陆地行走的海兽型数码宝贝。哥玛兽喜欢热闹，红色的毛发会随心情变化。它的爪子可以划开坚冰，还能指挥小鱼群帮助自己战斗。"},
            @{@"id":@"patamon", @"name":@"巴达兽", @"english":@"PATAMON", @"level":@"成长期", @"type":@"哺乳类型", @"attribute":@"数据种", @"move":@"空气炮 · Air Shot", @"intro":@"一对大耳朵是巴达兽最醒目的特征，也能让它在空中缓慢飞行。它性格温顺，体内隐藏着古代种传承的力量。战斗时会吸入空气，再一口气释放出去。"},
            @{@"id":@"tailmon", @"name":@"迪路兽", @"english":@"GATOMON", @"level":@"成熟期", @"type":@"圣兽型", @"attribute":@"疫苗种", @"move":@"猫猫拳 · Lightning Paw", @"intro":@"别被小巧的外形骗了：迪路兽是一只成熟期的圣兽型数码宝贝。尾巴上的神圣环象征着它的力量，长爪手套用于保护自己。它好奇又爱恶作剧，擅长迅捷的爪击。"}
        ];
        NSDataAsset *asset = [[NSDataAsset alloc] initWithName:@"digimon_catalog"];
        NSDictionary *catalog = asset.data ? [NSJSONSerialization JSONObjectWithData:asset.data options:0 error:nil] : nil;
        NSMutableArray *all = [classics mutableCopy];
        NSMutableSet *seen = [NSMutableSet set];
        for (NSDictionary *entry in classics) [seen addObject:entry[@"id"]];
        for (NSDictionary *row in catalog[@"entries"]) {
            NSString *identifier = row[@"id"];
            if (![identifier isKindOfClass:NSString.class] || !identifier.length || [seen containsObject:identifier]) continue;
            NSMutableDictionary *entry = [row mutableCopy];
            entry[@"english"] = identifier.uppercaseString;
            [all addObject:entry]; [seen addObject:identifier];
        }
        // 经典译名和官方译名都能搜索到，例如哥玛兽 / 芝蒙兽。
        for (NSUInteger i = 0; i < classics.count; i++) {
            NSMutableDictionary *entry = [all[i] mutableCopy];
            for (NSDictionary *row in catalog[@"entries"]) if ([row[@"id"] isEqual:entry[@"id"]]) { entry[@"officialName"] = row[@"name"]; break; }
            all[i] = entry;
        }
        entries = [all copy];
    });
    return entries;
}

static NSURLSession *AtlasSession(void) {
    static NSURLSession *session;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.defaultSessionConfiguration;
        configuration.URLCache = [[NSURLCache alloc] initWithMemoryCapacity:16 * 1024 * 1024 diskCapacity:128 * 1024 * 1024 diskPath:@"CRMDigimonAtlas"];
        configuration.HTTPMaximumConnectionsPerHost = 4;
        configuration.timeoutIntervalForRequest = 20;
        configuration.timeoutIntervalForResource = 30;
        session = [NSURLSession sessionWithConfiguration:configuration];
    });
    return session;
}

static NSURLRequest *AtlasRequest(NSString *identifier, BOOL picture) {
    NSURL *url;
    if (picture) {
        NSString *path = [[identifier stringByAppendingString:@".jpg"] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLPathAllowedCharacterSet];
        url = [NSURL URLWithString:[@"https://digimon.net/cimages/digimon/" stringByAppendingString:path]];
    } else {
        NSURLComponents *components = [NSURLComponents componentsWithString:@"https://digimon.net/reference_zh-CHS/detail.php"];
        components.queryItems = @[[NSURLQueryItem queryItemWithName:@"directory_name" value:identifier]];
        url = components.URL;
    }
    return [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:20];
}

static void AtlasCacheResponse(NSURLRequest *request, NSURLResponse *response, NSData *data) {
    if (data.length && data.length < 5 * 1024 * 1024) {
        NSCachedURLResponse *cached = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
        [AtlasSession().configuration.URLCache storeCachedResponse:cached forRequest:request];
    }
}

@interface CRMAtlasImageView : UIImageView
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, assign) NSUInteger generation;
- (void)loadIdentifier:(NSString *)identifier;
@end
@implementation CRMAtlasImageView
- (instancetype)init {
    if ((self = [super init])) {
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.stateLabel = AtlasLabel(@"", 12, UIFontWeightRegular);
        self.stateLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.stateLabel];
    }
    return self;
}
- (void)layoutSubviews { [super layoutSubviews]; self.stateLabel.frame = CGRectInset(self.bounds, 8, 8); }
- (void)dealloc { [self.task cancel]; }
- (void)loadIdentifier:(NSString *)identifier {
    [self.task cancel]; self.task = nil;
    NSUInteger generation = ++self.generation;
    self.image = nil;
    NSArray *bundled = @[@"agumon", @"gabumon", @"piyomon", @"tentomon", @"palmon", @"gomamon", @"patamon", @"tailmon"];
    if ([bundled containsObject:identifier]) self.image = [UIImage imageNamed:[@"atlas_" stringByAppendingString:identifier]];
    self.stateLabel.hidden = self.image != nil;
    if (self.image) return;
    self.stateLabel.text = @"正在加载插画…";
    NSURLRequest *request = AtlasRequest(identifier, YES);
    __weak typeof(self) weakSelf = self;
    self.task = [AtlasSession() dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        BOOL success = !error && [(NSHTTPURLResponse *)response statusCode] == 200 && data.length < 5 * 1024 * 1024;
        UIImage *image = success ? [UIImage imageWithData:data] : nil;
        if (image) AtlasCacheResponse(request, response, data);
        dispatch_async(dispatch_get_main_queue(), ^{
            typeof(self) self = weakSelf;
            if (!self || self.generation != generation) return;
            self.task = nil; self.image = image; self.stateLabel.hidden = image != nil;
            self.stateLabel.text = @"插画暂未加载\n请联网后在详情页点击重试";
        });
    }];
    [self.task resume];
}
@end

static UIView *AtlasHeader(UIViewController *controller, NSString *title, SEL backAction) {
    controller.view.backgroundColor = AtlasColor(0xF7F7F2);
    UIView *header = [[UIView alloc] init]; header.translatesAutoresizingMaskIntoConstraints = NO;
    [controller.view addSubview:header];
    UIButton *back = [UIButton buttonWithType:UIButtonTypeSystem];
    back.translatesAutoresizingMaskIntoConstraints = NO;
    back.backgroundColor = AtlasColor(0xE5EEEA); back.layer.cornerRadius = 15;
    [back setTitle:@"‹" forState:UIControlStateNormal];
    [back setTitleColor:AtlasColor(0x315F57) forState:UIControlStateNormal];
    back.titleLabel.font = [UIFont systemFontOfSize:30]; back.accessibilityLabel = @"返回";
    [back addTarget:controller action:backAction forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:back];
    UILabel *label = AtlasLabel(title, 23, UIFontWeightBold); label.translatesAutoresizingMaskIntoConstraints = NO;
    [header addSubview:label];
    [NSLayoutConstraint activateConstraints:@[
        [header.topAnchor constraintEqualToAnchor:controller.view.safeAreaLayoutGuide.topAnchor],
        [header.leadingAnchor constraintEqualToAnchor:controller.view.safeAreaLayoutGuide.leadingAnchor constant:18],
        [header.trailingAnchor constraintEqualToAnchor:controller.view.safeAreaLayoutGuide.trailingAnchor constant:-18],
        [header.heightAnchor constraintEqualToConstant:60],
        [back.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],
        [back.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [back.widthAnchor constraintEqualToConstant:44], [back.heightAnchor constraintEqualToConstant:44],
        [label.leadingAnchor constraintEqualToAnchor:back.trailingAnchor constant:14],
        [label.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [label.trailingAnchor constraintLessThanOrEqualToAnchor:header.trailingAnchor]
    ]];
    return header;
}

@interface CRMAtlasZoomController : UIViewController <UIScrollViewDelegate>
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *digimonName;
@property (nonatomic, strong) UIScrollView *zoom;
@property (nonatomic, strong) UIImageView *picture;
@property (nonatomic, assign) CGSize lastSize;
@end
@implementation CRMAtlasZoomController
- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *header = AtlasHeader(self, self.digimonName, @selector(close));
    self.zoom = [[UIScrollView alloc] init]; self.zoom.translatesAutoresizingMaskIntoConstraints = NO;
    self.zoom.minimumZoomScale = 1; self.zoom.maximumZoomScale = 3; self.zoom.delegate = self;
    self.zoom.backgroundColor = UIColor.whiteColor;
    self.picture = [[UIImageView alloc] initWithImage:self.image]; self.picture.contentMode = UIViewContentModeScaleAspectFit;
    self.picture.accessibilityLabel = self.digimonName;
    [self.zoom addSubview:self.picture]; [self.view addSubview:self.zoom];
    UILabel *hint = AtlasLabel(@"双指缩放 · 双击放大 / 还原", 12, UIFontWeightRegular);
    hint.textAlignment = NSTextAlignmentCenter; hint.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:hint];
    [NSLayoutConstraint activateConstraints:@[
        [self.zoom.topAnchor constraintEqualToAnchor:header.bottomAnchor constant:8],
        [self.zoom.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.zoom.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.zoom.bottomAnchor constraintEqualToAnchor:hint.topAnchor constant:-8],
        [hint.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [hint.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [hint.heightAnchor constraintEqualToConstant:28],
        [hint.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-6]
    ]];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2; [self.zoom addGestureRecognizer:doubleTap];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!CGSizeEqualToSize(self.lastSize, self.zoom.bounds.size)) {
        self.lastSize = self.zoom.bounds.size;
        self.zoom.zoomScale = 1; self.picture.frame = (CGRect){CGPointZero, self.lastSize};
        self.zoom.contentSize = self.lastSize;
    }
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView { return self.picture; }
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.picture.center = CGPointMake(MAX(scrollView.bounds.size.width, scrollView.contentSize.width) / 2,
                                     MAX(scrollView.bounds.size.height, scrollView.contentSize.height) / 2);
}
- (void)doubleTap:(UITapGestureRecognizer *)gesture {
    if (self.zoom.zoomScale > 1.01) { [self.zoom setZoomScale:1 animated:YES]; return; }
    CGPoint point = [gesture locationInView:self.picture];
    CGSize size = CGSizeMake(self.zoom.bounds.size.width / 2.5, self.zoom.bounds.size.height / 2.5);
    [self.zoom zoomToRect:CGRectMake(point.x - size.width / 2, point.y - size.height / 2, size.width, size.height) animated:YES];
}
- (void)close { [self dismissViewControllerAnimated:YES completion:nil]; }
@end

@interface CRMAtlasDetailController : ZWBaseViewController
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *entry;
@property (nonatomic, strong) CRMAtlasImageView *picture;
@property (nonatomic, strong) UILabel *profileLabel;
@property (nonatomic, strong) UILabel *tagsLabel;
@property (nonatomic, strong) UILabel *moveLabel;
@property (nonatomic, strong) UIButton *retryButton;
@property (nonatomic, strong) NSURLSessionDataTask *profileTask;
@end
@implementation CRMAtlasDetailController
+ (NSDictionary *)ss_constantParams { return @{@"hideNavigationBar": @YES}; }
- (instancetype)init {
    if ((self = [super init])) { self.hideNavigationBar = YES; self.hideTabbar = YES; self.hidesBottomBarWhenPushed = YES; }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *header = AtlasHeader(self, @"伙伴档案", @selector(goBack));
    UIScrollView *scroll = [[UIScrollView alloc] init]; scroll.translatesAutoresizingMaskIntoConstraints = NO;
    scroll.alwaysBounceVertical = YES; [self.view addSubview:scroll];
    UIStackView *content = [[UIStackView alloc] init]; content.axis = UILayoutConstraintAxisVertical; content.spacing = 18;
    content.translatesAutoresizingMaskIntoConstraints = NO; [scroll addSubview:content];
    [NSLayoutConstraint activateConstraints:@[
        [scroll.topAnchor constraintEqualToAnchor:header.bottomAnchor],
        [scroll.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [content.topAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.topAnchor constant:18],
        [content.leadingAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.leadingAnchor constant:22],
        [content.trailingAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.trailingAnchor constant:-22],
        [content.bottomAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.bottomAnchor constant:-28],
        [content.widthAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.widthAnchor constant:-44]
    ]];
    [content addArrangedSubview:AtlasLabel(self.entry[@"english"], 13, UIFontWeightSemibold)];
    [content addArrangedSubview:AtlasLabel(self.entry[@"name"], 32, UIFontWeightBold)];
    CRMAtlasImageView *picture = [[CRMAtlasImageView alloc] init]; self.picture = picture;
    [picture loadIdentifier:self.entry[@"id"]];
    picture.contentMode = UIViewContentModeScaleAspectFit; picture.backgroundColor = UIColor.whiteColor;
    picture.layer.cornerRadius = 24; picture.clipsToBounds = YES; picture.userInteractionEnabled = YES;
    picture.isAccessibilityElement = YES; picture.accessibilityLabel = [self.entry[@"name"] stringByAppendingString:@"，轻点放大图片"];
    [picture addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPicture)]];
    [content addArrangedSubview:picture]; [picture.heightAnchor constraintEqualToAnchor:content.widthAnchor multiplier:0.92].active = YES;
    UILabel *hint = AtlasLabel(@"轻点图片放大  ·  上滑探索伙伴资料 ↑", 12, UIFontWeightRegular);
    hint.textAlignment = NSTextAlignmentCenter; [content addArrangedSubview:hint];
    UILabel *tags = AtlasLabel(self.entry[@"level"], 14, UIFontWeightSemibold); self.tagsLabel = tags;
    [content addArrangedSubview:tags];
    [content addArrangedSubview:AtlasLabel(@"认识这位伙伴", 21, UIFontWeightBold)];
    UILabel *intro = AtlasLabel(@"正在加载官方中文介绍…", 16, UIFontWeightRegular); self.profileLabel = intro;
    [content addArrangedSubview:intro];
    [content addArrangedSubview:AtlasLabel(@"招牌必杀技", 21, UIFontWeightBold)];
    self.moveLabel = AtlasLabel(self.entry[@"move"] ?: @"正在加载…", 16, UIFontWeightMedium);
    [content addArrangedSubview:self.moveLabel];
    if (!self.entry[@"intro"].length) {
        self.retryButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.retryButton setTitle:@"加载介绍…" forState:UIControlStateNormal];
        [self.retryButton setTitleColor:AtlasColor(0x315F57) forState:UIControlStateNormal];
        [self.retryButton.heightAnchor constraintEqualToConstant:44].active = YES;
        [self.retryButton addTarget:self action:@selector(loadProfile) forControlEvents:UIControlEventTouchUpInside];
        [content addArrangedSubview:self.retryButton];
    }
    UIButton *source = [UIButton buttonWithType:UIButtonTypeSystem];
    [source setTitle:@"查看官方图鉴 ↗" forState:UIControlStateNormal];
    [source setTitleColor:AtlasColor(0x315F57) forState:UIControlStateNormal];
    source.backgroundColor = AtlasColor(0xE5EEEA); source.layer.cornerRadius = 16;
    [source.heightAnchor constraintEqualToConstant:48].active = YES;
    [source addTarget:self action:@selector(openSource) forControlEvents:UIControlEventTouchUpInside];
    [content addArrangedSubview:source];
    [content addArrangedSubview:AtlasLabel(@"插画与资料：Digimon Web 官方图鉴\n© BANDAI / Akiyoshi Hongo, Toei Animation\n经典八位采用简述，其他条目按需读取官方中文介绍。译名可能因版本不同。", 11, UIFontWeightRegular)];
    if (self.entry[@"intro"].length) [self updateProfileLabels];
    else [self loadProfile];
}
- (void)dealloc { [self.profileTask cancel]; }
- (void)updateProfileLabels {
    NSMutableArray *tags = [NSMutableArray array];
    for (NSString *key in @[@"level", @"type", @"attribute"]) if (self.entry[key].length) [tags addObject:self.entry[key]];
    self.tagsLabel.text = [tags componentsJoinedByString:@"   /   "];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init]; style.lineSpacing = 7;
    self.profileLabel.attributedText = [[NSAttributedString alloc] initWithString:self.entry[@"intro"] ?: @"暂无介绍" attributes:@{NSParagraphStyleAttributeName:style, NSFontAttributeName:self.profileLabel.font, NSForegroundColorAttributeName:AtlasColor(0x586D64)}];
    self.moveLabel.text = self.entry[@"move"] ?: @"官方暂未收录";
}
- (void)loadProfile {
    if (self.profileTask) return;
    self.retryButton.enabled = NO;
    [self.retryButton setTitle:@"加载介绍…" forState:UIControlStateNormal];
    NSURLRequest *request = AtlasRequest(self.entry[@"id"], NO);
    __weak typeof(self) weakSelf = self;
    self.profileTask = [AtlasSession() dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *html = !error && [(NSHTTPURLResponse *)response statusCode] == 200 ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        NSDictionary *profile = CRMAtlasParseProfile(html);
        if (profile) AtlasCacheResponse(request, response, data);
        dispatch_async(dispatch_get_main_queue(), ^{
            typeof(self) self = weakSelf;
            if (!self) return;
            self.profileTask = nil; self.retryButton.enabled = YES;
            [self.retryButton setTitle:profile ? @"重新读取介绍" : @"加载失败，点击重试" forState:UIControlStateNormal];
            if (profile) {
                NSMutableDictionary *entry = [self.entry mutableCopy]; [entry addEntriesFromDictionary:profile]; self.entry = entry;
                [self updateProfileLabels];
            } else {
                self.profileLabel.text = @"暂时无法读取官方介绍。请检查网络后重试，或点击下方按钮打开官方图鉴。";
                self.moveLabel.text = @"暂未读取";
            }
        });
    }];
    [self.profileTask resume];
}
- (void)openPicture {
    if (!self.picture.image) { [self.picture loadIdentifier:self.entry[@"id"]]; return; }
    CRMAtlasZoomController *viewer = [[CRMAtlasZoomController alloc] init];
    viewer.image = self.picture.image;
    viewer.digimonName = self.entry[@"name"]; viewer.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:viewer animated:YES completion:nil];
}
- (void)openSource {
    NSURL *url = AtlasRequest(self.entry[@"id"], NO).URL;
    [UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];
}
@end

@interface CRMAtlasCell : UICollectionViewCell
@property (nonatomic, strong) CRMAtlasImageView *picture;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *subtitle;
@end
@implementation CRMAtlasCell
- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.contentView.backgroundColor = UIColor.whiteColor;
        self.contentView.layer.cornerRadius = 22; self.contentView.clipsToBounds = YES;
        self.picture = [[CRMAtlasImageView alloc] init];
        self.name = AtlasLabel(@"", 17, UIFontWeightBold); self.name.numberOfLines = 2;
        self.subtitle = AtlasLabel(@"", 11, UIFontWeightRegular);
        self.subtitle.textColor = AtlasColor(0x82958A);
        for (UIView *view in @[self.picture, self.name, self.subtitle]) [self.contentView addSubview:view];
        self.isAccessibilityElement = YES; self.accessibilityTraits = UIAccessibilityTraitButton;
    }
    return self;
}
- (void)prepareForReuse {
    [super prepareForReuse]; [self.picture.task cancel]; self.picture.task = nil;
    self.picture.generation++; self.picture.image = nil;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.contentView.bounds.size.width, height = self.contentView.bounds.size.height;
    self.picture.frame = CGRectMake(10, 12, width - 20, height - 98);
    self.name.frame = CGRectMake(16, height - 80, width - 32, 44);
    self.subtitle.frame = CGRectMake(16, height - 33, width - 32, 18);
}
@end

@interface CRMDigimonAtlasViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate>
@property (nonatomic, strong) UICollectionView *collection;
@property (nonatomic, assign) CGFloat lastWidth;
@property (nonatomic, strong) UITextField *search;
@property (nonatomic, strong) UIButton *levelButton;
@property (nonatomic, strong) UILabel *summary;
@property (nonatomic, copy) NSString *selectedLevel;
@property (nonatomic, copy) NSArray<NSDictionary *> *filteredEntries;
@end
@implementation CRMDigimonAtlasViewController
+ (NSDictionary *)ss_constantParams { return @{@"hideNavigationBar": @YES}; }
- (instancetype)init {
    if ((self = [super init])) { self.hideNavigationBar = YES; self.hideTabbar = YES; self.hidesBottomBarWhenPushed = YES; }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *header = AtlasHeader(self, @"数码宝贝图集", @selector(goBack));
    self.filteredEntries = AtlasEntries();
    UILabel *intro = AtlasLabel(@"", 12, UIFontWeightRegular); self.summary = intro;
    intro.translatesAutoresizingMaskIntoConstraints = NO; [self.view addSubview:intro];
    self.search = [[UITextField alloc] init]; self.search.translatesAutoresizingMaskIntoConstraints = NO;
    self.search.placeholder = @"搜索中文名 / 英文标识";
    self.search.font = [UIFont systemFontOfSize:14]; self.search.textColor = AtlasColor(0x315F57);
    self.search.backgroundColor = UIColor.whiteColor; self.search.layer.cornerRadius = 14;
    self.search.clearButtonMode = UITextFieldViewModeWhileEditing; self.search.returnKeyType = UIReturnKeySearch;
    self.search.autocorrectionType = UITextAutocorrectionTypeNo; self.search.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.search.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 1)]; self.search.leftViewMode = UITextFieldViewModeAlways;
    self.search.delegate = self; [self.search addTarget:self action:@selector(filterEntries) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.search];
    self.levelButton = [UIButton buttonWithType:UIButtonTypeSystem]; self.levelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.levelButton setTitle:@"全部等级 ▾" forState:UIControlStateNormal];
    [self.levelButton setTitleColor:AtlasColor(0x315F57) forState:UIControlStateNormal];
    self.levelButton.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    self.levelButton.backgroundColor = AtlasColor(0xE5EEEA); self.levelButton.layer.cornerRadius = 14;
    [self.levelButton addTarget:self action:@selector(chooseLevel) forControlEvents:UIControlEventTouchUpInside]; [self.view addSubview:self.levelButton];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(16, 18, 24, 18); layout.minimumInteritemSpacing = 12; layout.minimumLineSpacing = 16;
    self.collection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collection.backgroundColor = UIColor.clearColor; self.collection.alwaysBounceVertical = YES;
    self.collection.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.collection.translatesAutoresizingMaskIntoConstraints = NO;
    self.collection.dataSource = self; self.collection.delegate = self;
    [self.collection registerClass:CRMAtlasCell.class forCellWithReuseIdentifier:@"digimon"];
    [self.view addSubview:self.collection];
    [NSLayoutConstraint activateConstraints:@[
        [intro.topAnchor constraintEqualToAnchor:header.bottomAnchor constant:8],
        [intro.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],
        [intro.trailingAnchor constraintEqualToAnchor:header.trailingAnchor],
        [self.search.topAnchor constraintEqualToAnchor:intro.bottomAnchor constant:12],
        [self.search.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],
        [self.search.trailingAnchor constraintEqualToAnchor:self.levelButton.leadingAnchor constant:-10],
        [self.search.heightAnchor constraintEqualToConstant:44],
        [self.levelButton.topAnchor constraintEqualToAnchor:self.search.topAnchor],
        [self.levelButton.trailingAnchor constraintEqualToAnchor:header.trailingAnchor],
        [self.levelButton.widthAnchor constraintEqualToConstant:96],
        [self.levelButton.heightAnchor constraintEqualToAnchor:self.search.heightAnchor],
        [self.collection.topAnchor constraintEqualToAnchor:self.search.bottomAnchor constant:4],
        [self.collection.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.collection.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.collection.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
    [self filterEntries];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.lastWidth != self.collection.bounds.size.width) {
        self.lastWidth = self.collection.bounds.size.width;
        [self.collection.collectionViewLayout invalidateLayout];
    }
}
- (void)filterEntries {
    NSMutableArray *matches = [NSMutableArray array];
    for (NSDictionary *entry in AtlasEntries()) if (CRMAtlasMatches(entry, self.search.text, self.selectedLevel)) [matches addObject:entry];
    self.filteredEntries = matches;
    self.summary.text = [NSString stringWithFormat:@"收录 %lu 位 · 当前 %lu 位 · 图片与介绍按需加载", (unsigned long)AtlasEntries().count, (unsigned long)matches.count];
    [self.collection reloadData];
    UILabel *empty = AtlasLabel(@"没有找到匹配的伙伴\n试试其他名称，或切换为全部等级", 15, UIFontWeightRegular);
    empty.textAlignment = NSTextAlignmentCenter;
    self.collection.backgroundView = matches.count ? nil : empty;
    [self.collection setContentOffset:CGPointMake(0, -self.collection.adjustedContentInset.top) animated:NO];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField { [textField resignFirstResponder]; return YES; }
- (void)chooseLevel {
    [self.view endEditing:YES];
    NSMutableOrderedSet *levels = [NSMutableOrderedSet orderedSetWithObject:@"全部等级"];
    for (NSDictionary *entry in AtlasEntries()) {
        if ([entry[@"level"] length]) [levels addObject:entry[@"level"]];
        if ([entry[@"secondaryLevel"] length]) [levels addObject:entry[@"secondaryLevel"]];
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"按等级浏览" message:nil preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    for (NSString *level in levels) {
        [alert addAction:[UIAlertAction actionWithTitle:level style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            weakSelf.selectedLevel = [level isEqualToString:@"全部等级"] ? nil : level;
            [weakSelf.levelButton setTitle:[level stringByAppendingString:@" ▾"] forState:UIControlStateNormal];
            [weakSelf filterEntries];
        }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section { return self.filteredEntries.count; }
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CRMAtlasCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"digimon" forIndexPath:indexPath];
    NSDictionary *entry = self.filteredEntries[indexPath.item];
    [cell.picture loadIdentifier:entry[@"id"]];
    cell.name.text = entry[@"name"]; cell.name.adjustsFontSizeToFitWidth = YES; cell.name.minimumScaleFactor = 0.7;
    cell.subtitle.text = [entry[@"attribute"] length] ? [NSString stringWithFormat:@"%@ · %@", entry[@"level"], entry[@"attribute"]] : entry[@"level"];
    cell.accessibilityLabel = [NSString stringWithFormat:@"%@，%@，查看详情", cell.name.text, cell.subtitle.text];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    CRMAtlasImageView *picture = ((CRMAtlasCell *)cell).picture;
    [picture.task cancel]; picture.task = nil; picture.generation++;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger columns = collectionView.bounds.size.width > 650 ? 3 : 2;
    CGFloat width = floor((collectionView.bounds.size.width - 36 - (columns - 1) * 12) / columns);
    return CGSizeMake(width, width + 82);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    CRMAtlasDetailController *detail = [[CRMAtlasDetailController alloc] init]; detail.entry = self.filteredEntries[indexPath.item];
    [self.navigationController pushViewController:detail animated:YES];
}
@end
