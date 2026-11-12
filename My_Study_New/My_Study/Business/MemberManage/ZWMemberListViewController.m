//
//  ZWMemberListViewController.m
//  My_Study
//
//  会员列表 —— App 主题风格：品牌绿 Hero 头卡 / 圆角搜索框 / 悬浮卡片
//

#import "ZWMemberListViewController.h"
#import "ZWMemberDetailViewController.h"
#import "ZWMemberApi.h"
#import "ZWMemberStyle.h"
#import "UIColor+Extensions.h"
#import "LoadingUtil.h"
#import "Toast.h"

static CGFloat const kCardMargin = 16.0;
static CGFloat const kCardRadius = 16.0;

#pragma mark - 会员卡片 Cell

@interface ZWMemberListCell : UITableViewCell
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIView *avatarView;
@property (nonatomic, strong) UILabel *avatarLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *levelPill;
@property (nonatomic, strong) UILabel *phoneLabel;
@property (nonatomic, strong) UILabel *pointsLabel;
@property (nonatomic, strong) UILabel *pointsCaption;
@property (nonatomic, strong) UILabel *chevronLabel;
@property (nonatomic, strong) MASConstraint *pillWidthCons;
- (void)configureWithMember:(NSDictionary *)member;
@end

@implementation ZWMemberListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];

        _cardView = [UIView new];
        _cardView.layer.cornerRadius = kCardRadius;
        _cardView.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
        [self.contentView addSubview:_cardView];
        [_cardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(6, kCardMargin, 6, kCardMargin));
        }];

        _avatarView = [UIView new];
        _avatarView.layer.cornerRadius = 23;
        [_cardView addSubview:_avatarView];
        [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(14);
            make.centerY.mas_equalTo(0);
            make.width.height.mas_equalTo(46);
        }];

        _avatarLabel = [UILabel new];
        _avatarLabel.font = [UIFont systemFontOfSize:19 weight:UIFontWeightSemibold];
        _avatarLabel.textAlignment = NSTextAlignmentCenter;
        [_avatarView addSubview:_avatarLabel];
        [_avatarLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];

        _chevronLabel = [UILabel new];
        _chevronLabel.text = @"›";
        _chevronLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightLight];
        [_cardView addSubview:_chevronLabel];
        [_chevronLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-12);
            make.centerY.mas_equalTo(0);
        }];

        _pointsCaption = [UILabel new];
        _pointsCaption.text = @"积分";
        _pointsCaption.font = [UIFont systemFontOfSize:10 weight:UIFontWeightRegular];
        _pointsCaption.textAlignment = NSTextAlignmentRight;
        [_cardView addSubview:_pointsCaption];
        [_pointsCaption mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(_chevronLabel.mas_left).mas_offset(-10);
            make.bottom.mas_equalTo(_avatarView.mas_bottom).mas_offset(-1);
            make.width.mas_equalTo(60);
        }];

        _pointsLabel = [UILabel new];
        _pointsLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
        _pointsLabel.textAlignment = NSTextAlignmentRight;
        [_cardView addSubview:_pointsLabel];
        [_pointsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(_pointsCaption.mas_right);
            make.bottom.mas_equalTo(_pointsCaption.mas_top).mas_offset(-2);
            make.width.mas_equalTo(60);
        }];

        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        [_cardView addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_avatarView.mas_right).mas_offset(12);
            make.top.mas_equalTo(_avatarView.mas_top).mas_offset(1);
            make.height.mas_equalTo(22);
            make.right.mas_lessThanOrEqualTo(_pointsLabel.mas_left).mas_offset(-8);
        }];
        [_nameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

        _levelPill = [UILabel new];
        _levelPill.font = [UIFont systemFontOfSize:10 weight:UIFontWeightSemibold];
        _levelPill.textAlignment = NSTextAlignmentCenter;
        _levelPill.layer.cornerRadius = 9;
        _levelPill.layer.masksToBounds = YES;
        [_cardView addSubview:_levelPill];
        [_levelPill mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_nameLabel.mas_right).mas_offset(8);
            make.centerY.mas_equalTo(_nameLabel.mas_centerY);
            make.height.mas_equalTo(18);
            self.pillWidthCons = make.width.mas_equalTo(0);
            make.right.mas_lessThanOrEqualTo(_pointsLabel.mas_left).mas_offset(-8);
        }];

        _phoneLabel = [UILabel new];
        _phoneLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        [_cardView addSubview:_phoneLabel];
        [_phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_nameLabel.mas_left);
            make.bottom.mas_equalTo(_avatarView.mas_bottom).mas_offset(-1);
            make.height.mas_equalTo(16);
            make.right.mas_lessThanOrEqualTo(_pointsLabel.mas_left).mas_offset(-8);
        }];
    }
    return self;
}

- (void)configureWithMember:(NSDictionary *)member {
    UIColor *accent = ZWMemberAccentColor();
    self.cardView.backgroundColor = ZWMemberCardColor();
    self.cardView.layer.borderColor = ZWMemberBorderColor().CGColor;

    self.avatarView.backgroundColor = ZWMemberTintBgColor();
    self.avatarLabel.textColor = accent;
    NSString *name = [member[@"name"] isKindOfClass:[NSString class]] ? member[@"name"] : @"";
    if (!name.length) name = @"?";
    self.avatarLabel.text = [name substringToIndex:1];

    self.nameLabel.text = name;
    self.nameLabel.textColor = ZWMemberInkColor();

    NSString *levelName = [member[@"level"] isKindOfClass:[NSDictionary class]] ? member[@"level"][@"name"] : nil;
    if (![levelName isKindOfClass:[NSString class]] || !levelName.length) levelName = nil;
    if (levelName) {
        self.levelPill.hidden = NO;
        self.levelPill.text = levelName;
        self.levelPill.textColor = accent;
        self.levelPill.backgroundColor = ZWMemberTintBgColor();
        CGFloat textW = [levelName boundingRectWithSize:CGSizeMake(120, 18)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName: self.levelPill.font}
                                                context:nil].size.width;
        [self.pillWidthCons uninstall];
        [self.levelPill mas_updateConstraints:^(MASConstraintMaker *make) {
            self.pillWidthCons = make.width.mas_equalTo(ceil(textW) + 14);
        }];
    } else {
        self.levelPill.hidden = YES;
    }

    NSString *phone = [member[@"phone"] isKindOfClass:[NSString class]] ? member[@"phone"] : nil;
    self.phoneLabel.text = ZWMemberNonEmpty(phone);
    self.phoneLabel.textColor = ZWMemberMutedColor();

    self.pointsLabel.text = [NSString stringWithFormat:@"%ld", (long)[member[@"points"] integerValue]];
    self.pointsLabel.textColor = accent;
    self.pointsCaption.textColor = ZWMemberMutedColor();
    self.chevronLabel.textColor = ZWMemberMutedColor();
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [UIView animateWithDuration:0.15 animations:^{
        self.cardView.transform = highlighted ? CGAffineTransformMakeScale(0.97, 0.97) : CGAffineTransformIdentity;
        self.cardView.alpha = highlighted ? 0.85 : 1.0;
    }];
}

@end

#pragma mark - 登录页

@interface ZWMemberLoginViewController : UIViewController
/** 登录成功回调（页面 dismiss 之后执行） */
@property (nonatomic, copy) void (^onLoginSuccess)(void);
@end

@implementation ZWMemberLoginViewController {
    UITextField *_usernameField;
    UITextField *_passwordField;
    UIButton *_loginButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ZWMemberBgColor();

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];

    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setTitle:@"✕" forState:UIControlStateNormal];
    closeButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    [closeButton setTitleColor:ZWMemberMutedColor() forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(56);
        make.right.mas_equalTo(-16);
        make.width.height.mas_equalTo(36);
    }];

    UIView *card = [UIView new];
    card.backgroundColor = ZWMemberCardColor();
    card.layer.cornerRadius = 20;
    card.layer.shadowColor = [UIColor blackColor].CGColor;
    card.layer.shadowOpacity = 0.08;
    card.layer.shadowRadius = 16;
    card.layer.shadowOffset = CGSizeMake(0, 6);
    [self.view addSubview:card];
    [card mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(24);
        make.right.mas_equalTo(-24);
        make.centerY.mas_equalTo(-30);
    }];

    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"会员管理系统";
    titleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
    titleLabel.textColor = ZWMemberInkColor();
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [card addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(28);
        make.left.right.mas_equalTo(0);
    }];

    UILabel *subtitleLabel = [UILabel new];
    subtitleLabel.text = @"请使用门店账号登录";
    subtitleLabel.font = [UIFont systemFontOfSize:13];
    subtitleLabel.textColor = ZWMemberMutedColor();
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    [card addSubview:subtitleLabel];
    [subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(6);
        make.left.right.mas_equalTo(0);
    }];

    _usernameField = [self buildFieldWithPlaceholder:@"用户名" secure:NO];
    [card addSubview:_usernameField];
    [_usernameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(subtitleLabel.mas_bottom).mas_offset(24);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(46);
    }];

    _passwordField = [self buildFieldWithPlaceholder:@"密码" secure:YES];
    [card addSubview:_passwordField];
    [_passwordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_usernameField.mas_bottom).mas_offset(14);
        make.left.right.height.mas_equalTo(_usernameField);
    }];

    _loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_loginButton setTitle:@"登 录" forState:UIControlStateNormal];
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _loginButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    _loginButton.backgroundColor = ZWMemberAccentColor();
    _loginButton.layer.cornerRadius = 12;
    [_loginButton addTarget:self action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:_loginButton];
    [_loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_passwordField.mas_bottom).mas_offset(22);
        make.left.right.mas_equalTo(_passwordField);
        make.height.mas_equalTo(46);
    }];

    UILabel *hintLabel = [UILabel new];
    hintLabel.text = @"演示账号：admin/admin123（管理员）· staff/staff123（员工）";
    hintLabel.font = [UIFont systemFontOfSize:11];
    hintLabel.textColor = ZWMemberMutedColor();
    hintLabel.textAlignment = NSTextAlignmentCenter;
    hintLabel.numberOfLines = 0;
    [card addSubview:hintLabel];
    [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_loginButton.mas_bottom).mas_offset(14);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(-20);
    }];
}

- (UITextField *)buildFieldWithPlaceholder:(NSString *)placeholder secure:(BOOL)secure {
    UITextField *field = [UITextField new];
    field.backgroundColor = ZWMemberBgColor();
    field.layer.cornerRadius = 10;
    field.font = [UIFont systemFontOfSize:15];
    field.textColor = ZWMemberInkColor();
    field.attributedPlaceholder =
        [[NSAttributedString alloc] initWithString:placeholder
                                        attributes:@{NSForegroundColorAttributeName: ZWMemberMutedColor()}];
    field.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 1)];
    field.leftViewMode = UITextFieldViewModeAlways;
    field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.secureTextEntry = secure;
    return field;
}

- (void)closeTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginTapped {
    NSString *username = [_usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = _passwordField.text ?: @"";
    if (!username.length || !password.length) {
        [Toast show:@"请输入用户名和密码"];
        return;
    }
    [self.view endEditing:YES];
    _loginButton.enabled = NO;
    [LoadingUtil showLoadingInView:@"登录中…" parentView:self.view];
    __weak typeof(self) weakSelf = self;
    [ZWMemberApi loginWithUsername:username password:password completion:^(NSDictionary *data, NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        self->_loginButton.enabled = YES;
        [LoadingUtil hide];
        if (error) {
            [Toast show:error.localizedDescription];
            return;
        }
        [Toast show:@"登录成功"];
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.onLoginSuccess) self.onLoginSuccess();
        }];
    }];
}

@end

#pragma mark - 列表页

@interface ZWMemberListViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshCtrl;
@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) UIView *tableHeader;
@property (nonatomic, strong) UILabel *heroCountLabel;
@property (nonatomic, strong) UILabel *heroSubLabel;
@property (nonatomic, strong) UILabel *footerLabel;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *members;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) BOOL loading;
@end

@implementation ZWMemberListViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"会员管理";
    self.members = [NSMutableArray array];
    self.page = 1;

    self.navigationItem.rightBarButtonItems = @[
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTapped)],
        [[UIBarButtonItem alloc] initWithTitle:@"服务器" style:UIBarButtonItemStylePlain target:self action:@selector(serverTapped)],
    ];

    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    [self buildEmptyView];
    [self applyTheme];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applyTheme)
                                                 name:zhThemeUpdateNotification
                                               object:nil];
    [self updateAccountButton];
    if ([ZWMemberApi hasToken]) {
        [self reload:1];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateAccountButton];
    if (![ZWMemberApi hasToken] && !self.presentedViewController) {
        [self presentLogin];
    }
}

#pragma mark - 账号与登录

- (void)updateAccountButton {
    NSString *title = [ZWMemberApi hasToken] ? @"退出" : @"登录";
    self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:title
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(accountTapped)];
}

- (void)accountTapped {
    if (![ZWMemberApi hasToken]) {
        [self presentLogin];
        return;
    }
    NSDictionary *user = [ZWMemberApi currentUser];
    NSString *name = [user[@"realName"] isKindOfClass:[NSString class]] ? user[@"realName"] : nil;
    if (!name.length && [user[@"username"] isKindOfClass:[NSString class]]) {
        name = user[@"username"];
    }
    NSString *role = [user[@"role"] isEqualToString:@"admin"] ? @"管理员" : @"员工";
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"当前账号"
                                            message:[NSString stringWithFormat:@"%@（%@）", name.length ? name : @"未知账号", role]
                                     preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"退出登录"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction *action) {
        __strong typeof(weakSelf) self = weakSelf;
        [ZWMemberApi logout];
        [self.members removeAllObjects];
        self.heroCountLabel.text = @"0";
        [self.tableView reloadData];
        [self updateEmptyState];
        [self updateAccountButton];
        [self presentLogin];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    alert.popoverPresentationController.barButtonItem = self.navigationItem.leftBarButtonItem;
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)presentLogin {
    ZWMemberLoginViewController *login = [[ZWMemberLoginViewController alloc] init];
    login.modalPresentationStyle = UIModalPresentationFullScreen;
    __weak typeof(self) weakSelf = self;
    login.onLoginSuccess = ^{
        __strong typeof(weakSelf) self = weakSelf;
        [self updateAccountButton];
        [self reload:1];
    };
    [self presentViewController:login animated:YES completion:nil];
}

#pragma mark - 主题

- (void)applyTheme {
    self.view.backgroundColor = ZWMemberBgColor();
    self.tableView.backgroundColor = [UIColor clearColor];
    self.refreshCtrl.tintColor = ZWMemberAccentColor();
    self.footerLabel.textColor = ZWMemberMutedColor();

    self.searchField.backgroundColor = ZWMemberCardColor();
    self.searchField.layer.borderColor = ZWMemberBorderColor().CGColor;
    self.searchField.textColor = ZWMemberInkColor();
    self.searchField.tintColor = ZWMemberAccentColor();
    self.searchField.attributedPlaceholder =
        [[NSAttributedString alloc] initWithString:@"搜索姓名 / 手机号 / 会员编号"
                                        attributes:@{NSForegroundColorAttributeName: ZWMemberMutedColor(),
                                                     NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    // 空视图颜色
    if (self.emptyView.subviews.count >= 3) {
        UIView *circle = self.emptyView.subviews[0];
        circle.backgroundColor = ZWMemberTintBgColor();
        UILabel *icon = circle.subviews.firstObject;
        icon.textColor = ZWMemberAccentColor();
        ((UILabel *)self.emptyView.subviews[1]).textColor = ZWMemberInkColor();
        ((UILabel *)self.emptyView.subviews[2]).textColor = ZWMemberMutedColor();
    }
    [self.tableView reloadData];
}

#pragma mark - 视图构建

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 88;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableHeaderView = [self buildTableHeader];
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

        _refreshCtrl = [[UIRefreshControl alloc] init];
        [_refreshCtrl addTarget:self action:@selector(refreshPulled) forControlEvents:UIControlEventValueChanged];
        [_tableView addSubview:_refreshCtrl];

        _footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
        _footerLabel.font = [UIFont systemFontOfSize:12];
        _footerLabel.textAlignment = NSTextAlignmentCenter;
        _tableView.tableFooterView = _footerLabel;
    }
    return _tableView;
}

/// Hero 头卡 + 搜索框
- (UIView *)buildTableHeader {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 208)];
    header.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    // Hero 卡片
    UIView *hero = [[UIView alloc] initWithFrame:CGRectMake(kCardMargin, 14, width - kCardMargin * 2, 112)];
    hero.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    hero.backgroundColor = ZWMemberBrandColor();
    hero.layer.cornerRadius = 22;
    [header addSubview:hero];

    UILabel *eyebrow = [[UILabel alloc] initWithFrame:CGRectMake(20, 16, hero.bounds.size.width - 110, 16)];
    eyebrow.text = @"MEMBER MANAGEMENT";
    eyebrow.font = [UIFont systemFontOfSize:11 weight:UIFontWeightSemibold];
    eyebrow.textColor = [UIColor colorWithWhite:1 alpha:0.62];
    [hero addSubview:eyebrow];

    _heroCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 36, hero.bounds.size.width - 110, 36)];
    _heroCountLabel.text = @"--";
    _heroCountLabel.font = [UIFont systemFontOfSize:30 weight:UIFontWeightBold];
    _heroCountLabel.textColor = ZWMemberOnBrandColor();
    [hero addSubview:_heroCountLabel];

    _heroSubLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 78, hero.bounds.size.width - 110, 16)];
    _heroSubLabel.text = @"位会员 · 轻点查看详情";
    _heroSubLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    _heroSubLabel.textColor = ZWMemberOnBrandSubColor();
    [hero addSubview:_heroSubLabel];

    // 右侧装饰圆
    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(hero.bounds.size.width - 84, 24, 64, 64)];
    circle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    circle.backgroundColor = ZWMemberOnBrandTintColor();
    circle.layer.cornerRadius = 32;
    [hero addSubview:circle];

    UILabel *circleChar = [[UILabel alloc] initWithFrame:circle.bounds];
    circleChar.text = @"会";
    circleChar.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    circleChar.textColor = ZWMemberOnBrandColor();
    circleChar.textAlignment = NSTextAlignmentCenter;
    [circle addSubview:circleChar];

    // 搜索框
    _searchField = [[UITextField alloc] initWithFrame:CGRectMake(kCardMargin, 142, width - kCardMargin * 2, 46)];
    _searchField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchField.font = [UIFont systemFontOfSize:14];
    _searchField.layer.cornerRadius = 14;
    _searchField.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
    _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchField.returnKeyType = UIReturnKeySearch;
    _searchField.delegate = self;
    UIView *leftPad = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 14, 46)];
    _searchField.leftView = leftPad;
    _searchField.leftViewMode = UITextFieldViewModeAlways;
    [_searchField addTarget:self action:@selector(searchTextChanged:) forControlEvents:UIControlEventEditingChanged];
    [header addSubview:_searchField];

    return header;
}

- (void)buildEmptyView {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    _emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 260, width, 200)];
    _emptyView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _emptyView.hidden = YES;
    [self.view addSubview:_emptyView];

    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake((width - 72) / 2.0, 0, 72, 72)];
    circle.layer.cornerRadius = 36;
    [_emptyView addSubview:circle];
    circle.backgroundColor = ZWMemberTintBgColor();

    UILabel *icon = [[UILabel alloc] initWithFrame:circle.bounds];
    icon.text = @"员";
    icon.font = [UIFont systemFontOfSize:30 weight:UIFontWeightSemibold];
    icon.textColor = ZWMemberAccentColor();
    icon.textAlignment = NSTextAlignmentCenter;
    [circle addSubview:icon];

    UILabel *tip = [[UILabel alloc] initWithFrame:CGRectMake(0, 88, width, 22)];
    tip.text = self.searchField.text.length ? @"未找到相关会员" : @"暂无会员";
    tip.tag = 101;
    tip.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    tip.textColor = ZWMemberInkColor();
    tip.textAlignment = NSTextAlignmentCenter;
    [_emptyView addSubview:tip];

    UILabel *sub = [[UILabel alloc] initWithFrame:CGRectMake(0, 114, width, 18)];
    sub.text = @"点击右上角「＋」录入会员";
    sub.font = [UIFont systemFontOfSize:12];
    sub.textColor = ZWMemberMutedColor();
    sub.textAlignment = NSTextAlignmentCenter;
    [_emptyView addSubview:sub];
}

#pragma mark - 数据

- (void)refreshPulled {
    [self reload:1];
}

- (void)searchTextChanged:(UITextField *)field {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadFirstPage) object:nil];
    [self performSelector:@selector(reloadFirstPage) withObject:nil afterDelay:0.4];
}

- (void)reloadFirstPage {
    [self reload:1];
}

- (void)reload:(NSInteger)page {
    if (self.loading) return;
    if (![ZWMemberApi hasToken]) {
        [self presentLogin];
        return;
    }
    self.loading = YES;
    if (page == 1 && self.members.count == 0) {
        [LoadingUtil showLoadingInView:@"加载中…" parentView:self.view];
    }

    __weak typeof(self) weakSelf = self;
    NSString *keyword = self.searchField.text.length ? self.searchField.text : nil;
    [ZWMemberApi fetchMembersWithPage:page size:20 keyword:keyword completion:^(NSDictionary *data, NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        self.loading = NO;
        [LoadingUtil hide];
        [self.refreshCtrl endRefreshing];
        if (error) {
            [Toast show:[NSString stringWithFormat:@"加载失败：%@", error.localizedDescription]];
            if (self.members.count == 0) [self updateEmptyState];
            // token 失效会被网络层清除，此时引导重新登录
            if (![ZWMemberApi hasToken]) {
                [self updateAccountButton];
                [self presentLogin];
            }
            return;
        }
        self.page = page;
        self.total = [data[@"total"] integerValue];
        NSArray *list = [data[@"list"] isKindOfClass:[NSArray class]] ? data[@"list"] : @[];
        if (page == 1) {
            [self.members setArray:list];
        } else {
            [self.members addObjectsFromArray:list];
        }
        self.heroCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.total];
        [self.tableView reloadData];
        [self updateEmptyState];
        [self updateFooterState];
    }];
}

- (void)updateEmptyState {
    BOOL empty = self.members.count == 0;
    self.emptyView.hidden = !empty;
    UILabel *tip = [self.emptyView viewWithTag:101];
    tip.text = self.searchField.text.length ? @"未找到相关会员" : @"暂无会员";
}

- (void)updateFooterState {
    if (self.members.count == 0) {
        self.footerLabel.text = @"";
    } else if (self.members.count >= self.total) {
        self.footerLabel.text = @"— 已经到底了 —";
    } else {
        self.footerLabel.text = @"上拉加载更多";
    }
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const kCellId = @"ZWMemberListCell";
    ZWMemberListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (!cell) {
        cell = [[ZWMemberListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellId];
    }
    [cell configureWithMember:self.members[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *member = self.members[indexPath.row];
    ZWMemberDetailViewController *vc = [[ZWMemberDetailViewController alloc] init];
    vc.memberId = [member[@"id"] integerValue];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat threshold = scrollView.contentSize.height - scrollView.bounds.size.height - 120;
    if (offsetY > threshold && !self.loading && self.members.count > 0 && self.members.count < self.total) {
        self.footerLabel.text = @"加载中…";
        [self reload:self.page + 1];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self reload:1];
    return YES;
}

#pragma mark - 操作

- (void)addTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"新增会员"
                                                                   message:@"填写姓名和手机号即可开卡"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.placeholder = @"姓名"; }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) {
        tf.placeholder = @"手机号";
        tf.keyboardType = UIKeyboardTypePhonePad;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        NSString *name = alert.textFields[0].text;
        NSString *phone = alert.textFields[1].text;
        if (!name.length || !phone.length) {
            [Toast show:@"姓名和手机号不能为空"];
            return;
        }
        [LoadingUtil showLoadingInView:@"开卡中…" parentView:weakSelf.view];
        [ZWMemberApi createMemberWithName:name phone:phone completion:^(NSDictionary *data, NSError *error) {
            [LoadingUtil hide];
            if (error) {
                [Toast show:[NSString stringWithFormat:@"创建失败：%@", error.localizedDescription]];
            } else {
                [Toast show:@"开卡成功"];
                [weakSelf reload:1];
            }
        }];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)serverTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"服务器地址"
                                                                   message:@"例如 http://192.168.1.5:3000"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) {
        tf.text = [ZWMemberApi baseURL];
        tf.keyboardType = UIKeyboardTypeURL;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        [ZWMemberApi setBaseURL:alert.textFields.firstObject.text];
        [Toast show:@"已保存服务器地址"];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
