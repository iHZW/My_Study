#import "NSObject+Params.h"
//
//  ZWMemberDetailViewController.m
//  My_Study
//
//  会员详情 —— App 主题风格：品牌绿 Hero / 数据三联卡 / 圆角分组卡片
//

#import "ZWMemberDetailViewController.h"
#import "ZWMemberApi.h"
#import "ZWMemberStyle.h"
#import "UIColor+Extensions.h"
#import "LoadingUtil.h"
#import "Toast.h"

static CGFloat const kCardMargin = 16.0;

typedef NS_ENUM(NSInteger, ZWCardPosition) {
    ZWCardPositionSingle,
    ZWCardPositionTop,
    ZWCardPositionMiddle,
    ZWCardPositionBottom,
};

#pragma mark - 档案信息行（圆角分组卡片）

@interface ZWMemberInfoCell : UITableViewCell
@property (nonatomic, assign) ZWCardPosition cardPosition;
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UIView *separator;
- (void)configureTitle:(NSString *)title value:(NSString *)value;
@end

@implementation ZWMemberInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];

        _cardView = [UIView new];
        [self.contentView addSubview:_cardView];
        [_cardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, kCardMargin, 0, kCardMargin));
        }];

        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
        [_cardView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(16);
            make.centerY.mas_equalTo(0);
            make.width.mas_equalTo(76);
        }];

        _valueLabel = [UILabel new];
        _valueLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        _valueLabel.textAlignment = NSTextAlignmentRight;
        _valueLabel.numberOfLines = 2;
        [_cardView addSubview:_valueLabel];
        [_valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_titleLabel.mas_right).mas_offset(10);
            make.right.mas_equalTo(-16);
            make.centerY.mas_equalTo(0);
        }];

        _separator = [UIView new];
        [_cardView addSubview:_separator];
        [_separator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(-16);
            make.bottom.mas_equalTo(0);
            make.height.mas_equalTo(1.0 / [UIScreen mainScreen].scale);
        }];
    }
    return self;
}

- (void)configureTitle:(NSString *)title value:(NSString *)value {
    self.titleLabel.text = title;
    self.valueLabel.text = value;
    self.cardView.backgroundColor = ZWMemberCardColor();
    self.titleLabel.textColor = ZWMemberMutedColor();
    self.valueLabel.textColor = ZWMemberInkColor();
    self.separator.backgroundColor = ZWMemberBorderColor();
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat radius = 16.0;
    UIRectCorner corners = 0;
    if (self.cardPosition == ZWCardPositionSingle) {
        corners = UIRectCornerAllCorners;
    } else if (self.cardPosition == ZWCardPositionTop) {
        corners = UIRectCornerTopLeft | UIRectCornerTopRight;
    } else if (self.cardPosition == ZWCardPositionBottom) {
        corners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
    }
    if (corners == 0) {
        self.cardView.layer.mask = nil;
        return;
    }
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.cardView.bounds
                                               byRoundingCorners:corners
                                                     cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = path.CGPath;
    self.cardView.layer.mask = mask;
}

@end

#pragma mark - 订单卡片 Cell

@interface ZWMemberOrderCell : UITableViewCell
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UILabel *orderNoLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *amountLabel;
@property (nonatomic, strong) UILabel *typeLabel;
- (void)configureWithOrder:(NSDictionary *)order;
@end

@implementation ZWMemberOrderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];

        _cardView = [UIView new];
        _cardView.layer.cornerRadius = 16;
        _cardView.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
        [self.contentView addSubview:_cardView];
        [_cardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(5, kCardMargin, 5, kCardMargin));
        }];

        _orderNoLabel = [UILabel new];
        _orderNoLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
        [_cardView addSubview:_orderNoLabel];
        [_orderNoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(14);
            make.top.mas_equalTo(12);
            make.right.mas_lessThanOrEqualTo(-100);
        }];

        _dateLabel = [UILabel new];
        _dateLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightRegular];
        [_cardView addSubview:_dateLabel];
        [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_orderNoLabel.mas_left);
            make.top.mas_equalTo(_orderNoLabel.mas_bottom).mas_offset(4);
        }];

        _amountLabel = [UILabel new];
        _amountLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        _amountLabel.textAlignment = NSTextAlignmentRight;
        [_cardView addSubview:_amountLabel];
        [_amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-14);
            make.top.mas_equalTo(11);
        }];

        _typeLabel = [UILabel new];
        _typeLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightRegular];
        _typeLabel.textAlignment = NSTextAlignmentRight;
        [_cardView addSubview:_typeLabel];
        [_typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(_amountLabel.mas_right);
            make.top.mas_equalTo(_amountLabel.mas_bottom).mas_offset(4);
        }];
    }
    return self;
}

- (void)configureWithOrder:(NSDictionary *)order {
    self.cardView.backgroundColor = ZWMemberCardColor();
    self.cardView.layer.borderColor = ZWMemberBorderColor().CGColor;
    self.orderNoLabel.text = ZWMemberNonEmpty([order[@"orderNo"] isKindOfClass:[NSString class]] ? order[@"orderNo"] : nil);
    self.orderNoLabel.textColor = ZWMemberInkColor();
    NSString *consumeAt = [order[@"consumeAt"] isKindOfClass:[NSString class]] ? order[@"consumeAt"] : order[@"createdAt"];
    self.dateLabel.text = ZWMemberFormatDate(consumeAt);
    self.dateLabel.textColor = ZWMemberMutedColor();
    self.amountLabel.text = ZWMemberFormatMoney(order[@"payAmount"]);
    self.amountLabel.textColor = ZWMemberAccentColor();
    NSString *pay = ZWMemberPayMethodText(order[@"payMethod"]);
    NSString *type = ZWMemberOrderTypeText(order[@"type"]);
    self.typeLabel.text = pay.length ? [NSString stringWithFormat:@"%@ · %@", type, pay] : type;
    self.typeLabel.textColor = ZWMemberMutedColor();
}

@end

#pragma mark - 详情页

@interface ZWMemberDetailViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *member;
@property (nonatomic, strong) NSArray<NSDictionary *> *orders;
@property (nonatomic, strong) NSArray<NSArray<NSString *> *> *infoRows; // @[标题, 值]
@property (nonatomic, strong) NSArray<NSString *> *sectionTitles;
@end

@implementation ZWMemberDetailViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.routerParams[@"memberId"]) self.memberId = [self.routerParams[@"memberId"] integerValue];
    self.title = @"会员详情";

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];

    [self applyTheme];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applyTheme)
                                                 name:zhThemeUpdateNotification
                                               object:nil];
    [self loadData];
}

- (void)applyTheme {
    self.view.backgroundColor = ZWMemberBgColor();
    self.tableView.backgroundColor = [UIColor clearColor];
    if (self.member) {
        [self buildTableHeader];
        [self.tableView reloadData];
    }
}

#pragma mark - 数据

- (void)loadData {
    [LoadingUtil showLoadingInView:@"加载中…" parentView:self.view];
    __weak typeof(self) weakSelf = self;
    [ZWMemberApi fetchMemberDetail:self.memberId completion:^(NSDictionary *data, NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (error) {
            [LoadingUtil hide];
            [Toast show:[NSString stringWithFormat:@"加载失败：%@", error.localizedDescription]];
            return;
        }
        self.member = data;
        NSString *name = [data[@"name"] isKindOfClass:[NSString class]] ? data[@"name"] : nil;
        if (name.length) self.title = name;
        [self buildInfoRows];
        [ZWMemberApi fetchMemberOrders:self.memberId completion:^(NSDictionary *ordersData, NSError *err) {
            [LoadingUtil hide];
            NSArray *list = [ordersData[@"list"] isKindOfClass:[NSArray class]] ? ordersData[@"list"] : @[];
            self.orders = list;
            [self buildTableHeader];
            [self.tableView reloadData];
        }];
    }];
}

- (void)buildInfoRows {
    NSDictionary *m = self.member;
    NSMutableArray *rows = [NSMutableArray array];
    NSString *birthday  = [m[@"birthday"] isKindOfClass:[NSString class]] ? m[@"birthday"] : nil;
    NSString *source    = [m[@"source"] isKindOfClass:[NSString class]] ? m[@"source"] : nil;
    NSString *storeName = [m[@"storeName"] isKindOfClass:[NSString class]] ? m[@"storeName"] : nil;
    NSString *remark    = [m[@"remark"] isKindOfClass:[NSString class]] ? m[@"remark"] : nil;
    [rows addObject:@[@"性别", ZWMemberGenderText(m[@"gender"])]];
    if (birthday.length)  [rows addObject:@[@"生日", birthday]];
    if (source.length)    [rows addObject:@[@"来源", source]];
    if (storeName.length) [rows addObject:@[@"所属门店", storeName]];
    [rows addObject:@[@"消费次数", [NSString stringWithFormat:@"%ld 次", (long)[m[@"consumptionCount"] integerValue]]]];
    NSString *lastConsume = ZWMemberFormatDate(m[@"lastConsumeAt"]);
    if (![lastConsume isEqualToString:@"—"]) [rows addObject:@[@"最近消费", lastConsume]];
    NSString *createdAt = ZWMemberFormatDate(m[@"createdAt"]);
    if (![createdAt isEqualToString:@"—"]) [rows addObject:@[@"注册时间", createdAt]];
    if (remark.length) [rows addObject:@[@"备注", remark]];
    self.infoRows = rows;

    NSMutableArray *titles = [NSMutableArray array];
    if (rows.count) [titles addObject:@"档案信息"];
    [titles addObject:@"最近消费"];
    self.sectionTitles = titles;
}

#pragma mark - 表头（Hero + 数据卡）

- (void)buildTableHeader {
    NSDictionary *m = self.member;
    if (!m) return;
    CGFloat width = self.tableView.bounds.size.width;
    NSString *name  = [m[@"name"] isKindOfClass:[NSString class]] ? m[@"name"] : @"";
    NSString *phone = [m[@"phone"] isKindOfClass:[NSString class]] ? m[@"phone"] : nil;
    NSString *memberNo = [m[@"memberNo"] isKindOfClass:[NSString class]] ? m[@"memberNo"] : nil;
    NSString *levelName = [m[@"level"] isKindOfClass:[NSDictionary class]] ? m[@"level"][@"name"] : nil;
    if (![levelName isKindOfClass:[NSString class]] || !levelName.length) levelName = nil;
    NSMutableArray<NSString *> *tagNames = [NSMutableArray array];
    if ([m[@"tags"] isKindOfClass:[NSArray class]]) {
        for (NSDictionary *tag in m[@"tags"]) {
            NSString *tagName = [tag isKindOfClass:[NSDictionary class]] ? tag[@"name"] : nil;
            if ([tagName isKindOfClass:[NSString class]] && tagName.length) [tagNames addObject:tagName];
        }
    }
    BOOL hasPills = (levelName.length > 0 || tagNames.count > 0);
    CGFloat heroH = hasPills ? 172.0 : 132.0;
    CGFloat statsH = 78.0;
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 14 + heroH + 12 + statsH + 6)];

    // ===== Hero 卡片 =====
    UIView *hero = [[UIView alloc] initWithFrame:CGRectMake(kCardMargin, 14, width - kCardMargin * 2, heroH)];
    hero.backgroundColor = ZWMemberBrandColor();
    hero.layer.cornerRadius = 22;
    [header addSubview:hero];

    UIView *avatar = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 56, 56)];
    avatar.backgroundColor = ZWMemberOnBrandTintColor();
    avatar.layer.cornerRadius = 28;
    [hero addSubview:avatar];

    UILabel *avatarChar = [[UILabel alloc] initWithFrame:avatar.bounds];
    avatarChar.text = name.length ? [name substringToIndex:1] : @"?";
    avatarChar.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    avatarChar.textColor = ZWMemberOnBrandColor();
    avatarChar.textAlignment = NSTextAlignmentCenter;
    [avatar addSubview:avatarChar];

    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(92, 26, hero.bounds.size.width - 112, 30)];
    nameLabel.text = name;
    nameLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
    nameLabel.textColor = ZWMemberOnBrandColor();
    [hero addSubview:nameLabel];

    NSString *subText = memberNo.length
        ? [NSString stringWithFormat:@"%@  ·  NO.%@", ZWMemberNonEmpty(phone), memberNo]
        : ZWMemberNonEmpty(phone);
    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(92, 58, hero.bounds.size.width - 112, 18)];
    subLabel.text = subText;
    subLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    subLabel.textColor = ZWMemberOnBrandSubColor();
    [hero addSubview:subLabel];

    // 等级 + 标签 pills
    if (hasPills) {
        CGFloat pillX = 92;
        CGFloat pillY = heroH - 44;
        NSMutableArray<NSString *> *pills = [NSMutableArray array];
        if (levelName.length) [pills addObject:levelName];
        [pills addObjectsFromArray:tagNames];
        for (NSString *pill in pills) {
            UIFont *pillFont = [UIFont systemFontOfSize:10 weight:UIFontWeightSemibold];
            CGFloat textW = [pill boundingRectWithSize:CGSizeMake(160, 18)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName: pillFont}
                                               context:nil].size.width;
            CGFloat pillW = ceil(textW) + 16;
            if (pillX + pillW > hero.bounds.size.width - 16) break;
            UILabel *pillLabel = [[UILabel alloc] initWithFrame:CGRectMake(pillX, pillY, pillW, 24)];
            pillLabel.text = pill;
            pillLabel.font = pillFont;
            pillLabel.textColor = ZWMemberOnBrandColor();
            pillLabel.backgroundColor = ZWMemberOnBrandTintColor();
            pillLabel.textAlignment = NSTextAlignmentCenter;
            pillLabel.layer.cornerRadius = 12;
            pillLabel.layer.masksToBounds = YES;
            [hero addSubview:pillLabel];
            pillX += pillW + 8;
        }
    }

    // ===== 数据三联卡 =====
    UIView *stats = [[UIView alloc] initWithFrame:CGRectMake(kCardMargin, 14 + heroH + 12, width - kCardMargin * 2, statsH)];
    stats.backgroundColor = ZWMemberCardColor();
    stats.layer.cornerRadius = 16;
    stats.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
    stats.layer.borderColor = ZWMemberBorderColor().CGColor;
    [header addSubview:stats];

    NSArray *statItems = @[
        @[[NSString stringWithFormat:@"%ld", (long)[m[@"points"] integerValue]], @"积分"],
        @[ZWMemberFormatMoney(m[@"balance"]), @"储值余额"],
        @[ZWMemberFormatMoney(m[@"totalConsumption"]), @"累计消费"],
    ];
    CGFloat colW = stats.bounds.size.width / statItems.count;
    [statItems enumerateObjectsUsingBlock:^(NSArray *item, NSUInteger idx, BOOL *stop) {
        UILabel *value = [[UILabel alloc] initWithFrame:CGRectMake(colW * idx, 16, colW, 24)];
        value.text = item[0];
        value.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
        value.textColor = ZWMemberAccentColor();
        value.textAlignment = NSTextAlignmentCenter;
        [stats addSubview:value];

        UILabel *caption = [[UILabel alloc] initWithFrame:CGRectMake(colW * idx, 44, colW, 16)];
        caption.text = item[1];
        caption.font = [UIFont systemFontOfSize:11 weight:UIFontWeightRegular];
        caption.textColor = ZWMemberMutedColor();
        caption.textAlignment = NSTextAlignmentCenter;
        [stats addSubview:caption];

        if (idx > 0) {
            UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(colW * idx, 18, 1.0 / [UIScreen mainScreen].scale, statsH - 36)];
            divider.backgroundColor = ZWMemberBorderColor();
            [stats addSubview:divider];
        }
    }];

    self.tableView.tableHeaderView = header;
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.member ? self.sectionTitles.count : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    BOOL isInfoSection = (self.infoRows.count > 0 && section == 0);
    if (isInfoSection) return self.infoRows.count;
    return self.orders.count ? self.orders.count : 1; // 无订单时显示占位
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isInfoSection = (self.infoRows.count > 0 && indexPath.section == 0);
    return isInfoSection ? 46 : 74;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 38;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 38)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kCardMargin + 2, 10, 200, 20)];
    label.text = self.sectionTitles[section];
    label.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    label.textColor = ZWMemberInkColor();
    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isInfoSection = (self.infoRows.count > 0 && indexPath.section == 0);

    if (isInfoSection) {
        static NSString *const kInfoCellId = @"ZWMemberInfoCell";
        ZWMemberInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kInfoCellId];
        if (!cell) {
            cell = [[ZWMemberInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kInfoCellId];
        }
        NSArray *row = self.infoRows[indexPath.row];
        [cell configureTitle:row[0] value:row[1]];

        NSInteger last = self.infoRows.count - 1;
        if (self.infoRows.count == 1)      cell.cardPosition = ZWCardPositionSingle;
        else if (indexPath.row == 0)       cell.cardPosition = ZWCardPositionTop;
        else if (indexPath.row == last)    cell.cardPosition = ZWCardPositionBottom;
        else                               cell.cardPosition = ZWCardPositionMiddle;
        cell.separator.hidden = (indexPath.row == last);
        return cell;
    }

    if (self.orders.count == 0) {
        static NSString *const kEmptyCellId = @"OrderEmptyCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kEmptyCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEmptyCellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.font = [UIFont systemFontOfSize:13];
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.text = @"暂无消费记录";
        cell.textLabel.textColor = ZWMemberMutedColor();
        return cell;
    }

    static NSString *const kOrderCellId = @"ZWMemberOrderCell";
    ZWMemberOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:kOrderCellId];
    if (!cell) {
        cell = [[ZWMemberOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kOrderCellId];
    }
    [cell configureWithOrder:self.orders[indexPath.row]];
    return cell;
}

@end
