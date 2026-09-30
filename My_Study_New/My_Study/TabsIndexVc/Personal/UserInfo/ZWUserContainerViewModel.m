#import "ZWUserContainerViewModel.h"
#import "PersonalHeader.h"
#import "CRMGameCenterViewController.h"
#import "UIApplication+Ext.h"

@interface ZWUserContainerViewModel () { ZWBaseView *_view; }
@property (nonatomic, strong) UIView *heroView;
@property (nonatomic, strong) UIView *overviewView;
@end

@implementation ZWUserContainerViewModel
@synthesize view = _view;

- (instancetype)init {
    if (self = [super init]) [self buildInterface];
    return self;
}

- (UILabel *)labelWithText:(NSString *)text color:(UIColor *)color font:(UIFont *)font {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = color;
    label.font = font;
    return label;
}

- (void)buildInterface {
    [self.view addSubview:self.heroView];
    [self.view addSubview:self.overviewView];

    [self.heroView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(12);
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.height.mas_equalTo(184);
    }];
    [self.overviewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.heroView.mas_bottom).offset(12);
        make.left.right.equalTo(self.heroView);
        make.bottom.equalTo(self.view).offset(-4);
    }];

    UIView *avatar = [[UIView alloc] init];
    avatar.backgroundColor = [UIColor colorWithWhite:1 alpha:0.18];
    avatar.layer.cornerRadius = 34;
    avatar.layer.borderWidth = 1;
    avatar.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.35].CGColor;
    [self.heroView addSubview:avatar];
    UILabel *avatarIcon = [self labelWithText:@"👨🏻‍💻" color:UIColor.whiteColor font:[UIFont systemFontOfSize:34]];
    [avatar addSubview:avatarIcon];

    UILabel *welcome = [self labelWithText:@"欢迎回来" color:[UIColor colorWithWhite:1 alpha:0.68] font:[UIFont systemFontOfSize:12]];
    UILabel *name = [self labelWithText:@"我的学习空间" color:UIColor.whiteColor font:[UIFont systemFontOfSize:21 weight:UIFontWeightBold]];
    UILabel *intro = [self labelWithText:@"保持好奇，让每一次实践都有所收获。" color:[UIColor colorWithWhite:1 alpha:0.82] font:[UIFont systemFontOfSize:13]];
    [self.heroView addSubview:welcome];
    [self.heroView addSubview:name];
    [self.heroView addSubview:intro];

    UIView *badge = [[UIView alloc] init];
    badge.backgroundColor = [UIColor colorWithWhite:1 alpha:0.13];
    badge.layer.cornerRadius = 12;
    [self.heroView addSubview:badge];
    UILabel *badgeText = [self labelWithText:@"●  本地学习档案" color:[UIColor colorWithWhite:1 alpha:0.88] font:[UIFont systemFontOfSize:11 weight:UIFontWeightMedium]];
    [badge addSubview:badgeText];

    [avatar mas_makeConstraints:^(MASConstraintMaker *make) { make.left.top.equalTo(self.heroView).offset(24); make.width.height.mas_equalTo(68); }];
    [avatarIcon mas_makeConstraints:^(MASConstraintMaker *make) { make.center.equalTo(avatar); }];
    [welcome mas_makeConstraints:^(MASConstraintMaker *make) { make.left.equalTo(avatar.mas_right).offset(16); make.top.equalTo(avatar).offset(4); }];
    [name mas_makeConstraints:^(MASConstraintMaker *make) { make.left.equalTo(welcome); make.top.equalTo(welcome.mas_bottom).offset(5); }];
    [intro mas_makeConstraints:^(MASConstraintMaker *make) { make.left.equalTo(avatar); make.top.equalTo(avatar.mas_bottom).offset(17); }];
    [badge mas_makeConstraints:^(MASConstraintMaker *make) { make.left.equalTo(avatar); make.top.equalTo(intro.mas_bottom).offset(13); make.height.mas_equalTo(24); }];
    [badgeText mas_makeConstraints:^(MASConstraintMaker *make) { make.left.equalTo(badge).offset(10); make.right.equalTo(badge).offset(-10); make.centerY.equalTo(badge); }];

    NSArray *items = @[@[@"iOS", @"原生能力"], @[@"Flutter", @"跨端实践"], @[@"游戏", @"趣味体验"]];
    UIView *previous = nil;
    for (NSInteger index = 0; index < items.count; index++) {
        // 游戏方向提供快捷入口，其余两项继续展示学习方向。
        UIView *item = index == 2 ? [[UIControl alloc] init] : [[UIView alloc] init];
        if (index == 2) {
            UIControl *gameButton = (UIControl *)item;
            [gameButton addTarget:self action:@selector(openGameCenter) forControlEvents:UIControlEventTouchUpInside];
            gameButton.accessibilityLabel = @"打开小游戏乐园";
            gameButton.accessibilityTraits = UIAccessibilityTraitButton;
        }
        [self.overviewView addSubview:item];
        UILabel *value = [self labelWithText:items[index][0] color:UIColorFromRGB(0x315F57) font:[UIFont systemFontOfSize:17 weight:UIFontWeightBold]];
        UILabel *caption = [self labelWithText:items[index][1] color:UIColorFromRGB(0x87938F) font:[UIFont systemFontOfSize:11]];
        value.textAlignment = caption.textAlignment = NSTextAlignmentCenter;
        [item addSubview:value]; [item addSubview:caption];
        [item mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.overviewView);
            make.width.equalTo(self.overviewView).multipliedBy(1.0 / 3.0);
            make.left.equalTo(previous ? previous.mas_right : self.overviewView.mas_left);
        }];
        [value mas_makeConstraints:^(MASConstraintMaker *make) { make.centerX.equalTo(item); make.top.equalTo(item).offset(15); }];
        [caption mas_makeConstraints:^(MASConstraintMaker *make) { make.centerX.equalTo(item); make.top.equalTo(value.mas_bottom).offset(5); }];
        if (index == 2) {
            UILabel *arrow = [self labelWithText:@"›" color:UIColorFromRGB(0x6E9990) font:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium]];
            [item addSubview:arrow];
            [arrow mas_makeConstraints:^(MASConstraintMaker *make) { make.centerY.equalTo(value); make.left.equalTo(value.mas_right).offset(3); }];
        }
        if (index > 0) {
            UIView *line = [[UIView alloc] init]; line.backgroundColor = UIColorFromRGB(0xE8EEEB); [item addSubview:line];
            [line mas_makeConstraints:^(MASConstraintMaker *make) { make.left.centerY.equalTo(item); make.width.mas_equalTo(1); make.height.mas_equalTo(30); }];
        }
        previous = item;
    }
}

- (void)openGameCenter {
    UIViewController *currentController = [UIApplication displayViewController];
    CRMGameCenterViewController *gameCenter = [[CRMGameCenterViewController alloc] init];
    gameCenter.hidesBottomBarWhenPushed = YES;
    [currentController.navigationController pushViewController:gameCenter animated:YES];
}

- (ZWBaseView *)view {
    if (!_view) { _view = [[ZWBaseView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, self.heightView)]; _view.backgroundColor = kPersonalDefaultBGColor; }
    return _view;
}
- (UIView *)heroView {
    if (!_heroView) { _heroView = [[UIView alloc] init]; _heroView.backgroundColor = UIColorFromRGB(0x315F57); _heroView.layer.cornerRadius = 22; _heroView.layer.masksToBounds = YES; }
    return _heroView;
}
- (UIView *)overviewView {
    if (!_overviewView) { _overviewView = [[UIView alloc] init]; _overviewView.backgroundColor = UIColor.whiteColor; _overviewView.layer.cornerRadius = 18; _overviewView.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.06].CGColor; _overviewView.layer.shadowOpacity = 1; _overviewView.layer.shadowRadius = 10; _overviewView.layer.shadowOffset = CGSizeMake(0, 4); }
    return _overviewView;
}
- (CGFloat)heightView { return 284; }
- (NSString *)reuseIdentifier { return @"ZWUserContainerViewIdentifier"; }
- (void)refreshView {}
- (void)themeChangeNotification {}
@end
